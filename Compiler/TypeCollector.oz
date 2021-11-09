%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)

   Inspector(inspect)

   System(showError)
   
   Helpers(a2CIL cIL2A vIL2CIL vIL2A
	   cILXTups2AXRec vILXTups2AXRec
	   checkDuplicateElements
	   x2A clean iIL2I) at 'Helpers.ozf'
export
   CollectTypes
prepare
   ListToRecord = List.toRecord
   RecordForAllInd = Record.forAllInd
   RecordMap = Record.map
define
   %% CollectTypes: G DebugB PrintProc -> GTCo#TnTypeDict#AClassILRec#Entry1Tn#NodeTn
   %% 1) converts G into GTCo,
   %% 2) collects all types in G in a dictionary TnTypeDict with
   %% features Tn#Type, where Tn is a unique type name for type Type,
   %% and
   %% 3) collects all uses of classes in G in a record AClassILRec
   %% with features A#ClassIL, where A is a unique atom corresponding
   %% to the use of a class with certain arguments.
   %% 4) creates Entry1Tn, the type name for the combined entry type
   %% of all dimensions
   %% 5) creates NodeTn, the type name for the combined node record
   %% type of all dimensions
   %% Prints out debugging information is DebugB==true, and is quiet
   %% otherwise. Prints out progress information with procedure
   %% PrintProc.
   fun {CollectTypes G DebugB PrintProc}
      %% Enter: Type -> Tn
      %% Enters a type Type into the type dictionary TnTypeDict, and
      %% returns its type name Tn
      fun {Enter Type}
	 TnTypeTups = {Dictionary.entries TnTypeDict}
	 EqualTypes =
	 {Filter TnTypeTups
	  fun {$ _#Type1}
	     if {IsDet Type} andthen {IsDet Type1} then
		Type1==Type
	     else
		false
	     end
	  end}
      in
	 if EqualTypes==nil then
	    Tn = {NewName}
	 in
	    TnTypeDict.Tn := Type
	    Tn
	 else
	    Tn#_ = EqualTypes.1
	 in
	    Tn
	 end
      end
      %% CILCILTups2DVADIDARec: CILCILTups -> DVADIDARec
      %% Transforms a list CILCILTups of tuples CIL#CIL into a
      %% record DVADIDARec of features A:DIDA
      %% (where A = {Helpers.vIL2A CIL}, DIDA = {Helpers.cIL2A CIL}).
      fun {CILCILTups2DVADIDARec CILCILTups}
	 ACILRec = {Helpers.cILXTups2AXRec CILCILTups}
	 DVADIDARec =
	 {RecordMap ACILRec
	  fun {$ CIL}
	     DIDA = {Helpers.cIL2A CIL}
	  in
	     if {Not {HasFeature DIDADimensionILRec DIDA}} then
		Coord = {CondSelect CIL coord noCoord}
		File = {CondSelect CIL file noFile}
	     in
		raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CILDIDATups2DVADIDARec' msg:'Referring to undefined dimension ID: '#DIDA info:o(CILCILTups ACILRec) coord:Coord file:File) end
	     end
	     DIDA
	  end}
      in
	 DVADIDARec
      end
      %% Tn2Type: Tn Coord File -> Type
      %% Uses type name Tn to get type Type.
      fun {Tn2Type Tn Coord File}
	 if {Not {HasFeature TnTypeDict Tn}} then
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'Tn2Type' msg:'Type dictionary does not contain key.' info:o(Tn) coord:Coord file:File) end
	 end
	 TnTypeDict.Tn
      end
      %%
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% CollectTypes1: IL DVADIDARec AILRec CIDA DIDA Pn -> ILTCo
      %% Converts the IL expression IL into ILTCo.
      %% DVADIDARec: A -> DIDA, where A is a dimension variable and DIDA
      %%             a dimension ID (to resolve "type.labelref"s)
      %% AILRec: A -> IL, where A is a variable name and IL an IL
      %%         expression (to resolve "class.ref"s with arguments)
      %% CIDA: the class ID of the currently defined class or noCIDA
      %%       (to detect cycles in class definitions)
      %% DIDA: the dimension ID of the currently defined dimension or
      %%       noDIDA (to resolve dimension variable "This")
      %% Pn: the unique name of the current principle use if
      %%     processing the argument type definitions of a principle,
      %%     and noPn otherwise (to distinguish type variables)
      %%
      %% Changes from IL to ILTCo:
      %% * for all types in IL (also in annotations):
      %%   - convert TypeIL into Type:
      %%     - resolve all type references
      %%     - resolve all label type references
      %%     - domain types: convert all CILs in the args to As
      %%     - record types: convert CILILTups in the args to an AILRec
      %%     - resolve all type abbreviations:
      %%       - bool => {false true}
      %%       - valency(t) => vec(t card)
      %%       - vec({c1,...,cn} t) => {c1:t,...cn:t}
      %%       - ints => set(int)
      %%     - type variables: distinguish them by the unique name of
      %%       the principle in whose argument type they appear
      %%   - add Type at key Tn in TnTypeDict (where Tn is a unique
      %%   type name for Type)
      %%   - replace TypeIL by Tn in ILTCo
      %% * dimension
      %%   - outputs:
      %%     - replace choosen outputs (outputs) by the corresponding
      %%     output definition
      %%     - replace used outputs (useoutputs) by the corresponding
      %%     output definition
      %% * useprinciple
      %%   - create unique principle name Pn
      %%   - update the DVADIDARec
      %%   - for each missing arg, insert the default value from the
      %%   principle definition
      %%   - replace the args by a IL record of them, annotated by the types
      %%   given in the principle definition
      %%   - add model type from principle definition (modelTn)
      %%   - add constraints from principle definition (constraints)
      %%   - add dimension on which they are used (dIDA)
      %% * class.dimension
      %%   - replace by a tuple CIL#IL1, where CIL represents the
      %%   dimension idref, and IL1 = {CollectTypes1 IL DVADIDARec
      %%   AILRec CIDA DIDA Pn} (where IL is the body of the
      %%   class.dimension expression)
      %% * class.ref
      %%   - resolve all class references, generate a unique key A for
      %%   each different class use, and add this class use under key
      %%   to AClassILDict under this key.
      %% * entry
      %%   - replace by a (correctly annotated) IL record of the body
      %% * featurepath
      %%   - add feature "dimension_idref" whose value is the
      %%   dereferenced dimension variable on the "dimension" field
      %% * concatenation
      %%   - annotate with 'type.string' (only those can be
      %%   concatenated)
      %%
      %% Makes use of the following dictionaries:
      %%   * TnTypeDict: Tn -> TypeILTCo (for collected types)
      %%   * AClassILDict: A -> ClassILTCo (for collected used classes)
      %%   * ATnDict: A -> Tn to optimize "type.ref"s
      %%   * ATnDict1: A -> Tn to optimize "type.labelref"s
      %%
      %% Makes use of the following records:
      %%   * PIDAPrincipleILRec: PIDA -> PrincipleIL, where PIDA is a
      %%   principle ID and PrincipleIL is a principle definition IL expression
      %%   (to resolve "principle"s),
      %%   * OIDAOutputILRec: OIDA -> OutputIL, where OIDA is an
      %%   output ID and OutputIL is an output definition IL expression
      %%   (to resolve "output"s),
      %%   * DIDADimensionILRec: DIDA -> DimensionIL, where DIDA is a
      %%   dimension ID and DimensionIL is a dimension IL expression,
      %%   * TIDATypeILRec: TIDA -> TypeIL, where TIDA is a type ID
      %%   and TypeIL is an IL type expression (to resolve
      %%   "type.ref"s), and
      %%   * CIDAClassILRec: CIDA -> ClassIL, where CIDA is a class ID
      %%   and ClassIL is an IL class expression (to resolve all
      %%   "class.ref"s).
      fun {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
      in
	 case IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% grammar
	 of elem(tag: grammar ...) then
	    PrincipleILs = {CondSelect IL principles nil}
	    OutputILs = {CondSelect IL outputs nil}
	    DimensionILs = {CondSelect IL dimensions nil}
	    ClassILs = {CondSelect IL classes nil}
	    EntryILs = {CondSelect IL entries nil}
	    DIDCILs = {CondSelect IL usedimensions nil}
	    %% convert DimensionILs
	    DimensionILs1 =
	    {Map DimensionILs
	     fun {$ DimensionIL}
		{CollectTypes1 DimensionIL DVADIDARec AILRec CIDA DIDA Pn}
	     end}    
	    %% convert EntryILs
	    EntryILs1 =
	    {Map EntryILs
	     fun {$ EntryIL}
		{CollectTypes1 EntryIL DVADIDARec AILRec CIDA DIDA Pn}
	     end}
	    %%
	    for DIDCIL in DIDCILs do
	       DIDA1 = {Helpers.cIL2A DIDCIL}
	    in
	       if {Not {HasFeature DIDADimensionILRec DIDA1}} then
		  Coord1 = {CondSelect DIDCIL coord Coord}
		  File1 = {CondSelect DIDCIL file File}
	       in
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined dimension ID: '#DIDA1 info:o('grammar') coord:Coord1 file:File1) end
	       end
	    end
	 in
	    elem(tag: grammar
		 principles: PrincipleILs
		 outputs: OutputILs
		 dimensions: DimensionILs1
		 usedimensions: DIDCILs
		 classes: ClassILs
		 entries: EntryILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% dimension
	 [] elem(tag: dimension
		 id: DIDCIL ...) then
	    DIDA1 = {Helpers.cIL2A DIDCIL}
	    AttrsTypeIL = {CondSelect IL attrs
			   elem(tag: 'type.record'
				args: nil)}
	    EntryTypeIL = {CondSelect IL entry
			   elem(tag: 'type.record'
				args: nil)}
	    LabelTypeIL = {CondSelect IL label
			   elem(tag: 'type.domain'
				args: nil)}
	    %% get attrs type name
	    AttrsCoord = {CondSelect AttrsTypeIL coord Coord}
	    AttrsFile = {CondSelect AttrsTypeIL file File}
	    AttrsTn = {CollectTypes1 AttrsTypeIL DVADIDARec AILRec CIDA DIDA1 Pn}
	    AttrsType = {Tn2Type AttrsTn Coord File}
	    case AttrsType
	    of elem(tag: 'type.record' ...) then skip
	    else
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Attributes type must be a record.' info:o(AttrsType 'dimension') coord:AttrsCoord file:AttrsFile) end
	    end
	    %% get entry type name
	    EntryCoord = {CondSelect EntryTypeIL coord Coord}
	    EntryFile = {CondSelect EntryTypeIL file File}
	    EntryTn = {CollectTypes1 EntryTypeIL DVADIDARec AILRec CIDA DIDA1 Pn}
	    EntryType = {Tn2Type EntryTn Coord File}
	    if {Not EntryType.tag=='type.record'} then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Entry type must be a record.' info:o(EntryType 'dimension') coord:EntryCoord file:EntryFile) end
	    end
	    %% get label type name
	    LabelCoord = {CondSelect LabelTypeIL coord Coord}
	    LabelFile = {CondSelect LabelTypeIL file File}
	    LabelTn = {CollectTypes1 LabelTypeIL DVADIDARec AILRec CIDA DIDA1 Pn}
	    LabelType = {Tn2Type LabelTn Coord File}
	    if {Not LabelType.tag=='type.domain'} then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Label type must be a domain.' info:o(LabelType 'dimension') coord:LabelCoord file:LabelFile) end
	    end
	    %%
	    TypeILs = {CondSelect IL types nil}
	    PrincipleILs = {CondSelect IL principles nil}
	    OutputILs = {CondSelect IL outputs nil}
	    UseOutputILs = {CondSelect IL useoutputs nil}
	    %% collect types in type definitions
	    TypeILs1 =
	    {Map TypeILs
	     fun {$ TypeIL}
		{CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA1 Pn}
	     end}
	    %% collect used principles and add the dimension they are used on
	    PrincipleILs1 =
	    {Map PrincipleILs
	     fun {$ PrincipleIL}
		PrincipleIL1 =
		{CollectTypes1 PrincipleIL DVADIDARec AILRec CIDA DIDA1 Pn}
	     in
		{Adjoin PrincipleIL1 elem(dIDA: DIDA1)}
	     end}
	    %% replace choosen outputs by the corresponding output
	    %% definition
	    OutputILs1 =
	    {Map OutputILs
	     fun {$ OutputIL}
		OIDCIL = OutputIL.idref
		OIDA = {Helpers.cIL2A OIDCIL}
		%%
		if {Not {HasFeature OIDAOutputILRec OIDA}} then
		   Coord = {CondSelect OutputIL coord noCoord}
		   File = {CondSelect OutputIL file noFile}
		in
		   raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined output ID: '#OIDA info:o('dimension') coord:Coord file:File) end
		end
		%%
		OutputIL1 = OIDAOutputILRec.OIDA
	     in
		OutputIL1
	     end}
	    %% replace used outputs by the corresponding output definition
	    UseOutputILs1 =
	    {Map UseOutputILs
	     fun {$ UseOutputIL}
		OIDCIL = UseOutputIL.idref
		OIDA = {Helpers.cIL2A OIDCIL}
		%%
		if {Not {HasFeature OIDAOutputILRec OIDA}} then
		   Coord = {CondSelect UseOutputIL coord noCoord}
		   File = {CondSelect UseOutputIL file noFile}
		in
		   raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined output ID: '#OIDA info:o('dimension') coord:Coord file:File) end
		end
		%%
		UseOutputIL1 = OIDAOutputILRec.OIDA
		%%
		if {Not {Member UseOutputIL1 OutputILs1}} then
		   Coord = {CondSelect UseOutputIL coord noCoord}
		   File = {CondSelect UseOutputIL file noFile}
		in
		   raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Using output ID which has not been chosen: '#OIDA info:o('dimension') coord:Coord file:File) end
		end
	     in
		UseOutputIL1
	     end}
	 in
	    elem(tag: dimension
		 id: DIDCIL
		 attrs: AttrsTn
		 entry: EntryTn
		 label: LabelTn
		 types: TypeILs1
		 principles: PrincipleILs1
		 outputs: OutputILs1
		 useoutputs: UseOutputILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% classdef
	 [] elem(tag: classdef
		 id: CIDCIL
		 body: BodyIL ...) then
	    VarILs = {CondSelect IL vars nil}
	    BodyIL1 = {CollectTypes1 BodyIL DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    elem(tag: classdef
		 id: CIDCIL
		 vars: VarILs
		 body: BodyIL1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% useprinciple
	 [] elem(tag: useprinciple
		 idref: PIDCIL ...) then
	    %% create unique name for the principle use
	    Pn1 = {NewName}
	    %%
	    VILCILTups = {CondSelect IL dimensions nil}
	    CILCILTups = {Map VILCILTups 
			  fun {$ VIL#CIL}
			     CIL1 = {Helpers.vIL2CIL VIL}
			  in
			     CIL1#CIL
			  end}
	    VILILTups = {CondSelect IL args nil}
	    CILILTups = {Map VILILTups
			 fun {$ VIL#IL}
			    CIL = {Helpers.vIL2CIL VIL}
			 in
			    CIL#IL
			 end}
	    %% create mapping DVADIDARec1
	    DVADIDARec1 = {CILCILTups2DVADIDARec CILCILTups}
	    %% get principle definition PrincipleIL
	    PIDA = {Helpers.cIL2A PIDCIL}
	    if {Not {HasFeature PIDAPrincipleILRec PIDA}} then
	       Coord1 = {CondSelect PIDCIL coord Coord}
	       File1 = {CondSelect PIDCIL file File}
	    in
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined principle ID: '#PIDA info:o(IL 'principle') coord:Coord1 file:File1) end
	    end
	    PrincipleIL = PIDAPrincipleILRec.PIDA
	    %%
	    PVILs = {CondSelect PrincipleIL dimensions nil}
	    PCILs = {Map PVILs Helpers.vIL2CIL}
	    PVILTypeILTups = {CondSelect PrincipleIL args nil}
	    PCILTypeILTups = {Map PVILTypeILTups
			      fun {$ PVIL#TypeIL}
				 PCIL = {Helpers.vIL2CIL PVIL}
			      in
				 PCIL#TypeIL
			      end}
	    PVILILTups = {CondSelect PrincipleIL defaults nil}
	    PCILILTups = {Map PVILILTups
			  fun {$ PVIL#IL}
			     PCIL = {Helpers.vIL2CIL PVIL}
			  in
			     PCIL#IL
			  end}
	    PModelIL = {CondSelect PrincipleIL model elem(tag: 'type.record'
							  args: nil)}
	    %% check whether DVADIDARec1's arity equals the arity in
	    %% the principle def
	    PAs = {Map PCILs Helpers.cIL2A}
	    for CIL#_ in CILCILTups do
	       A = {Helpers.cIL2A CIL}
	    in
	       if {Not {Member A PAs}} then
		  Coord1 = {CondSelect CIL coord Coord}
		  File1 = {CondSelect CIL file File}
	       in
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'A principle assigns a dimension to a dimension variable not included in its definition: '#A info:o(PAs IL 'principle') coord:Coord1 file:File1) end
	       end
	    end
	    %%
	    As = {Arity DVADIDARec1}
	    for PA in PAs do
	       if {Not {Member PA As}} then
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'A principle does not assign a dimension to one of its dimension variables: '#PA info:o(PAs As IL 'principle') coord:Coord file:File) end
	       end
	    end
	    %% create record type IL PArgTypeIL from PCILTypeILTups of
	    %% the principle definition
	    PArgsTypeIL = elem(tag: 'type.record'
			       args: PCILTypeILTups
			       %%
			       coord: Coord
			       file: File)
	    %% check used principle's arguments for illegal fields (=
	    %% fields not present in the principle definition)
	    PAs1 = {Map PCILTypeILTups
		    fun {$ PCIL#_} {Helpers.cIL2A PCIL} end}
	    for CIL#_ in CILILTups do
	       A = {Helpers.cIL2A CIL}
	    in
	       if {Not {Member A PAs1}} then
		  Coord1 = {CondSelect CIL coord Coord}
		  File1 = {CondSelect CIL file File}
	       in
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Illegal argument for principle: '#A info:o(PAs1 IL 'principle') coord:Coord1 file:File1) end
	       end
	    end
	    %% get used principle's arguments, and insert the default
	    %% value if an argument is missing
	    AILRec = {Helpers.cILXTups2AXRec CILILTups}
	    PAILRec = {Helpers.cILXTups2AXRec PCILILTups}
	    CILILTups1 =
	    {Map PCILTypeILTups
	     fun {$ PCIL#_}
		A = {Helpers.cIL2A PCIL}
		IL =
		if {HasFeature AILRec A} then
		   AILRec.A
		else
		   if {HasFeature PAILRec A} then
		      PAILRec.A
		   else
		      Coord1 = {CondSelect PCIL coord Coord}
		      File1 = {CondSelect PCIL file File}
		   in
		      raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Argument without default value omitted: '#A info:o(IL 'principle') coord:Coord1 file:File1) end
		   end
		end
	     in
		PCIL#IL
	     end}
	    %% add bindings 'Lex' -> 'lex' and 'Multi' -> 'multi' to
	    %% DVADIDARec1 (and yield DVADIDARec2)
	    DVADIDARec2 = {AdjoinList DVADIDARec1 ['Lex'#'lex'
						   'Multi'#'multi'
						   'This'#DIDA]}
	    %% create record ArgsIL from CILILTups1, and annotate it
	    %% with PArgsTypeIL
	    ArgsIL = elem(tag: record
			  args: CILILTups1
			  %%
			  coord: Coord
			  file: File)
	    ArgsIL1 = elem(tag: annotation
			   arg1: ArgsIL
			   arg2: PArgsTypeIL
			   %%
			   coord: Coord
			   file: File)
	    ArgsIL2 = {CollectTypes1 ArgsIL1 DVADIDARec2 AILRec CIDA DIDA Pn1}
	    %%
	    PModelTn = {CollectTypes1 PModelIL DVADIDARec2 AILRec CIDA DIDA Pn1}
	    PModelType = {Tn2Type PModelTn Coord File}
	    case PModelType
	    of elem(tag: 'type.record' ...) then skip
	    else
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Principle definition error: principle model type must be a record.' info:o(PModelType IL 'principle') coord:Coord file:File) end
	    end
	    %% get constraints feature from principle definition...
	    PCILIILTups = {CondSelect PrincipleIL constraints nil}
	    %% ...and convert it into CAPriITups
	    CAPriITups = {Map PCILIILTups
			  fun {$ CIL#IIL}
			     CA = {Helpers.cIL2A CIL}
			     PriI = {Helpers.iIL2I IIL}
			  in
			     CA#PriI
			  end}
	 in
	    elem(tag: useprinciple
		 idref: PIDCIL
		 dimensions: CILCILTups
		 args: ArgsIL2
		 %%
		 modelTn: PModelTn
		 %%
		 constraints: CAPriITups
		 %%
		 pn: Pn1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% class.dimension
	 [] elem(tag: 'class.dimension'
		 idref: DIDCIL
		 arg: IL ...) then
	    DIDA1 = {Helpers.cIL2A DIDCIL}
	    if {Not {HasFeature DIDADimensionILRec DIDA1}} then
	       Coord1 = {CondSelect DIDCIL coord Coord}
	       File1 = {CondSelect DIDCIL file File}
	    in
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined dimension ID: '#DIDA1 info:o(IL 'class.dimension') coord:Coord1 file:File1) end
	    end
	    %% create tuple CIL#IL1, where CIL represents the
	    %% dimension idref, and IL1 = {CollectTypes1 IL DVADIDARec
	    %% AILRec CIDA DIDA Pn})
	    IL1 = {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    DIDCIL#IL1
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% class.ref
	 [] elem(tag: 'class.ref'
		 idref: CIDCIL ...) then
	    VILILTups = {CondSelect IL args nil}
	    CIDA1 = {Helpers.cIL2A CIDCIL}
	    if CIDA1==CIDA then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Cyclic definition: referring to currently defined class ID: '#CIDA1 info:o(IL 'class.ref') coord:Coord file:File) end
	    end
	    %%
	    VILILTups1 = {Map VILILTups Helpers.clean}
	    AILRec1 = {RecordMap AILRec Helpers.clean}
	    KeyA = {Helpers.x2A CIDA1#VILILTups1#AILRec1}
	    if {HasFeature AClassILDict KeyA} then
	       %% if the same class has already been used with the
	       %% same arguments, do nothing
	       skip
	    else
	       %% else this is the first use of the class with these
	       %% particular arguments, and we have to process it
	       if {Not {HasFeature CIDAClassILRec CIDA1}} then
		  Coord1 = {CondSelect CIDCIL coord Coord}
		  File1 = {CondSelect CIDCIL file File}
	       in
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined class ID: '#CIDA1 info:o(IL 'class.ref') coord:Coord1 file:File1) end
	       end
	       ClassIL = CIDAClassILRec.CIDA1
	       CBodyIL = ClassIL.body
	       CVILs = {CondSelect ClassIL vars nil}
	       %%
	       CAs = {Map CVILs Helpers.vIL2A}
	       for VIL#_ in VILILTups do
		  A = {Helpers.vIL2A VIL}
	       in
		  if {Not {Member A CAs}} then
		     Coord1 = {CondSelect VIL coord Coord}
		     File1 = {CondSelect VIL file File}
		  in
		     raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'A class assigns a value to an argument variable not in its definition: '#A info:o(CAs IL 'class.ref') coord:Coord1 file:File1) end
		  end
	       end
	       %%
	       CILILTups = {Map VILILTups
			    fun {$ VIL#IL}
			       CIL = {Helpers.vIL2CIL VIL}
			       IL1 = {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
			    in
			       CIL#IL1
			    end}
	       AILRec1 = {Helpers.cILXTups2AXRec CILILTups}
	       As = {Arity AILRec1}
	       for CA in CAs do
		  if {Not {Member CA As}} then
		     raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'A class does not assign values to all of its argument variables: '#CA info:o(As IL 'class.ref') coord:Coord file:File) end
		  end
	       end
	       %%
	       AILRec2 = {Adjoin AILRec AILRec1}
	       IL1 = {CollectTypes1 CBodyIL DVADIDARec AILRec2 CIDA1 DIDA Pn}
	    in
	       %% save the class
	       AClassILDict.KeyA := IL1
	       %% mark the class as used
	       CIDABDict.CIDA1 := true
	    end
	    IL2 = elem(tag: 'class.ref'
		       idref: CIDCIL
		       args: VILILTups
		       %%
		       key: KeyA
		       %%
		       coord: Coord
		       file: File)
	 in
	    IL2
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% entry
	 [] elem(tag: entry
		 body: BodyIL ...) then
	    BodyIL1 = {CollectTypes1 BodyIL DVADIDARec AILRec CIDA DIDA Pn}
	    %% embed the body in a record IL1, and annotate it with Entry1Tn
	    IL1 = elem(tag: record
		       args: [BodyIL1]
		       %%
		       coord: Coord
		       file: File)
	    IL2 = elem(tag: annotation
		       arg1: IL1
		       arg2: Entry1Tn
		       %%
		       coord: Coord
		       file: File)
	 in
	    IL2
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% constant
	 [] elem(tag: constant ...) then
	    IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% variable
	 [] elem(tag: variable
		 data: A ...) then
	    if {Not {HasFeature AILRec A}} then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to unbound variable name: '#A info:o(IL AILRec 'variable') coord:Coord file:File) end
	    end
	    IL1 = AILRec.A
	 in
	    {CollectTypes1 IL1 DVADIDARec AILRec CIDA DIDA Pn}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% integer
	 [] elem(tag: integer ...) then
	    IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% top/bot
	 [] elem(tag: top ...) then
	    IL
	 [] elem(tag: bot ...) then
	    IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set
	 [] elem(tag: set ...) then
	    ILs = {CondSelect IL args nil}
	    ILs1 = {Map ILs
		    fun {$ IL}
		       {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		    end}
	 in
	    elem(tag: set
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% list
	 [] elem(tag: list ...) then
	    ILs = {CondSelect IL args nil}
	    ILs1 = {Map ILs
		    fun {$ IL}
		       {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		    end}
	 in
	    elem(tag: list
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% record
	 [] elem(tag: record ...) then
	    ILs = {CondSelect IL args nil}
	    ILs1 = {Map ILs
		    fun {$ IL}
		       {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		    end}
	 in
	    elem(tag: record
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% feature
	 [] IL1#IL2 then
	    IL11 = {CollectTypes1 IL1 DVADIDARec AILRec CIDA DIDA Pn}
	    IL21 = {CollectTypes1 IL2 DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    IL11#IL21
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.wild
	 [] elem(tag: 'card.wild' ...) then
	    IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.set
	 [] elem(tag: 'card.set' ...) then
	    ILs = {CondSelect IL args nil}
	 in
	    elem(tag: 'card.set'
		 args: ILs
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% card.interval
	 [] elem(tag: 'card.interval' ...) then
	    IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% feature path
	 [] elem(tag: featurepath
		 root: RootA
		 dimension: VIL
		 aspect: AspectA
		 fields: FieldCILs ...) then
	    DVA = {Helpers.vIL2A VIL}
	    if {Not {HasFeature DVADIDARec DVA}} then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to unbound dimension variable: '#DVA info:o(IL DVADIDARec 'featurepath') coord:Coord file:File) end
	    end
	    DIDA1 = DVADIDARec.DVA
	 in
	    elem(tag: featurepath
		 root: RootA
		 dimension: VIL
		 aspect: AspectA
		 fields: FieldCILs
		 %%
		 dimension_idref: DIDA1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set generator
	 [] elem(tag: setgen
		 arg: IL1 ...) then
	    IL2 = {CollectTypes1 IL1 DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    elem(tag: setgen
		 arg: IL2
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% annotation
	 [] elem(tag: annotation
		 arg1: ArgIL1
		 arg2: ArgIL2 ...) then
	    ArgIL11 = {CollectTypes1 ArgIL1 DVADIDARec AILRec CIDA DIDA Pn}
	    ArgIL21 = {CollectTypes1 ArgIL2 DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    elem(tag: annotation
		 arg1: ArgIL11
		 arg2: ArgIL21
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% conjunction
	 [] elem(tag: conj
		 args: ILs ...) then
	    ILs1 = {Map ILs
		    fun {$ IL}
		       {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		    end}
	 in
	    elem(tag: conj
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjunction
	 [] elem(tag: disj
		 args: ILs ...) then
	    ILs1 =
	    {Map ILs fun {$ IL}
			{CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		     end}
	 in
	    elem(tag: disj
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% concatenation
	 [] elem(tag: concat
		 args: ILs ...) then
	    ILs1 =
	    {Map ILs fun {$ IL}
			{CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		     end}
	    IL1 = elem(tag: concat
		       args: ILs1
		       %%
		       coord: Coord
		       file: File)
	    IL2 = elem(tag: annotation
		       arg1: IL1
		       arg2: StringTn
		       %%
		       coord: Coord
		       file: File)
	 in
	    IL2
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% order
	 [] elem(tag: order ...) then
	    ILs = {CondSelect IL args nil}
	    ILs1 = {Map ILs
		    fun {$ IL}
		       {CollectTypes1 IL DVADIDARec AILRec CIDA DIDA Pn}
		    end}
	 in
	    elem(tag: order
		 args: ILs1
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% typedef
	 []  elem(tag: typedef
		  id: TIDCIL
		  type: TypeIL ...) then
	    Tn = {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	 in
	    elem(tag: typedef
		 id: TIDCIL
		 type: Tn
		 %%
		 coord: Coord
		 file: File)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.domain
	 [] elem(tag: 'type.domain' ...) then
	    CILs = {CondSelect IL args nil}
	    As = {Map CILs Helpers.cIL2A}
	    {Helpers.checkDuplicateElements As Coord File}
	    As1 = {Sort As Value.'<'}
	    Type = elem(tag: 'type.domain'
			args: As1)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.set
	 [] elem(tag: 'type.set'
		 arg: TypeIL ...) then
	    Tn = {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    Type = elem(tag: 'type.set'
			arg: Tn)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.iset
	 [] elem(tag: 'type.iset'
		 arg: TypeIL ...) then
	    Tn = {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    Type = elem(tag: 'type.iset'
			arg: Tn)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.tuple
	 [] elem(tag: 'type.tuple' ...) then
	    TypeILs = {CondSelect IL args nil}
	    Tns = {Map TypeILs
		   fun {$ TypeIL}
		      {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
		   end}
	    Type = elem(tag: 'type.tuple'
			args: Tns)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.list
	 [] elem(tag: 'type.list'
		 arg: TypeIL ...) then
	    Tn = {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    Type = elem(tag: 'type.list'
			arg: Tn)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.record
	 [] elem(tag: 'type.record'
		 args: CILTypeILTups ...) then
	    CILTnTups = {Map CILTypeILTups
			 fun {$ CILTypeILTup}
			    {CollectTypes1 CILTypeILTup DVADIDARec AILRec CIDA DIDA Pn}
			 end}
	    ATnRec = {Helpers.cILXTups2AXRec CILTnTups}
	    Type = elem(tag: 'type.record'
			args: ATnRec)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.valency
	 [] elem(tag: 'type.valency'
		 arg: TypeIL1 ...) then
	    TypeIL2 = elem(tag: 'type.card')
	    TypeIL = elem(tag: 'type.vec'
			  arg1: TypeIL1
			  arg2: TypeIL2)
	 in
	    {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.card
	 [] elem(tag: 'type.card' ...) then
	    Type = elem(tag: 'type.card')
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.vec
	 [] elem(tag: 'type.vec'
		 arg1: TypeIL1
		 arg2: TypeIL2 ...) then
	    Tn1 = {CollectTypes1 TypeIL1 DVADIDARec AILRec CIDA DIDA Pn}
	    Type1 = {Tn2Type Tn1 Coord File}
	    Type1TagA = Type1.tag
	    if {Not Type1TagA=='type.domain'} then
	       Coord1 = {CondSelect TypeIL1 coord Coord}
	       File1 = {CondSelect TypeIL1 file File}
	    in
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Map or valency domain is not a domain type: '#Type1TagA info:o('type.vec') coord:Coord1 file:File1) end
	    end
	    Type1ArgsAs = Type1.args
	    %%
	    CILTypeILTups = {Map Type1ArgsAs
			     fun {$ A}
				CIL = {Helpers.a2CIL A}
			     in
				CIL#TypeIL2
			     end}
	    TypeIL = elem(tag: 'type.record'
			  args: CILTypeILTups)
	 in
	    {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.int
	 [] elem(tag: 'type.int' ...) then
	    Type = elem(tag: 'type.int')
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.ints
	 [] elem(tag: 'type.ints' ...) then
	    TypeIL = elem(tag: 'type.set'
			  arg: elem(tag: 'type.int'))
	 in
	    {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.string
	 [] elem(tag: 'type.string' ...) then
	    Type = elem(tag: 'type.string')
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.bool
	 [] elem(tag: 'type.bool' ...) then
	    Type = elem(tag: 'type.domain'
			args: ['false' 'true'])
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.ref
	 [] elem(tag: 'type.ref'
		 idref: TIDCIL ...) then 
	    TIDA = {Helpers.cIL2A TIDCIL}
	    KeyA = {Helpers.x2A TIDA#DVADIDARec}
	    Tn1 =
	    if {HasFeature ATnDict KeyA} then
	       ATnDict.KeyA
	    else
	       if {Not {HasFeature TIDATypeILRec TIDA}} then
		  Coord = {CondSelect TIDCIL coord noCoord}
	       in
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined type ID '#TIDA info:o(IL 'type.ref') coord:Coord file:File) end
	       end
	       TypeIL = TIDATypeILRec.TIDA
	       Tn = {CollectTypes1 TypeIL DVADIDARec AILRec CIDA DIDA Pn}
	       %%
	       ATnDict.KeyA := Tn
	    in
	       Tn
	    end
	 in
	    Tn1
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.labelref
	 [] elem(tag: 'type.labelref'
		 arg: VIL ...) then
	    KeyA = {Helpers.x2A VIL#DVADIDARec}
	    Tn1 =
	    if {HasFeature ATnDict1 KeyA} then
	       ATnDict1.KeyA
	    else
	       A = {Helpers.vIL2A VIL}
	       if {Not {HasFeature DVADIDARec A}} then
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to unbound dimension variable: '#A info:o(IL DVADIDARec 'type.labelref') coord:Coord file:File) end
	       end
	       %%
	       DIDA1 = DVADIDARec.A
	       if {Not {HasFeature DIDADimensionILRec DIDA1}} then
		  raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Referring to undefined dimension ID: '#DIDA1 info:o(IL 'type.labelref') coord:Coord file:File) end
	       end
	       DimensionIL = DIDADimensionILRec.DIDA1
	       LabelTypeIL = DimensionIL.label
	       Tn = {CollectTypes1 LabelTypeIL DVADIDARec AILRec CIDA DIDA Pn}
	       %%
	       ATnDict1.KeyA := Tn
	    in
	       Tn
	    end
	 in
	    Tn1
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type.variable
	 [] elem(tag: 'type.variable'
		 data: A ...) then
	    if Pn==noPn then
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Type variables cannot be used outside of principle definitions (argument type definitions).' info:o(IL 'type.variable') coord:Coord file:File) end
	    end
	    Type = elem(tag: 'type.variable'
			data: A
			%%
			pn: Pn
			%%
			coord: Coord
			file: File)
	 in
	    {Enter Type}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 else
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes1' msg:'Illformed IL expression.' info:o(IL DVADIDARec AILRec CIDA DIDA Pn) coord:Coord file:File) end
	 end
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% prepare...
      %%
      %% create mapping PIDA -> IL
      PrincipleILs = {CondSelect G principles nil}
      PIDAPrincipleILDict = {NewDictionary}
      for PrincipleIL in PrincipleILs do
	 PIDCIL = PrincipleIL.id
	 PIDA = {Helpers.cIL2A PIDCIL}
	 if {Dictionary.member PIDAPrincipleILDict PIDA} then
	    Coord = {CondSelect PIDCIL coord noCoord}
	    File = {CondSelect PIDCIL file noFile}
	 in
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Duplicate principle definition.' info:o(PrincipleIL PIDA PrincipleILs) coord:Coord file:File) end
	 end
      in
	 PIDAPrincipleILDict.PIDA := PrincipleIL
      end
      PIDAPrincipleILRec = {Dictionary.toRecord o PIDAPrincipleILDict}
      %% create mapping OIDA -> IL
      OutputILs = {CondSelect G outputs nil}
      OIDAOutputILDict = {NewDictionary}
      for OutputIL in OutputILs do
	 OIDCIL = OutputIL.id
	 OIDA = {Helpers.cIL2A OIDCIL}
	 if {Dictionary.member OIDAOutputILDict OIDA} then
	    Coord = {CondSelect OIDCIL coord noCoord}
	    File = {CondSelect OIDCIL file noFile}
	 in
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Duplicate output definition.' info:o(OutputIL OIDA OutputILs) coord:Coord file:File) end
	 end
      in
	 OIDAOutputILDict.OIDA := OutputIL
      end
      OIDAOutputILRec = {Dictionary.toRecord o OIDAOutputILDict}
      %% create mapping CIDA -> IL
      ClassILs = {CondSelect G classes nil}
      CIDAClassILDict = {NewDictionary}
      for ClassIL in ClassILs do
	 CIDCIL = ClassIL.id
	 Coord = {CondSelect CIDCIL coord noCoord}
	 File = {CondSelect CIDCIL file noFile}
	 CIDA = {Helpers.cIL2A CIDCIL}
	 if CIDA==noCIDA then
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Cannot use class ID "noCIDA".' info:o(ClassIL CIDA ClassILs) coord:Coord file:File) end
	 end
	 if {Dictionary.member CIDAClassILDict CIDA} then
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Duplicate class definition.' info:o(ClassIL CIDA ClassILs) coord:Coord file:File) end
	 end
      in
	 CIDAClassILDict.CIDA := ClassIL
      end
      CIDAClassILRec = {Dictionary.toRecord o CIDAClassILDict}
      %% create mapping DIDA -> IL
      DimensionILs = {CondSelect G dimensions nil}
      DIDADimensionILDict = {NewDictionary}
      for DimensionIL in DimensionILs do
	 DIDCIL = DimensionIL.id
	 DIDA = {Helpers.cIL2A DIDCIL}
	 if {Dictionary.member DIDADimensionILDict DIDA} then
	    Coord = {CondSelect DIDCIL coord noCoord}
	    File = {CondSelect DIDCIL file noFile}
	 in
	    raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Duplicate dimension definition.' info:o(DimensionIL DIDA DimensionILs) coord:Coord file:File) end
	 end
      in
	 DIDADimensionILDict.DIDA := DimensionIL
      end
      DIDADimensionILRec = {Dictionary.toRecord o DIDADimensionILDict}
      %% create mapping TIDA -> TypeIL
      TIDATypeILDict = {NewDictionary}
      for DimensionIL in DimensionILs do
	 DIDCIL = DimensionIL.id
	 DIDA = {Helpers.cIL2A DIDCIL}
	 TypeDefILs = {CondSelect DimensionIL types nil}
      in
	 for TypeDefIL in TypeDefILs do
	    TIDCIL = TypeDefIL.id
	    TIDA = {Helpers.cIL2A TIDCIL}
	    if {Dictionary.member TIDATypeILDict TIDA} then
	       Coord = {CondSelect TIDCIL coord noCoord}
	       File = {CondSelect TIDCIL file noFile}
	    in
	       raise error1('functor':'Compiler/TypeCollector.ozf' 'proc':'CollectTypes' msg:'Duplicate type definition.' info:o(TypeDefIL TIDA TypeDefILs DIDA DimensionIL DimensionILs) coord:Coord file:File) end
	    end
	    TypeIL = TypeDefIL.type
	 in
	    TIDATypeILDict.TIDA := TypeIL
	 end
      end
      TIDATypeILRec = {Dictionary.toRecord o TIDATypeILDict}
      %% create type dictionary TnTypeDict
      TnTypeDict = {NewDictionary}
      %%
      AClassILDict = {NewDictionary}
      %%
      CIDABDict = {NewDictionary}
      {RecordForAllInd CIDAClassILRec
       proc {$ CIDA _} CIDABDict.CIDA := false end}
      %%
      ATnDict = {NewDictionary}
      %%
      ATnDict1 = {NewDictionary}
      %% create entry type Entry1Type from the entry types of the
      %% individual dimensions
      CILEntryTypeILTups =
      {Map DimensionILs
       fun {$ DimensionIL}
	  DIDCIL = DimensionIL.id
	  EntryTypeIL = DimensionIL.entry
       in
	  DIDCIL#EntryTypeIL
       end}
      Entry1Type = elem(tag: 'type.record'
			args: CILEntryTypeILTups)
      Entry1Tn = {CollectTypes1 Entry1Type o o noCIDA noDIDA noPn}
      %% create node type NodeType having the attributes index, pos,
      %% entryIndex, nodeSet and word
      IntType = elem(tag: 'type.int')
      IntTn = {Enter IntType}
      IntsType = elem(tag: 'type.set'
		      arg: IntTn)
      IntsTn = {Enter IntsType}
      StringType = elem(tag: 'type.string')
      StringTn = {Enter StringType}
      NodeType = elem(tag:'type.record'
		      args: o(index: IntTn
			      pos: IntsTn
			      entryIndex: IntTn
			      nodeSet: IntsTn
			      word: StringTn))
      NodeTn = {Enter NodeType}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      G1 = {CollectTypes1 G o o noCIDA noDIDA noPn}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
      %% create complete node type NodeType1 including both the
      %% attributes index, pos, entryIndex, nodeSet and word, and the
      %% attrs, entry and model records of the individual dimensions
      DimensionILs1 = {CondSelect G1 dimensions nil}
      DIDATnTups =
      {Map DimensionILs1
       fun {$ DimensionIL}
	  DIDCIL = DimensionIL.id
	  DIDA = {Helpers.cIL2A DIDCIL}
	  AttrsTn = DimensionIL.attrs
	  EntryTn = DimensionIL.entry
	  %%
	  ModelDict = {NewDictionary}
	  for PrincipleIL in DimensionIL.principles do
	     ModelTn = PrincipleIL.modelTn
	     ModelType = TnTypeDict.ModelTn
	  in
	     {Record.forAllInd ModelType.args
	      proc {$ A Tn} ModelDict.A := Tn end}
	  end
	  ModelRec = {Dictionary.toRecord o ModelDict}
	  ModelType = elem(tag: 'type.record'
			   args: ModelRec)
	  ModelTn = {Enter ModelType}
	  Type = elem(tag: 'type.record'
		      args: o(attrs: AttrsTn
			      entry: EntryTn
			      model: ModelTn))
	  Tn = {Enter Type}
       in
	  DIDA#Tn
       end}
      DIDATnRec = {ListToRecord o DIDATnTups}
      Node1Type = elem(tag: 'type.record'
		       args: {Adjoin NodeType.args DIDATnRec})
      Node1Tn = {Enter Node1Type}
      %%
      CIDAs = {Dictionary.keys CIDABDict}
      UnusedCIDAs =
      for CIDA in CIDAs collect:Collect do
	 if CIDABDict.CIDA==false then {Collect CIDA} end
      end
      UnusedCIDAsI = {Length UnusedCIDAs}
      {PrintProc UnusedCIDAsI#' unused lexical classes ...'}
      for CIDA in UnusedCIDAs do
	 {PrintProc CIDA}
      end
      %%
      AClassILRec = {Dictionary.toRecord o AClassILDict}
   in
      G1#TnTypeDict#AClassILRec#Entry1Tn#NodeTn#Node1Tn
   end
end
