%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(aILTups2A1ILRec cIL2VIL cIL2IIL cIL2A) at 'Helpers.ozf'

%   Inspector(inspect)
%   Ozcar(breakpoint)
export
   Convert
define
   %% Convert: Elements -> IL
   %% Transforms a list of XML elements Elements into an IL expression IL.
   fun {Convert Elements}
      AILTups = {Map Elements Element2AILTup}
      ILs =
      for A#IL in AILTups collect:Collect do
	 if A==grammar orelse A==set then {Collect IL} end
      end
      I = {Length ILs}
      if I==0 then
	 raise error1('functor':'Compiler/XML/XML2IL.ozf' 'proc':'Convert' msg:'No grammar/node set contained in elements.' info:o(Elements) coord:noCoord file:noFile) end
      end
      if I>1 then
	 raise error1('functor':'Compiler/XML/XML2IL.ozf' 'proc':'Convert' msg:'More than one grammar/node set contained in elements.' info:o(Elements) coord:noCoord file:noFile) end
      end
      IL = ILs.1
   in
      IL
   end
   %%
   %% define disjunctions (DTD PEs)
   TypeDisjRec = o(type: [typeDomain typeSet typeISet typeTuple typeList typeRecord typeValency typeCard typeVec typeInt typeInts typeString typeBool typeRef typeLabelRef typeVariable])
   %%
   TermDisjRec = o(term: [constant variable integer top bot constantCard constantCardSet constantCardInterval variableCard variableCardSet variableCardInterval set list record recordConj recordDisj setGen setGenConj setGenDisj featurePath annotation conj disj concat order bounds feature varFeature])
   %%
   ClassDisjRec = o('class': [classDimension useClass classConj classDisj])
   %%
   RecSpecDisjRec = o(recSpec: [feature varFeature recordConj recordDisj])
   %%
   SetGenSpecDisjRec = o(setGenSpec: [constant setGenConj setGenDisj])
   %%
   %% Attribute2ACILTup: Attribute -> ACILTup
   %% Convert a parsed XML attribute Attribute into a tuple A#CIL,
   %% where A is the attribute and CIL its value.
   fun {Attribute2ACILTup Attribute}
      Coord1 = {CondSelect Attribute coord noCoord}
      Coord = {CondSelect Coord1 2 noCoord}
      File = {CondSelect Coord1 1 noFile}
      %%
      A = Attribute.name
      A1 = Attribute.value
      CIL = elem(tag: constant
		 data: A1
		 coord: Coord
		 file: File)
   in
      A#CIL
   end
   %%
   %% Element2AILTup: Element -> AILTup
   %% Convert a parsed XML element Element into a tuple A#IL.
   fun {Element2AILTup Element}
      Coord1 = {CondSelect Element coord noCoord}
      Coord = {CondSelect Coord1 2 noCoord}
      File = {CondSelect Coord1 1 noFile}
      %%
      Attributes = {CondSelect Element attributes nil}
      Children = {CondSelect Element children nil}
      AILTups = {Map Attributes Attribute2ACILTup}
      AILTups1 = {Map Children Element2AILTup}
   in
      case Element
      of pi(name: xml
	    data: A ...) then
	 pi#elem(tag: xml
		 data: A
		 %%
		 coord: Coord
		 file: File)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% grammar
      [] element(name: grammar ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(useDimension: '*'
					     dimension: '*'
					     classDef: '*'
					     entry: '*') o Coord File}
	 UseDimensionCILs = AILRec1.useDimension
	 DimensionILs = AILRec1.dimension
	 ClassDefILs = AILRec1.classDef
	 EntryILs = AILRec1.entry
	 IL = elem(tag: grammar
		   usedimensions: UseDimensionCILs
		   dimensions: DimensionILs
		   classes: ClassDefILs
		   entries: EntryILs
		   %%
		   coord: Coord
		   file: File)
      in
	 grammar#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useDimension
      [] element(name: useDimension ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 DIDCIL = AILRec.idref
      in
	 useDimension#DIDCIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dimension
      [] element(name: dimension ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(id: '!') o Coord File}
	 IDCIL = AILRec.id
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(attrsType: '?'
					     entryType: '?'
					     labelType: '?'
					     typeDef: '*'
					     usePrinciple: '*'
					     output: '*'
					     useOutput: '*') o Coord File}
	 AttrsTypeIL = {CondSelect AILRec1 attrsType elem(tag: 'type.record'
							  args: nil
							  %%
							  coord: Coord
							  file: File)}
	 EntryTypeIL = {CondSelect AILRec1 entryType elem(tag: 'type.record'
							  args: nil
							  %%
							  coord: Coord
							  file: File)}
	 LabelTypeIL = {CondSelect AILRec1 labelType elem(tag: 'type.domain'
							  args: nil
							  %%
							  coord: Coord
							  file: File)}
	 TypeDefILs = AILRec1.typeDef
	 UsePrincipleILs = AILRec1.usePrinciple
	 OutputILs = AILRec1.output
	 UseOutputILs = AILRec1.useOutput
	 IL = elem(tag: dimension
		   id: IDCIL
		   attrs: AttrsTypeIL
		   entry: EntryTypeIL
		   label: LabelTypeIL
		   types: TypeDefILs
		   principles: UsePrincipleILs
		   outputs: OutputILs
		   useoutputs: UseOutputILs
		   %%
		   coord: Coord
		   file: File)
      in
	 dimension#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% attrsType
      [] element(name: attrsType ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
      in
	 attrsType#TypeIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% entryType
      [] element(name: entryType ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
      in
	 entryType#TypeIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% labelType
      [] element(name: labelType ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
      in
	 labelType#TypeIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% output
      [] element(name: output ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 IL = elem(tag: output
		   idref: IDCIL
		   %%
		   coord: Coord
		   file: File)
      in
	 output#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useOutput
      [] element(name: useOutput ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 IL = elem(tag: useoutput
		   idref: IDCIL
		   %%
		   coord: Coord
		   file: File)
      in
	 useOutput#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeDef
      [] element(name: typeDef ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(id: '!') o Coord File}
	 IDCIL = AILRec.id
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = elem(tag: typedef
		   id: IDCIL
		   type: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeDef#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% usePrinciple
      [] element(name: usePrinciple ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(dim: '*'
					     arg: '*') o Coord File}
	 DimILs = AILRec1.dim
	 ArgILs = AILRec1.arg
	 IL = elem(tag: useprinciple
		   idref: IDCIL
		   dimensions: DimILs
		   args: ArgILs
		   %%
		   coord: Coord
		   file: File)
      in
	 usePrinciple#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dim
      [] element(name: dim ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(var: '!'
					    idref: '!') o Coord File}
	 CIL = AILRec.var
	 VIL = {Helpers.cIL2VIL CIL}
	 IDCIL = AILRec.idref
	 IL = VIL#IDCIL
      in
	 dim#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% arg
      [] element(name: arg ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(var: '!') o Coord File}
	 CIL = AILRec.var
	 VIL = {Helpers.cIL2VIL CIL}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '!') TermDisjRec Coord File}
	 TermIL = AILRec1.term
	 IL = VIL#TermIL
      in
	 arg#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeDomain
      [] element(name: typeDomain ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(constant: '*') o Coord File}
	 CILs = AILRec1.constant
	 IL = elem(tag: 'type.domain'
		   args: CILs
		   %%
		   coord: Coord
		   file: File)
      in
	 typeDomain#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeSet
      [] element(name: typeSet ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = elem(tag: 'type.set'
		   arg: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeSet#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeISet
      [] element(name: typeISet ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = elem(tag: 'type.iset'
		   arg: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeISet#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeTuple
      [] element(name: typeTuple ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '*') TypeDisjRec Coord File}
	 TypeILs = AILRec1.type
	 IL = elem(tag: 'type.tuple'
		   args: TypeILs
		   %%
		   coord: Coord
		   file: File)
      in
	 typeTuple#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeList
      [] element(name: typeList ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = elem(tag: 'type.list'
		   arg: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeList#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeRecord
      [] element(name: typeRecord ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(typeFeature: '*') o Coord File}
	 TypeILs = AILRec1.typeFeature
	 IL = elem(tag: 'type.record'
		   args: TypeILs
		   %%
		   coord: Coord
		   file: File)
      in
	 typeRecord#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeValency
      [] element(name: typeValency ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = elem(tag: 'type.valency'
		   arg: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeValency#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeCard
      [] element(name: typeCard ...) then
	 IL = elem(tag: 'type.card'
		   %%
		   coord: Coord
		   file: File)
      in
	 typeCard#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeVec
      [] element(name: typeVec ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: 2) TypeDisjRec Coord File}
	 TypeILs = AILRec1.type
	 TypeIL1 = {Nth TypeILs 1}
	 TypeIL2 = {Nth TypeILs 2}
	 IL = elem(tag: 'type.vec'
		   arg1: TypeIL1
		   arg2: TypeIL2
		   %%
		   coord: Coord
		   file: File)
      in
	 typeVec#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeInt
      [] element(name: typeInt ...) then
	 IL = elem(tag: 'type.int'
		   %%
		   coord: Coord
		   file: File)
      in
	 typeInt#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeInts
      [] element(name: typeInts ...) then
	 IL = elem(tag: 'type.ints'
		   %%
		   coord: Coord
		   file: File)
      in
	 typeInts#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeString
      [] element(name: typeString ...) then
	 IL = elem(tag: 'type.string'
		   %%
		   coord: Coord
		   file: File)
      in
	 typeString#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeBool
      [] element(name: typeBool ...) then
	 IL = elem(tag: 'type.bool'
		   %%
		   coord: Coord
		   file: File)
      in
	 typeBool#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeRef
      [] element(name: typeRef ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 IL = elem(tag: 'type.ref'
		   idref: IDCIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeRef#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeLabelRef
      [] element(name: typeLabelRef ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
	 IL = elem(tag: 'type.labelref'
		   arg: VIL
		   %%
		   coord: Coord
		   file: File)
      in
	 typeLabelRef#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeVariable
      [] element(name: typeVariable ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 A = {Helpers.cIL2A CIL}
	 IL = elem(tag: 'type.variable'
		   data: A
		   %%
		   coord: Coord
		   file: File)
      in
	 typeVariable#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% typeFeature
      [] element(name: typeFeature ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(type: '!') TypeDisjRec Coord File}
	 TypeIL = AILRec1.type
	 IL = CIL#TypeIL
      in
	 typeFeature#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% classDef
      [] element(name: classDef ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(id: '!') o Coord File}
	 IDCIL = AILRec.id
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(variable: '*'
					     'class': '*') ClassDisjRec Coord File}
	 VariableCILs = AILRec1.variable
	 VariableVILs = {Map VariableCILs Helpers.cIL2VIL}
	 ClassILs = AILRec1.'class'
	 ClassIL = elem(tag: conj
			args: ClassILs
			%%
			coord: Coord
			file: File)
	 IL = elem(tag: classdef
		   id: IDCIL
		   vars: VariableVILs
		   body: ClassIL
		   %%
		   coord: Coord
		   file: File)
      in
	 classDef#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% classDimension
      [] element(name: classDimension ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '!') TermDisjRec Coord File}
	 TermIL = AILRec1.term
	 IL = elem(tag: 'class.dimension'
		   idref: IDCIL
		   arg: TermIL
		   %%
		   coord: Coord
		   file: File)
      in
	 classDimension#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useClass
      [] element(name: useClass ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(idref: '!') o Coord File}
	 IDCIL = AILRec.idref
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(varFeature: '*') o Coord File}
	 VarFeatureCILILTups = AILRec1.varFeature
	 VarFeatureVILILTups = {Map VarFeatureCILILTups
				fun {$ CIL#IL}
				   VIL = {Helpers.cIL2VIL CIL}
				in
				   VIL#IL
				end}
	 IL = elem(tag: 'class.ref'
		   idref: IDCIL
		   args: VarFeatureVILILTups
		   %%
		   coord: Coord
		   file: File)
      in
	 useClass#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% classConj
      [] element(name: classConj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o('class': '*') ClassDisjRec Coord File}
	 ClassILs = AILRec1.'class'
	 IL = elem(tag: conj
		   args: ClassILs
		   %%
		   coord: Coord
		   file: File)
      in
	 classConj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% classDisj
      [] element(name: classDisj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o('class': '*') ClassDisjRec Coord File}
	 ClassILs = AILRec1.'class'
	 IL = elem(tag: disj
		   args: ClassILs
		   %%
		   coord: Coord
		   file: File)
      in
	 classDisj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% entry
      [] element(name: entry ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o('class': '*') ClassDisjRec Coord File}
	 ClassILs = AILRec1.'class'
	 ClassIL = elem(tag: conj
			args: ClassILs
			%%
			coord: Coord
			file: File)
	 IL = elem(tag: entry
		   body: ClassIL
		   %%
		   coord: Coord
		   file: File)
      in
	 entry#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constant
      [] element(name: constant ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
      in
	 constant#CIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% variable
      [] element(name: variable ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
      in
	 variable#VIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% integer
      [] element(name: integer ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 IIL = {Helpers.cIL2IIL CIL}
      in
	 integer#IIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% top/bot
      [] element(name: top ...) then
	 IL = elem(tag: top
		   %%
		   coord: Coord
		   file: File)
      in
	 top#IL
      [] element(name: bot ...) then
	 IL = elem(tag: bot
		   %%
		   coord: Coord
		   file: File)
      in
	 bot#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constantCard
      [] element(name: constantCard ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!'
					    card: '?') o Coord File}
	 CIL = AILRec.data
	 CardCIL = {CondSelect AILRec card elem(tag: constant
						data: 'one')}
	 CardA = case CardCIL.data
		 of 'one' then '!'
		 [] 'opt' then '?'
		 [] 'any' then '*'
		 [] 'geone' then '+'
		 else 'error'
		 end
	 if CardA=='error' then
	    raise error1('functor':'Compiler/XML/XML2IL.ozf' 'proc':'Element2AILTup' msg:'Value of card attribute is "'#CardCIL.data#'", but must be either "one", "opt", "any", or "geone".' info:o(Element) coord:Coord file:File) end
	 end
	 CardIL = elem(tag: 'card.wild'
		       arg: CardA
		       %%
		       coord: Coord
		       file: File)
	 IL = CIL#CardIL
      in
	 constantCard#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constantCardSet
      [] element(name: constantCardSet ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(integer: '*') o Coord File}
	 IILs = AILRec1.integer
	 CardIL = elem(tag: 'card.set'
		       args: IILs
		       %%
		       coord: Coord
		       file: File)
	 IL = CIL#CardIL
      in
	 constantCardSet#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constantCardInterval
      [] element(name: constantCardInterval ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(integer: 2) o Coord File}
	 IILs = AILRec1.integer
	 IIL1 = {Nth IILs 1}
	 IIL2 = {Nth IILs 2}
	 CardIL = elem(tag: 'card.interval'
		       arg1: IIL1
		       arg2: IIL2
		       %%
		       coord: Coord
		       file: File)
	 IL = CIL#CardIL
      in
	 constantCardInterval#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% variableCard
      [] element(name: variableCard ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!'
					    card: '?') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
	 CardCIL = {CondSelect AILRec card elem(tag: constant
						data: 'one')}
	 CardA = case CardCIL.data
		 of 'one' then '!'
		 [] 'opt' then '?'
		 [] 'any' then '*'
		 [] 'geone' then '+'
		 else 'error'
		 end
	 if CardA=='error' then
	    raise error1('functor':'Compiler/XML/XML2IL.ozf' 'proc':'Element2AILTup' msg:'Value of card attribute is "'#CardCIL.data#'", but must be either "one", "opt", "any", or "geone".' info:o(Element) coord:Coord file:File) end
	 end
	 CardIL = elem(tag: 'card.wild'
		       arg: CardA
		       %%
		       coord: Coord
		       file: File)
	 IL = VIL#CardIL
      in
	 variableCard#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% variableCardSet
      [] element(name: variableCardSet ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(integer: '*') o Coord File}
	 IILs = AILRec1.integer
	 CardIL = elem(tag: 'card.set'
		       args: IILs
		       %%
		       coord: Coord
		       file: File)
	 IL = VIL#CardIL
      in
	 variableCardSet#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% variableCardInterval
      [] element(name: variableCardInterval ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(integer: 2) o Coord File}
	 IILs = AILRec1.integer
	 IIL1 = {Nth IILs 1}
	 IIL2 = {Nth IILs 2}
	 CardIL = elem(tag: 'card.interval'
		       arg1: IIL1
		       arg2: IIL2
		       %%
		       coord: Coord
		       file: File)
	 IL = VIL#CardIL
      in
	 variableCardInterval#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% set
      [] element(name: set ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: set
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 set#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% list
      [] element(name: list ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: list
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 list#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% record
      [] element(name: record ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(recSpec: '*') RecSpecDisjRec Coord File}
	 ILs = AILRec1.recSpec
	 IL = elem(tag: record
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 record#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% recordConj
      [] element(name: recordConj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(recSpec: '*') RecSpecDisjRec Coord File}
	 ILs = AILRec1.recSpec
	 IL = elem(tag: conj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 recordConj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% recordDisj
      [] element(name: recordDisj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(recSpec: '*') RecSpecDisjRec Coord File}
	 ILs = AILRec1.recSpec
	 IL = elem(tag: disj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 recordDisj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% setGen
      [] element(name: setGen ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(setGenSpec: '*') SetGenSpecDisjRec Coord File}
	 ILs = AILRec1.setGenSpec
	 SetGenIL = elem(tag: conj
			 args: ILs
			 %%
			 coord: Coord
			 file: File)
	 IL = elem(tag: setgen
		   arg: SetGenIL
		   %%
		   coord: Coord
		   file: File)
      in
	 setGen#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% setGenConj
      [] element(name: setGenConj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(setGenSpec: '*') SetGenSpecDisjRec Coord File}
	 ILs = AILRec1.setGenSpec
	 IL = elem(tag: conj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 setGenConj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% setGenDisj
      [] element(name: setGenDisj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(setGenSpec: '*') SetGenSpecDisjRec Coord File}
	 ILs = AILRec1.setGenSpec
	 IL = elem(tag: disj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 setGenDisj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% featurePath
      [] element(name: featurePath ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(root: '!'
					    dimension: '!'
					    aspect: '!') o Coord File}
	 RootCIL = AILRec.root
	 RootA = {Helpers.cIL2A RootCIL}
	 RootA1 = case RootA
		  of down then '_'
		  [] up then '^'
		  end
	 DimensionCIL = AILRec.dimension
	 DimensionVIL = {Helpers.cIL2VIL DimensionCIL}
	 AspectCIL = AILRec.aspect
	 AspectA = {Helpers.cIL2A AspectCIL}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(constant: '*') o Coord File}
	 CILs = AILRec1.constant
	 IL = elem(tag: featurepath
		   root: RootA1
		   dimension: DimensionVIL
		   aspect: AspectA
		   fields: CILs
		   %%
		   coord: Coord
		   file: File)
      in
	 featurePath#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% annotation
      [] element(name: annotation ...) then
	 TermTypeDisjRec = {Adjoin TermDisjRec TypeDisjRec}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '!'
					     type: '!') TermTypeDisjRec Coord File}
	 TermIL = AILRec1.term
	 TypeIL = AILRec1.type
	 IL = elem(tag: annotation
		   arg1: TermIL
		   arg2: TypeIL
		   %%
		   coord: Coord
		   file: File)
      in
	 annotation#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% feature
      [] element(name: feature ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '!') TermDisjRec Coord File}
	 TermIL = AILRec1.term
	 IL = CIL#TermIL
      in
	 feature#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% varFeature
      [] element(name: varFeature ...) then
	 AILRec =
	 {Helpers.aILTups2A1ILRec AILTups o(data: '!') o Coord File}
	 CIL = AILRec.data
	 VIL = {Helpers.cIL2VIL CIL}
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '!') TermDisjRec Coord File}
	 TermIL = AILRec1.term
	 IL = VIL#TermIL
      in
	 varFeature#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% conj
      [] element(name: conj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: conj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 conj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% disj
      [] element(name: disj ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: disj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 disj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% concat
      [] element(name: concat ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: concat
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 concat#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% order
      [] element(name: order ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '*') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL = elem(tag: order
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
      in
	 order#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% bounds
      [] element(name: bounds ...) then
	 AILRec1 =
	 {Helpers.aILTups2A1ILRec AILTups1 o(term: '2') TermDisjRec Coord File}
	 ILs = AILRec1.term
	 IL1 = {Nth ILs 1}
	 IL2 = {Nth ILs 2}
	 IL = elem(tag: bounds
		   arg1: IL1
		   arg2: IL2
		   %%
		   coord: Coord
		   file: File)
      in
	 bounds#IL
      else
	 raise error1('functor':'Compiler/XML/XML2IL.ozf' 'proc':'Element2AILTup' msg:'Illformed XML element.' info:o(Element) coord:Coord file:File) end
      end
   end
end
