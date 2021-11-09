%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD(sup)
   Open(file)
   OS(unlink)
   Resolve(expand)
   URL(make resolve toString)
export
   CIL2A
   IIL2I
   A2CIL
   I2IIL
   VIL2A
   VIL2CIL
   
   CheckDuplicateElements
   CILXTups2AXRec
   VILXTups2AXRec

   CollectILs
   CollectCILs

   X2V
   X2A

   IsSubset
   Unique
   
   ExpandUrlV
   ChangeSuffix
   GetSuffix
   V2PortI
   Dup
   Mv
   
   PutV

   Clean

   GetPaths
   CheckPath
prepare
   ListLast = List.last
   ListTake = List.take
   RecordMap = Record.map
define
   V2S = VirtualString.toString
   S2I = String.toInt
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into the corresponding atom A.
   fun {CIL2A CIL} CIL.data end
   %% IIL2I: IIL -> I
   %% Transforms an IL integer IIL into the corresponding integer I.
   fun {IIL2I IIL}
      I = IIL.data
      I1 = if I==infty then FD.sup else I end
   in
      I1
   end
   %% A2CIL: A -> CIL
   %% Transforms an atom into the corresponding IL constant CIL.
   fun {A2CIL A}
      elem(tag: constant
	   data: A)
   end
   %% I2IIL: I -> IIL
   %% Transforms an integer into the corresponding IL integer IIL.
   fun {I2IIL I}
      I1 = if I==FD.sup then infty else I end
   in
      elem(tag: integer
	   data: I1)
   end
   %% VIL2A: VIL -> A
   %% Transforms an IL variable VIL into the corresponding atom A.
   fun {VIL2A VIL} VIL.data end
   %% VIL2CIL: VIL -> CIL
   %% Transforms an IL variable VIL into the corresponding IL constant CIL.
   fun {VIL2CIL VIL}
      {Adjoin VIL elem(tag: constant)}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CheckDuplicateElements: Xs Coord File -> U
   %% Checks a list Xs for duplicate elements,
   %% and raises an exception if there is one.
   %% Coord is a coordinate, File a file.
   proc {CheckDuplicateElements Xs Coord File}
      _ =
      {FoldL Xs
       fun {$ AccX X}
	  if {Member X AccX} then
	     MsgV = 'Duplicate element'#
	     if {IsAtom X} orelse {IsInt X} then ': '#X else '' end
	  in
	     raise error1('functor':'Compiler/Helpers.ozf' 'proc':'CheckDuplicateElements' msg:MsgV info:o(X Xs) coord:Coord file:File) end
	  else
	     X|AccX
	  end
       end nil}
   end
   %% CILXTups2AXRec: CILXTups -> AXRec
   %% Transforms a list of features CIL#X into a record with features A:X
   %% (where A = {CIL2A CIL}).
   fun {CILXTups2AXRec CILXTups}
      AXDict = {NewDictionary}
      for CIL#X in CILXTups do
	 A = {CIL2A CIL}
	 if {Dictionary.member AXDict A} then
	    Coord = {CondSelect CIL coord noCoord}
	    File = {CondSelect CIL file noFile}
	 in
	    raise error1('functor':'Compiler/Helpers.ozf' 'proc':'CILXTups2AXRec' msg:'Duplicate field.' info:o(CIL A CILXTups) coord:Coord file:File) end
	 end
      in
	 AXDict.A := X
      end
      AXRec = {Dictionary.toRecord o AXDict}
   in
      AXRec
   end
   %% VILXTups2AXRec: VILXTups -> AXRec
   %% Transforms a list of features VIL#X into a record with features A:X
   %% (where A = {VIL2A VIL}).
   fun {VILXTups2AXRec VILXTups}
      AXDict = {NewDictionary}
      for VIL#X in VILXTups do
	 A = {VIL2A VIL}
	 if {Dictionary.member AXDict A} then
	    Coord = {CondSelect VIL coord noCoord}
	    File = {CondSelect VIL file noFile}
	 in
	    raise error1('functor':'Compiler/Helpers.ozf' 'proc':'VILXTups2AXRec' msg:'Duplicate field.' info:o(VIL A VILXTups) coord:Coord file:File) end
	 end
      in
	 AXDict.A := X
      end
      AXRec = {Dictionary.toRecord o AXDict}
   in
      AXRec
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CollectILs: IL -> ILs
   %% Collects all subordinate IL expressions in an IL expression with
   %% con/disjunction
   fun {CollectILs IL}
      case IL
      of elem(tag: conj
	      args: ILs ...) then
	 {FoldL ILs
	  fun {$ AccILs IL}
	     ILs1 = {CollectILs IL}
	  in
	     {Append ILs1 AccILs}
	  end nil}
      [] elem(tag: disj
	      args: ILs ...) then
	 {FoldL ILs
	  fun {$ AccILs IL}
	     ILs1 = {CollectILs IL}
	  in
	     {Append ILs1 AccILs}
	  end nil}
      else
	 [IL]
      end
   end
   %% CollectCILs: IL -> CILs
   %% Collects all IL constants CILs in IL. IL may contain only
   %% constants or disjunctions of constants.
   fun {CollectCILs IL}
      case IL
      of elem(tag: constant ...) then
	 [IL]
      [] elem(tag: disj
	      args: ILs ...) then
	 {FoldL ILs
	  fun {$ AccCILs IL}
	     CILs = {CollectCILs IL}
	  in
	     {Append CILs AccCILs}
	  end nil}
      else
	 TagA = IL.tag
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
      in
	 raise error1('functor':'Compiler/Helpers.ozf' 'proc':'CollectCILs' msg:'Error collecting constants: constant or disjunction expected, got: '#TagA info:o(IL) coord:Coord file:File) end
      end
   end
   %% X2V: X -> V
   %% Transforms value X into a virtual string V.
   fun {X2V X}
      V = {Value.toVirtualString X 10000 10000}
   in
      V
   end
   %% X2A: X -> A
   %% Transforms a value X into an atom A.
   V2A = VirtualString.toAtom
   %%
   fun {X2A X}
      V = {X2V X}
      A = {V2A V}
   in
      A
   end
   %% IsSubset: Xs Ys -> B
   %% Returns true if Xs denotes a subset of Ys, and false if not.
   fun {IsSubset Xs Ys}
      {All Xs
       fun {$ X} {Member X Ys} end}
   end
   %% Unique: X Xs -> B
   %% Given that X is a member of Xs, checks whether X is unique in Xs,
   %% i.e., does not occur more than once.
   fun {Unique X Xs}
      case Xs
      of nil then true
      [] Y|Ys then
	 if X==Y then
	    {Not {Member X Ys}}
	 else
	    {Unique X Ys}
	 end
      end
   end
   %% ExpandUrlV: UrlV -> S
   %% Expands Url V relative to the current directory.
   fun {ExpandUrlV UrlV}
      {URL.toString {Resolve.expand {URL.resolve './' UrlV}}}
   end
   %% AllButLast: Xs -> Ys
   %% Takes all but the last element of a list Xs.
   fun {AllButLast Xs} {ListTake Xs {Length Xs}-1} end
   %% ChangeSuffix: V1 V2 -> S
   %% Changes the suffix of filename V1 to V2, and returns the changed string S.
   %% E.g. {ChangeSuffix "bla.ozf" "txt"} -> "bla.txt".
   fun {ChangeSuffix V1 V2}
      S1 = {V2S V1}
      S2 = {V2S V2}
      Ss = {String.tokens S1 &.}
      Ss1 = {AllButLast Ss}
      S3 =
      {FoldR Ss1
       fun {$ S AccS} {Append S &.|AccS} end nil}
      S4 = {Append S3 S2}
   in
      S4
   end
   %% GetSuffix: V -> S
   %% Gets the suffix of a filename.
   fun {GetSuffix V}
      S = {V2S V}
      Ss = {String.tokens S &.}
      S1 = {ListLast Ss}
   in
      S1
   end
   %% V2PortI: V -> PortI
   %% Get port PortI from virtual string V, e.g. 4711 from
   %% "4711.xmlsocket".
   fun {V2PortI V}
      %% get string S
      S = {V2S V}
      %% get string S1 before suffix .socket
      Ss = {String.tokens S &.}
      PortS = Ss.1
      PortI = {S2I PortS}
   in
      PortI
   end
   %% Dup: V1 V2 -> U
   %% Duplicates file with URL UrlV1 as file with URL UrlV2.
   proc {Dup UrlV1 UrlV2}
      S1 = {V2S UrlV1}
      S2 = {V2S UrlV2}
      if S1==S2 then
	 raise error1('functor':'Compiler/Helpers.ozf' 'proc':'Cp' msg:'"'#S1#'" and "'#S2#'" are the same file.' info:o(S1 S2) coord:noCoord file:noFile) end
      end
      FileO1 = {New Open.file init(name: S1)}
      DataS1 = {FileO1 read(list: $
			   size: all)}
      {FileO1 close}
      FileO2 = {New Open.file init(name: S2
				  flags: [create truncate write])}
   in
      {FileO2 write(vs: DataS1)}
      {FileO2 close}
   end
   %% Mv: UrlV1 UrlV2 -> U
   %% Moves file with URL UrlV1 to file with URL UrlV2.
   proc {Mv UrlV1 UrlV2}
      {Dup UrlV1 UrlV2}
      {OS.unlink UrlV1}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% PutV: V UrlV -> U
   %% Writes the virtual string V into a file with URL UrlV.
   proc {PutV V UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [create truncate write text])}
   in
      {FileO write(vs: V)}
      {FileO close}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Clean: IL -> IL1
   %% Remove any additional features (e.g. coord, file) from an IL expression
   %% and all its sub-expressions.
   fun {Clean IL}
      Coord = {CondSelect IL coord noCoord}
      File = {CondSelect IL file noFile}
   in
      case IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% grammar
      of elem(tag: grammar ...) then
	 PrinciplesILs = {CondSelect IL principles nil}
	 PrinciplesILs1 = {Map PrinciplesILs Clean}
	 %%
	 OutputsILs = {CondSelect IL outputs nil}
	 OutputsILs1 = {Map OutputsILs Clean}
	 %%
	 UsedimensionsILs = {CondSelect IL usedimensions nil}
	 UsedimensionsILs1 = {Map UsedimensionsILs Clean}
	 %%
	 DimensionsILs = {CondSelect IL dimensions nil}
	 DimensionsILs1 = {Map DimensionsILs Clean}
	 %%
	 ClassesILs = {CondSelect IL classes nil}
	 ClassesILs1 = {Map ClassesILs Clean}
	 %%
	 EntriesILs = {CondSelect IL entries nil}
	 EntriesILs1 = {Map EntriesILs Clean}
	 %%
	 IL1 = elem(tag: grammar
		    principles: PrinciplesILs1
		    outputs: OutputsILs1
		    usedimensions: UsedimensionsILs1
		    dimensions: DimensionsILs1
		    classes: ClassesILs1
		    entries: EntriesILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% principledef
      [] elem(tag: principledef
	      id: IDCIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 DimensionsILs = {CondSelect IL dimensions nil}
	 DimensionsILs1 = {Map DimensionsILs Clean}
	 %%
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 DefaultsILs = {CondSelect IL defaults nil}
	 DefaultsILs1 = {Map DefaultsILs Clean}
	 %%
	 ModelIL = {CondSelect IL model elem(tag: 'type.record'
					     args: nil)}
	 ModelIL1 = {Clean ModelIL}
	 %%
	 IL1 =  elem(tag: principledef
		     id: IDCIL1
		     dimensions: DimensionsILs1
		     args: ArgsILs1
		     defaults: DefaultsILs1
		     model: ModelIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dimension
      [] elem(tag: dimension
	      id: IDCIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 AttrsIL = {CondSelect IL attrs elem(tag: 'type.record'
					     args: nil)}
	 AttrsIL1 = {Clean AttrsIL}
	 %%
	 EntryIL = {CondSelect IL entry elem(tag: 'type.record'
					     args: nil)}
	 EntryIL1 = {Clean EntryIL}
	 %%
	 LabelIL = {CondSelect IL label elem(tag: 'type.domain'
					     args: nil)}
	 LabelIL1 = {Clean LabelIL}
	 %%
	 TypesILs = {CondSelect IL types nil}
	 TypesILs1 = {Map TypesILs Clean}
	 %%
	 PrinciplesILs = {CondSelect IL principles nil}
	 PrinciplesILs1 = {Map PrinciplesILs Clean}
	 %%
	 OutputsILs = {CondSelect IL outputs nil}
	 OutputsILs1 = {Map OutputsILs Clean}
	 %%
	 UseoutputsILs = {CondSelect IL useoutputs nil}
	 UseoutputsILs1 = {Map UseoutputsILs Clean}
	 %%
	 IL1 = elem(tag: dimension
		    id: IDCIL1
		    attrs: AttrsIL1
		    entry: EntryIL1
		    label: LabelIL1
		    types: TypesILs1
		    principles: PrinciplesILs1
		    outputs: OutputsILs1
		    useoutputs: UseoutputsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typedef
      [] elem(tag: typedef
	      id: IDCIL
	      type: TypeIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 TypeIL1 = {Clean TypeIL}
	 %%
	 IL1 = elem(tag: typedef
		    id: IDCIL1
		    type: TypeIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.domain
      [] elem(tag: 'type.domain' ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: 'type.domain'
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.set
      [] elem(tag: 'type.set'
	      arg: TypeIL ...) then
	 TypeIL1 = {Clean TypeIL}
	 %%
	 IL1 = elem(tag: 'type.set'
		    arg: TypeIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.iset
      [] elem(tag: 'type.iset'
	      arg: TypeIL ...) then
	 TypeIL1 = {Clean TypeIL}
	 %%
	 IL1 = elem(tag: 'type.iset'
		    arg: TypeIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.tuple
      [] elem(tag: 'type.tuple' ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: 'type.tuple'
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.list
      [] elem(tag: 'type.list'
	      arg: TypeIL ...) then
	 TypeIL1 = {Clean TypeIL}
	 %%
	 IL1 = elem(tag: 'type.list'
		    arg: TypeIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.record
      [] elem(tag: 'type.record' ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: 'type.record'
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.valency
      [] elem(tag: 'type.valency'
	      arg: TypeIL ...) then
	 TypeIL1 = {Clean TypeIL}
	 %%
	 IL1 = elem(tag: 'type.valency'
		    arg: TypeIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.card
      [] elem(tag: 'type.card' ...) then
	 IL1 = elem(tag: 'type.card')
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.vec
      [] elem(tag: 'type.vec'
	      arg1: TypeIL1
	      arg2: TypeIL2 ...) then
	 TypeIL11 = {Clean TypeIL1}
	 TypeIL21 = {Clean TypeIL2}
	 %%
	 IL1 = elem(tag: 'type.vec'
		    arg1: TypeIL11
		    arg2: TypeIL21)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.int
      [] elem(tag: 'type.int' ...) then
	 IL1 = elem(tag: 'type.int')
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.ints
      [] elem(tag: 'type.ints' ...) then
	 IL1 = elem(tag: 'type.ints')
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.string
      [] elem(tag: 'type.string' ...) then
	 IL1 = elem(tag: 'type.string')
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.bool
      [] elem(tag: 'type.bool' ...) then
	 IL1 = elem(tag: 'type.bool')
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.ref
      [] elem(tag: 'type.ref'
	      idref: IDCIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 IL1 = elem(tag: 'type.ref'
		    idref: IDCIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.labelref
      [] elem(tag: 'type.labelref'
	      arg: CIL ...) then
	 CIL1 = {Clean CIL}
	 %%
	 IL1 = elem(tag: 'type.labelref'
		    arg: CIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type.variable
      [] elem(tag: 'type.variable'
	      data: A ...) then
	 IL1 = elem(tag: 'type.variable'
		    data: A)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constant
      [] elem(tag: constant
	      data: A ...) then
	 IL1 = elem(tag: constant
		    data: A)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useprinciple
      [] elem(tag: useprinciple
	      idref: IDCIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 DimensionsILs = {CondSelect IL dimensions nil}
	 DimensionsILs1 = {Map DimensionsILs Clean}
	 %%
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: useprinciple
		    idref: IDCIL1
		    dimensions: DimensionsILs1
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% classdef
      [] elem(tag: classdef
	      id: IDCIL
	      body: BodyIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 VarsILs = {CondSelect IL vars nil}
	 VarsILs1 = {Map VarsILs Clean}
	 %%
	 BodyIL1 = {Clean BodyIL}
	 %%
	 IL1 = elem(tag: classdef
		    id: IDCIL1
		    vars: VarsILs1
		    body: BodyIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% variable
      [] elem(tag: variable
	      data: A ...) then
	 IL1 = elem(tag: variable
		    data: A)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% class.dimension
      [] elem(tag: 'class.dimension'
	      idref: IDCIL
	      arg: ArgIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 ArgIL1 = {Clean ArgIL}
	 %%
	 IL1 = elem(tag: 'class.dimension'
		    idref: IDCIL1
		    arg: ArgIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% class.ref
      [] elem(tag: 'class.ref'
	      idref: IDCIL ...) then
	 IDCIL1 = {Clean IDCIL}
	 %%
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: 'class.ref'
		    idref: IDCIL1
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% conj
      [] elem(tag: conj ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: conj
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% disj
      [] elem(tag: disj ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: disj
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% concat
      [] elem(tag: concat ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: concat
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% order
      [] elem(tag: order ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: order
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% entry
      [] elem(tag: entry
	      body: BodyIL ...) then
	 BodyIL1 = {Clean BodyIL}
	 %%
	 IL1 = elem(tag: entry
		    body: BodyIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% set
      [] elem(tag: set ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: set
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% list
      [] elem(tag: list ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: list
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% record
      [] elem(tag: record ...) then
	 ArgsILs = {CondSelect IL args nil}
	 ArgsILs1 = {Map ArgsILs Clean}
	 %%
	 IL1 = elem(tag: record
		    args: ArgsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% setgen
      [] elem(tag: setgen
	      arg: ArgIL ...) then
	 ArgIL1 = {Clean ArgIL}
	 %%
	 IL1 = elem(tag: setgen
		    arg: ArgIL1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% featurepath
      [] elem(tag: featurepath
	      root: RootA
	      dimension: VIL
	      aspect: AspectA ...) then
	 VIL1 = {Clean VIL}
	 %%
	 FieldsILs = {CondSelect IL fields nil}
	 FieldsILs1 = {Map FieldsILs Clean}
	 %%
	 IL1 = elem(tag: featurepath
		    root: RootA
		    dimension: VIL1
		    aspect: AspectA
		    fields: FieldsILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% annotation
      [] elem(tag: annotation
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgIL11 = {Clean ArgIL1}
	 ArgIL21 = {Clean ArgIL2}
	 %%
	 IL1 = elem(tag: annotation
		    arg1: ArgIL11
		    arg2: ArgIL21)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% integer
      [] elem(tag: integer
	      data: I ...) then
	 IL1 = elem(tag: integer
		    data: I)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% top/bot
      [] elem(tag: top ...) then
	 IL1 = elem(tag: top)
      in
	 IL1
      [] elem(tag: bot ...) then
	 IL1 = elem(tag: bot)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% card.wild
      [] elem(tag: 'card.wild'
	      arg: A ...) then
	 IL1 = elem(tag: 'card.wild'
		    arg: A)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% card.set
      [] elem(tag: 'card.set' ...) then
	 ILs = {CondSelect IL args nil}
	 ILs1 = {Map ILs Clean}
	 %%
	 IL1 = elem(tag: 'card.set'
		    args: ILs1)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% card.interval
      [] elem(tag: 'card.interval'
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgIL11 = {Clean ArgIL1}
	 ArgIL21 = {Clean ArgIL2}
	 %%
	 IL1 = elem(tag: 'card.interval'
		    arg1: ArgIL11
		    arg2: ArgIL21)
      in
	 IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% pair
      [] IL1#IL2 then
	 IL11 = {Clean IL1}
	 IL21 = {Clean IL2}
      in
	 IL11#IL21
      else
	 raise error1('functor':'Compiler/Helpers.ozf' 'proc':'Clean' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
      end
   end
   %% GetPaths: Lat -> Paths
   %% Gets a list of lists of paths to values in lattice Lat which could
   %% possibly be undefined.
   fun {GetPaths Lat}
      Rec = {Lat2Rec Lat}
   in
      {GetPaths1 Rec nil}
   end
   fun {GetPaths1 X AccLIs}
      case X
      of '<list>'(Y) then
	 {GetPaths1 Y {Append AccLIs ['<list>']}}
      [] '<set>'(Y) then
	 {GetPaths1 Y {Append AccLIs ['<set>']}}
      elseif {IsList X} then	 
	 for I in 1..{Length X} append:Append1 do
	    Y = {Nth X I}
	    LIss = {GetPaths1 Y {Append AccLIs [I]}}
	 in
	    {Append1 LIss}
	 end
      elseif {IsRecord X} andthen {Not {Arity X}==nil} then
	 As = {Arity X}
      in
	 for A in As append:Append1 do
	    Y = X.A
	    LIss = {GetPaths1 Y {Append AccLIs [A]}}
	 in
	    {Append1 LIss}
	 end
      else
	 if X=='<undef>' then [AccLIs] else nil end
      end
   end
   fun {Lat2Rec Lat}
      case Lat.tag
      of card then
	 '<def>'   % top value defined ({0})
      [] domain then
	 '<undef>' % top value undefined
      [] domainSet then
	 '<def>'   % top value defined ({} or full set)
      [] domainTuple then
	 '<undef>' % top value undefined
      [] domainTupleSet then
	 '<def>'   % top value defined ({} or full set)
      [] flat then
	 '<undef>' % top value undefined
      [] int then
	 '<undef>' % top value undefined
      [] intSet then
	 '<def>'   % top value defined ({} or full set)
      [] list then
	 '<list>'({Lat2Rec Lat.domain}) % top value of the domain defined?
      [] record then
	 {RecordMap Lat.record Lat2Rec} % top value of all features defined?
      [] set then
	 '<set>'({Lat2Rec Lat.domain})  % top value of the domain defined?
      [] string then
	 '<undef>'   % top value undefined
      [] tuple then
	 {Map Lat.domains Lat2Rec} % top value of all projections defined?
      end
   end
   %% CheckPath: SL Path -> B
   %% Returns true if solver language expression SL contains no
   %% undefined values, and false otherwise.
   fun {CheckPath SL Path}
      case SL
      of featurepath(...) then
	 true
      [] 'flat_top' then
	 false
      [] 'flat_bot' then
	 false
      else
	 case Path
	 of nil then
	    true
	 [] LI|LIs then
	    case LI
	    of '<list>' then
	       {All SL
		fun {$ SL1} {CheckPath SL1 LIs} end}
	    [] '<set>' then
	       {All SL
		fun {$ SL1} {CheckPath SL1 LIs} end}
	    elseif {IsInt LI} then
	       {CheckPath {Nth SL LI} LIs}
	    else
	       {CheckPath SL.LI LIs}
	    end
	 end
      end
   end
end
