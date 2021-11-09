%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Inspector(inspect)
%   Ozcar(breakpoint)
   System(show)

   Helpers(cIL2A iIL2I collectILs collectCILs unique isSubset) at 'Helpers.ozf'
export
   Check
prepare
   ListMapInd = List.mapInd
   ListZip = List.zip
   RecordZip = Record.zip
define
   %% Check: G TnTypeDict AClassILTCoRec -> GTCh#AClassILTChRec#TnTypeRec
   %% Converts grammar G into GTCh, performing typechecking on its
   %% way, creates AClassILRec, mapping keys A to class uses
   %% ClassILTCh, and creates TnTypeRec from TnTypeDict, instantiating
   %% all type variables in TnTypeDict.
   fun {Check G TnTypeDict AClassILTCoRec}
      %% CheckAnnotation: Tn AnnoTn Coord File -> U
      %% Tn is the type name for Type, and AnnoTn for AnnoType.  Check
      %% whether the annotated type AnnoType is a correct annotation
      %% for type Type.
      %% In addition, instantiate type variables (i.e. change
      %% TnTypeDict).
      proc {CheckAnnotation Tn AnnoTn Coord File}
	 if Tn==noTn then
	    skip
	 else
	    Type = {Tn2Type Tn Coord File}
	    AnnoType = {Tn2Type AnnoTn Coord File}
	 in
	    if Type.tag=='type.variable' then
	       TnTypeDict.Tn := AnnoType
	    else
	       TagA = Type.tag
	       AnnoTagA = AnnoType.tag
	    in
	       if {Not TagA==AnnoTagA} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'CheckAnnotation' msg:'Type error: type '#TagA#' annotated with '#AnnoTagA info:o(Type AnnoType) coord:Coord file:File) end
	       else
		  case TagA
		  of 'type.domain' then
		     ArgAs = Type.args
		     AnnoArgAs = AnnoType.args
		  in
		     if {Not ArgAs==AnnoArgAs} then
			raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'CheckAnnotation' msg:'Type error: type and annotated type have different domains.' info:o(ArgAs AnnoArgAs Type AnnoType) coord:Coord file:File) end
		     end
		  [] 'type.set' then
		     ArgTn = Type.arg
		     AnnoArgTn = AnnoType.arg
		  in
		     {CheckAnnotation ArgTn AnnoArgTn Coord File}
		  [] 'type.iset' then
		     ArgTn = Type.arg
		     AnnoArgTn = AnnoType.arg
		  in
		     {CheckAnnotation ArgTn AnnoArgTn Coord File}
		  [] 'type.tuple' then
		     ArgsTns = Type.args
		     AnnoArgsTns = AnnoType.args
		  in
		     _ =
		     {ListZip ArgsTns AnnoArgsTns
		      fun {$ Tn AnnoTn}
			 {CheckAnnotation Tn AnnoTn Coord File}
			 _
		      end}
		  [] 'type.list' then
		     ArgTn = Type.arg
		     AnnoArgTn = AnnoType.arg
		  in
		     {CheckAnnotation ArgTn AnnoArgTn Coord File}
		  [] 'type.record' then
		     ArgsATnRec=  Type.args
		     AnnoArgsATnRec = AnnoType.args
		  in
		     _ =
		     {RecordZip ArgsATnRec AnnoArgsATnRec
		      fun {$ Tn AnnoTn}
			 {CheckAnnotation Tn AnnoTn Coord File}
			 _
		      end}
		  else
		     %% for all types without args, e.g. type.string
		     %% just the tags must match, i.e.  no more tests
		     %% to do :)
		     skip
		  end
	       end
	    end
	 end
      end
      %% Tn2Type: Tn Coord File -> Type
      %% Gets type Type corresponding to type name Tn.
      fun {Tn2Type Tn Coord File}
	 if {Not {HasFeature TnTypeDict Tn}} then
	    raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Tn2Type' msg:'The type name -> type mapping does not include type name. '#Tn info:o coord:Coord file:File) end
	 end
	 TnTypeDict.Tn
      end
      %% CheckType: Type IL -> U
      %% Checks type Type (of IL expression IL):
      %% - {Not Type==noType}
      %% - {Not Type.tag=='type.variable}
      proc {CheckType Type IL}
	 if Type==noType then
	    Coord = IL.coord
	    File = IL.file
	 in
	    raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'CheckType' msg:'Type error: unspecified type (hint: try to add a type annotation or use a feature path).' info:o(IL Type) coord:Coord file:File) end
	 end
	 %%
	 if Type.tag=='type.variable' then
	    Coord = IL.coord
	    File = IL.file
	 in
	    raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'CheckType' msg:'Type error: uninstantiated type variable (hint: try to add a type annotation or use a feature path).' info:o(IL) coord:Coord file:File) end
	 end
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Check1: IL Tn -> ILTCh
      %% Converts IL into ILTCh, performing typechecking on its way.
      %% Changes from IL to ILTCh:
      %% - adds to each IL term the feature tn:Tn where Tn is the type
      %% name of the term's type
      %% - removes all type annotations (after typechecking them of
      %% course)
      %% - instantiates type variables (either by type annotations or
      %% by feature paths)
      fun {Check1 IL Tn}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
	 %%
	 Type = {CondSelect TnTypeDict Tn noType}
      in
	 case IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% grammar
	 of elem(tag: grammar
		 principles: PrincipleILs
		 dimensions: DimensionILs
		 usedimensions: DIDCILs
		 classes: ClassILs
		 entries: EntryILs
		 outputs: OutputILs ...) then
	    DimensionILs1 = {Map DimensionILs
			     fun {$ DimensionIL}
				{Check1 DimensionIL noTn}
			     end}
	    EntryILs1 = {Map EntryILs
			 fun {$ EntryIL}
			    {Check1 EntryIL noTn}
			 end}
	 in
	    elem(tag: grammar
		 principles: PrincipleILs
		 dimensions: DimensionILs1
		 usedimensions: DIDCILs
		 classes: ClassILs
		 entries: EntryILs1
		 outputs: OutputILs
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% dimension
	 [] elem(tag: dimension
		 id: DIDCIL
		 attrs: AttrsTn
		 entry: EntryTn
		 label: LabelTn
		 types: TypedefILs
		 principles: PrincipleILs
		 outputs: OutputILs
		 useoutputs: UseOutputILs ...) then
	    %% check for duplicate model fields in the principle
	    %% definitions of the used principles
	    _ =
	    {FoldL PrincipleILs
	     fun {$ AccAs PrincipleIL}
		Coord1 = {CondSelect PrincipleIL coord Coord}
		File1 = {CondSelect PrincipleIL file File}
		%%
		ModelTn = PrincipleIL.modelTn
		ModelType = {Tn2Type ModelTn Coord1 File1}
		ATypeILRec = ModelType.args
		As = {Arity ATypeILRec}
	     in
		for A in As do
		   if {Member A AccAs} then
		      raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Duplicate model field in principle definition: '#A info:o(AccAs PrincipleIL IL Type 'dimension') coord:Coord1 file:File1) end
		   end
		end
		{Append As AccAs}
	     end nil}
	    %%
	    PrincipleILs1 =
	    {Map PrincipleILs
	     fun {$ PrincipleIL} {Check1 PrincipleIL noTn} end}
	 in
	    elem(tag: dimension
		 id: DIDCIL
		 attrs: AttrsTn
		 entry: EntryTn
		 label: LabelTn
		 types: TypedefILs
		 principles: PrincipleILs1
		 outputs: OutputILs
		 useoutputs: UseOutputILs
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% useprinciple
	 [] elem(tag: useprinciple
		 idref: PIDCIL
		 dimensions: CILCILTups
		 args: IL
		 %%
		 modelTn: ModelTn
		 %%
		 constraints: Constraints
		 %%
		 pn: Pn
		 %%
		 dIDA: DIDA ...) then
	    IL1 = {Check1 IL noTn}
	 in
	    elem(tag: useprinciple
		 idref: PIDCIL
		 dimensions: CILCILTups
		 args: IL1
		 %%
		 modelTn: ModelTn
		 %%
		 constraints: Constraints
		 %%
		 pn: Pn
		 %%
		 dIDA: DIDA
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% class.ref
	 [] elem(tag: 'class.ref'
		 idref: CIDCIL
		 args: VILILTups
		 key: KeyA ...) then
	    if {HasFeature AClassILTChDict KeyA} then
	       %% need not typecheck if this has already been done :-}
	       skip
	    else
	       ClassILTCo = AClassILTCoRec.KeyA
	       ClassILTCh = {Check1 ClassILTCo Tn}
	    in
	       AClassILTChDict.KeyA := ClassILTCh
	    end
	    %%
	    ILTCh = elem(tag: 'class.ref'
			 idref: CIDCIL
			 args: VILILTups
			 %%
			 key: KeyA
			 %%
			 coord: Coord
			 file: File)
	 in
	    ILTCh
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% constant
	 [] elem(tag: constant
		 data: A ...) then
	    {CheckType Type IL}
	    %%
	    ILTCh =
	    case Type
	    of elem(tag: 'type.domain'
		    args: As) then
	       if {Not {Member A As}} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant not included in domain type: '#A info:o(Type IL 'constant') coord:Coord file:File) end
	       end
	    in
	       elem(tag: constant
		    data: A
		    %%
		    tn: Tn
		    %%
		    coord: Coord
		    file: File)
	    [] elem(tag: 'type.string') then
	       elem(tag: constant
		    data: A
		    %%
		    tn: Tn
		    %%
		    coord: Coord
		    file: File)
	    [] elem(tag: 'type.record'
		    args: ATnRec) then
	       As = {Arity ATnRec}
	       if As==nil then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: valency type has non-empty domain.' info:o(Type IL 'constant') coord:Coord file:File) end
	       end
	       A1 = As.1
	       Tn1 = ATnRec.A1
	       Type1 = {Tn2Type Tn1 Coord File}
	       {CheckType Type1 IL}
	       Type1TagA = Type1.tag
	       if {Not Type1TagA=='type.card'} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: cardinality type expected for cardinality specification, but got: '#Type1TagA info:o(Type IL 'constant') coord:Coord file:File) end
	       end
	       IL1 = IL#elem(tag: 'card.wild'
			     arg: '!'
			     %%
			     coord: Coord
			     file: File)
	       IL2 = {Check1 IL1 Tn}
	    in
	       IL2
	    [] elem(tag: 'type.tuple'
		    args: Tns) then
	       if {Not {Length Tns}==2} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): tuple type has '#{Length Tns}#' projections instead of two.' info:o(IL Type 'constant') coord:Coord file:File) end
	       end
	       Tn1 = Tns.1
	       Type1 = TnTypeDict.Tn1
	       Type1TagA = Type1.tag
	       if {Not Type1TagA=='type.domain'} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): first projection of tuple type has type '#Type1TagA#' instead of type.domain.' info:o(IL Type 'constant' Type1) coord:Coord file:File) end
	       end
	       Tn2 = {Nth Tns 2}
	       Type2 = TnTypeDict.Tn2
	       Type2TagA = Type2.tag
	       if {Not Type2TagA=='type.domain'} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): second projection of tuple type has type '#Type2TagA#' instead of type.domain.' info:o(IL Type 'constant' Type2) coord:Coord file:File) end
	       end
	       if {Not {Helpers.isSubset Type2.args ['!' '?' '*' '+']}} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): second projection of tuple type has domain type which is not a subset of {! ? * +}.' info:o(IL Type 'constant' Type2) coord:Coord file:File) end
	       end
	       IL1 = IL#elem(tag: 'card.wild'
			     arg: '!'
			     %%
			     coord: Coord
			     file: File)
	       IL2 = {Check1 IL1 Tn}
	    in
	       IL2
	    else
	       TagA = Type.tag
	    in
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: constant has type assumption '#TagA info:o(IL Type 'constant') coord:Coord file:File) end
	    end
	 in
	    ILTCh
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% integer
	 [] elem(tag: integer
		 data: I ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    if {Not TypeTagA=='type.int'} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer has type assumption '#TypeTagA info:o(IL Type 'integer') coord:Coord file:File) end
	    end
	    %%
	    if I<1 then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer is less than one: '#I info:o(IL Type 'integer') coord:Coord file:File) end
	    end
	 in
	    elem(tag: integer
		 data: I
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% top/bot
	 [] elem(tag: top ...) then
	    {CheckType Type IL}
	 in
	    elem(tag: top
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	 [] elem(tag: bot ...) then
	    {CheckType Type IL}
	 in
	    elem(tag: bot
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set
	 [] elem(tag: set
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    TagA#ILs1 =
	    if TypeTagA=='type.set' orelse
	       TypeTagA=='type.iset' then
	       Tn1 = Type.arg
	    in
	       set#{Map ILs
		    fun {$ IL} {Check1 IL Tn1} end}
	    elseif TypeTagA=='type.record' then
	       record#{Map ILs
		       fun {$ IL1} {Check1 IL1 Tn} end}
	    else
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: set has type assumption '#TypeTagA info:o(IL Type 'set') coord:Coord file:File) end
	    end
	 in
	    elem(tag: TagA
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% list
	 [] elem(tag: list
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    ILs1 =
	    case Type
	    of elem(tag: 'type.list'
		    arg: Tn1) then
	       {Map ILs
		fun {$ IL} {Check1 IL Tn1} end}
	    [] elem(tag: 'type.tuple'
		    args: Tns) then
	       {ListMapInd ILs
		fun {$ I IL}
		   if {Not {Length Tns}>=I} then
		      Coord1 = {CondSelect IL coord Coord}
		      File1 = {CondSelect IL file File}
		   in
		      raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: tuple type does not have enough projections (must have at least '#I#').' info:o(Type IL 'list') coord:Coord1 file:File1) end
		   end
		   Tn1 = {Nth Tns I}
		in
		   {Check1 IL Tn1}
		end}
	    else
	       TagA = Type.tag
	    in
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: list has type assumption '#TagA info:o(IL Type 'list') coord:Coord file:File) end
	    end
	 in
	    elem(tag: list
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.wild
	 [] elem(tag: 'card.wild'
		 arg: IL ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	 in
	    case TypeTagA
	    of 'type.card' then
	       elem(tag: 'card.wild'
		    arg: IL
		    %%
		    tn: Tn
		    %%
		    coord: Coord
		    file: File)
	    [] 'type.domain' then
	       ConstantA =
	       case IL
	       of '!' then '!'
	       [] '?' then '?'
	       [] '*' then '*'
	       [] '+' then '+'
	       else
		  raise error1('functor':'Compiler/TypeChecker.ozf'  'proc':'Check1' msg:'Type error: only wild cards "!", "?", "*" and "+" supported for pairs' info:o(IL Type 'card.wild') coord:Coord file:File) end
	       end
	    in
	       elem(tag: 'constant'
		    data: ConstantA
		    %%
		    tn: Tn
		    %%
		    coord: Coord
		    file: File)
	    else
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: cardinality or domain type expected for wild card expression, but got: '#TypeTagA info:o(IL Type 'card.wild') coord:Coord file:File) end
	    end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.set
	 [] elem(tag: 'card.set'
		 args: IILs ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    if {Not TypeTagA=='type.card'} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: cardinality type expected for cardinality set, but got: '#TypeTagA info:o(IL Type 'card.set') coord:Coord file:File) end
	    end
	    %%
	    for IIL in IILs do
	       IILTagA = IIL.tag
	       if {Not IILTagA=='integer'} then
		  Coord1 = {CondSelect IIL coord Coord}
		  File1 = {CondSelect IIL file File}
	       in
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer expected in cardinality set, but got: '#IILTagA info:o(IIL IL Type 'card.set') coord:Coord1 file:File1) end
	       end
	       %%
	       I = {Helpers.iIL2I IIL}
	    in
	       if I<0 then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer in cardinality set is negative: '#I info:o(IL Type 'card.set') coord:Coord file:File) end
	       end
	    end
	 in
	    elem(tag: 'card.set'
		 args: IILs
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)	    
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.interval
	 [] elem(tag: 'card.interval'
		 arg1: IIL1
		 arg2: IIL2 ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    if {Not TypeTagA=='type.card'} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: cardinality type expected for cardinality interval, but got: '#TypeTagA info:o(IL Type 'card.interval') coord:Coord file:File) end
	    end
	    %%
	    IIL1TagA = IIL1.tag
	    if {Not IIL1TagA=='integer'} then
	       Coord1 = {CondSelect IIL1 coord Coord}
	       File1 = {CondSelect IIL1 file File}
	    in
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer expected as left argument of a cardinality interval, but got: '#IIL1TagA info:o(IIL1 IL Type 'card.interval') coord:Coord1 file:File1) end
	    end
	    %%
	    IIL2TagA = IIL2.tag
	    if {Not IIL2TagA=='integer'} then
	       Coord2 = {CondSelect IIL2 coord Coord}
	       File2 = {CondSelect IIL2 file File}
	    in
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: integer expected as right argument of a cardinality interval, but got: '#IIL2TagA info:o(IIL2 IL Type 'card.interval') coord:Coord2 file:File2) end
	    end
	    %%
	    I1 = {Helpers.iIL2I IIL1}
	    I2 = {Helpers.iIL2I IIL2}
	    if I1>I2 then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: the left argument of a cardinality interval is greater than the right one: '#I1#'>'#I2 info:o(IL Type 'card.interval') coord:Coord file:File)
	       end
	    end
	    %%
	    if I1<0 then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: the left argument of a cardinality interval is negative: '#I1 info:o(IL Type 'card.interval') coord:Coord file:File) end
	    end
	    %%
	    if I2<0 then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: the right argument of a cardinality interval is negative: '#I2 info:o(IL Type 'card.interval') coord:Coord file:File) end
	    end
	 in
	    elem(tag: 'card.interval'
		 arg1: IIL1
		 arg2: IIL2
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% record
	 [] elem(tag: record	      
		 args: CILILTups ...) then
	    {CheckType Type IL}
	    %%
	    CILILTups1 = {Map CILILTups
			  fun {$ CILILTup} {Check1 CILILTup Tn} end}
	 in
	    elem(tag: record
		 args: CILILTups1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set generator
	 [] elem(tag: setgen
		 arg: IL ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    if TypeTagA=='type.set' orelse
	       TypeTagA=='type.iset' then
	       Tn1 = Type.arg
	       Type1 = {Tn2Type Tn1 Coord File}
	       {CheckType Type1 IL}
	       Tns = case Type1
		     of elem(tag: 'type.tuple'
			     args: Tns1) then
			Tns1
		     else
			raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: the domain of the set type of the set generator is not a tuple.' info:o(Type1 IL Type 'setgen') coord:Coord file:File) end
		     end
	       %%
	       As =
	       for Tn2 in Tns append:Append do
		  Type2 = {Tn2Type Tn2 Coord File}
		  {CheckType Type2 IL}
		  As1 = case Type2
			of elem(tag: 'type.domain'
				args: As2) then
			   As2
			else
			   raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: at least one projection of the tuple domain of the set type of the set generator expression is not a domain.' info:o(Type2 IL Type 'setgen') coord:Coord file:File) end
			end
	       in
		  {Append As1}
	       end	       
	       %% collect all constants in the set generator expression (As1)
	       CILs = {Helpers.collectILs IL}
	       As1 = {Map CILs Helpers.cIL2A}
	    in
	       %% check whether As1 contains only constants A1 which
	       %% are included in As
	       for A1 in As1 do
		  if {Not {Member A1 As}} then
		     raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: set generator expression contains a constant not contained in any of the corresponding domain types: '#A1 info:o(As IL Type 'setgen') coord:Coord file:File) end
		  end
		  %%
		  if {Not {Helpers.unique A1 As}} then
		     raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: set generator expression is ambiguous: it contains a constant contained in more than one of the corresponding domain types: '#A1 info:o(As IL Type 'setgen') coord:Coord file:File) end
		  end		     
	       end
	    else
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: set generator expression has type assumption '#TypeTagA#' but must have either type.set or type.iset' info:o(IL Type 'setgen') coord:Coord file:File) end
	    end
	 in
	    elem(tag: setgen
		 arg: IL
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% annotation
	 [] elem(tag: annotation
		 arg1: IL1
		 arg2: Tn1 ...) then
	    Type1 = {Tn2Type Tn1 Coord File}
	    {CheckType Type1 IL}
	    %%
	    {CheckAnnotation Tn Tn1 Coord File}
	    %%
	    IL2 = {Check1 IL1 Tn1}
	 in
	    IL2
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% conjunction
	 [] elem(tag: conj
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    ILs1 =
	    {Map ILs fun {$ IL} {Check1 IL Tn} end}
	 in
	    elem(tag: conj
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjunction
	 [] elem(tag: disj
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    ILs1 =
	    {Map ILs fun {$ IL} {Check1 IL Tn} end}
	 in
	    elem(tag: disj
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% concatenation
	 [] elem(tag: concat
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    ILs1 =
	    {Map ILs fun {$ IL} {Check1 IL Tn} end}
	 in
	    elem(tag: concat
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% order
	 [] elem(tag: order
		 args: ILs ...) then
	    {CheckType Type IL}
	    %%
	    TagA = Type.tag
	    if {Not TagA=='type.set' orelse TagA=='type.iset'} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: order expression has type assumption '#TagA#' but must either be type.set or type.iset' info:o(IL Type 'order') coord:Coord file:File) end
	    end
	    Tn1 = Type.arg
	    Type1 = {Tn2Type Tn1 Coord File}
	    {CheckType Type1 IL}
	    TagA1 = Type1.tag
	    if {Not TagA1=='type.tuple'} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: domain of order expression has type assumption '#TagA1#'  but must be type.tuple.' info:o(IL Type Type1 'order') coord:Coord file:File) end
	    end
	    Types = Type1.args
	    TypesI = {Length Types}
	    if {Not TypesI==2} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: domain of order expression has '#TypesI#' projections but must have precisely two.' info:o(IL Type Type1 'order') coord:Coord file:File) end
	    end
	    if {Not Types.1=={Nth Types 2}} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: domain of order expression has two different projection types but they must be the same.' info:o(IL Type Type1 'order') coord:Coord file:File) end
	    end
	    Tn2 = Types.1
	    %%
	    ILs1 = {Map ILs fun {$ IL} {Check1 IL Tn2} end}
	 in
	    elem(tag: order
		 args: ILs1
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% bounds
	 [] elem(tag: bounds
		 arg1: IL1
		 arg2: IL2 ...) then
	    {CheckType Type IL}
	    %%
	    TypeTagA = Type.tag
	    TagA#IL11#IL21 =
	    if TypeTagA=='type.set' orelse
	       TypeTagA=='type.iset' then
	       bounds#{Check1 IL1 Tn}#{Check1 IL2 Tn}
	    else
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: bounds has type assumption '#TypeTagA info:o(IL Type 'bounds') coord:Coord file:File) end
	    end
	 in
	    elem(tag: TagA
		 arg1: IL11
		 arg2: IL21
		 %%
		 tn: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% feature path
	 [] elem(tag: featurepath
		 root: RootA
		 dimension: VIL
		 dimension_idref: DIDA1
		 aspect: AspectA
		 fields: FieldCILs ...) then
	    case RootA
	    of '_' then skip
	    [] '^' then skip
	    else
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Root can only be _ or ^ (and not '#RootA#')' info:o(IL Type 'featurepath') coord:Coord file:File) end
	    end
	    %%
	    if {Not {HasFeature DIDADimensionILRec DIDA1}} then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Referring to undefined dimension ID: '#DIDA1 info:o(IL Type 'featurepath') coord:Coord file:File) end
	    end
	    %% get aspect type (Tn1)
	    DimensionIL = DIDADimensionILRec.DIDA1
	    Tn1 = DimensionIL.AspectA
	    %% get projected feature path type (starting with Tn1)
	    %% using the fields FieldCILs
	    Tn2 =
	    {FoldL FieldCILs
	     fun {$ AccTn FieldCIL}
		Coord1 = {CondSelect FieldCIL coord noCoord}
		File1 = {CondSelect FieldCIL file noFile}
		%%
		AccType = {Tn2Type AccTn Coord1 File1}
		FieldA1 = {Helpers.cIL2A FieldCIL}
		%%
		FieldA =
		if FieldA1==ql then
		   DimensionIL = DIDADimensionILRec.DIDA1
		   LabelTypeTn = DimensionIL.label
		   LabelType = {Tn2Type LabelTypeTn Coord File}
		   ArgsAs = LabelType.args
		   if ArgsAs==nil then
		      raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Referring to a label on a dimension where the label type is empty: '#DIDA1 info:o(LabelType 'featurepath') coord:Coord file:File) end
		   end
		in
		   ArgsAs.1
		else
		   FieldA1
		end
	     in
		case AccType
		of elem(tag: 'type.record'
			args: ATypeRec) then
		   if {Not {HasFeature ATypeRec FieldA}} then
		      raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record type arity (or map/valency domain) does not include field: '#FieldA info:o(AccType IL Type 'featurepath') coord:Coord1 file:File1) end
		   end
		   ATypeRec.FieldA
		else
		   TagA = Type.tag
		in 
		   raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: feature path has type assumption '#TagA#' (but should be type.record, type.vec or type.valency)' info:o(AccType IL Type 'featurepath') coord:Coord1 file:File1) end
		end
	     end Tn1}	    
	    %%
	    Type2 = {Tn2Type Tn2 Coord File}
	    {CheckType Type2 IL}
	    %%
	    {CheckAnnotation Tn Tn2 Coord File}
	 in
	    elem(tag: featurepath
		 root: RootA
		 dimension: VIL
		 dimension_idref: DIDA1
		 aspect: AspectA
		 fields: FieldCILs
		 %%
		 tn: Tn2
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% feature
	 [] IL1#IL2 then
	    {CheckType Type IL}
	    %%
	    Coord1 = {CondSelect IL1 coord Coord}
	    File1 = {CondSelect IL1 file File}
	    %%
	    CILs = {Helpers.collectCILs IL1}
	    %%
	    if CILs==nil then
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: feature has no field' info:o(IL Type 'feature') coord:Coord1 file:File1) end
	    end
	 in
	    case Type
	    of elem(tag: 'type.record'
		    args: ATnRec) then
	       ILILTups =
	       {Map CILs
		fun {$ CIL}
		   A = {Helpers.cIL2A CIL}
		   if {Not {HasFeature ATnRec A}} then
		      raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record type arity (or map/valency domain) does not contain field: '#A info:o(IL Type 'feature') coord:Coord1 file:File1) end
		   end
		   Tn2 = ATnRec.A
		   IL21 = {Check1 IL2 Tn2}
		in
		   CIL#IL21
		end}
	    in
	       if {Length ILILTups}==1 then
		  ILILTups.1
	       else
		  elem(tag: disj
		       args: ILILTups
		       %%
		       tn: Tn
		       %%
		       coord: Coord
		       file: File)
	       end
	       %% record syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +)
	    [] elem(tag: 'type.tuple'
		    args: Tns) then
	       if {Not {Length Tns}==2} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): tuple type has '#{Length Tns}#' projections instead of two.' info:o(IL Type 'feature') coord:Coord1 file:File1) end
	       end
	       Tn1 = Tns.1
	       Type1 = TnTypeDict.Tn1
	       Type1TagA = Type1.tag
	       if {Not Type1TagA=='type.domain'} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): first projection of tuple type has type '#Type1TagA#' instead of type.domain.' info:o(IL Type 'feature' Type1) coord:Coord1 file:File1) end
	       end
	       Tn2 = {Nth Tns 2}
	       Type2 = TnTypeDict.Tn2
	       Type2TagA = Type2.tag
	       if {Not Type2TagA=='type.domain'} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): second projection of tuple type has type '#Type2TagA#' instead of type.domain.' info:o(IL Type 'feature' Type2) coord:Coord1 file:File1) end
	       end
	       if {Not {Helpers.isSubset Type2.args ['!' '?' '*' '+']}} then
		  raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: record syntax support for sets of tuples modeling mappings from constants to cardinalities (!, ?, *, +): second projection of tuple type has domain type which is not a subset of {! ? * +}.' info:o(IL Type 'feature' Type2) coord:Coord1 file:File1) end
	       end
	       IL11 = {Check1 IL1 Tn1}
	       IL21 = {Check1 IL2 Tn2}
	    in
	       elem(tag: list
		    args: [IL11 IL21]
		    %%
		    tn: Tn
		    %%
		    coord: Coord
		    file: File)
	    else
	       TagA = Type.tag
	    in
	       raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Type error: feature (or wild card expression) has type assumption '#TagA info:o(IL Type 'feature') coord:Coord1 file:File1) end
	    end
	 else
	    raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Illformed IL expression.' info:o(IL Type 'feature') coord:Coord file:File) end
	 end
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% create mapping DIDA -> IL (needed for feature paths)
      DimensionILs = {CondSelect G dimensions nil}
      DIDADimensionILDict = {NewDictionary}
      for DimensionIL in DimensionILs do
	 DIDCIL = DimensionIL.id
	 DIDA = {Helpers.cIL2A DIDCIL}
	 if {Dictionary.member DIDADimensionILDict DIDA} then
	    Coord = {CondSelect DIDCIL coord noCoord}
	    File = {CondSelect DIDCIL file noFile}
	 in
	    raise error1('functor':'Compiler/TypeChecker.ozf' 'proc':'Check1' msg:'Duplicate dimension definition.' info:o(DimensionIL DIDA DimensionILs) coord:Coord file:File) end
	 end
      in
	 DIDADimensionILDict.DIDA := DimensionIL
      end
      DIDADimensionILRec = {Dictionary.toRecord o DIDADimensionILDict}
      %%
      AClassILTChDict = {NewDictionary}
      %%
      GTCh = {Check1 G noTn}
      %%
      AClassILTChRec = {Dictionary.toRecord o AClassILTChDict}
      %%
      TnTypeRec = {Dictionary.toRecord o TnTypeDict}
   in
      GTCh#AClassILTChRec#TnTypeRec
   end
end
