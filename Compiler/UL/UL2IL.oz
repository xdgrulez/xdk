%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Ozcar(breakpoint)
   
   Helpers(cIL2A aILTups2A1ILRec cUL2CIL vUL2VIL iUL2IIL token2IL vIL2A) at 'Helpers.ozf'
export
   Convert
define
   %% Convert: UL -> IL
   %% Transforms a UL expression UL into an IL expression IL.
   fun {Convert UL}
      _#IL = {UL2AILTup UL}
   in
      IL
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% UL2AILTup: UL -> AILTup
   %% Transforms a UL expression UL into a pair A#IL of a field A and
   %% an IL expression IL.
   fun {UL2AILTup UL}
      Coord1 = UL.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = UL.file
      File = if File1==unit then noFile else File1 end
      Sem = UL.sem
   in
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defgrammar
      of defgrammar(UL1) then
	 UL2 = UL1.sem
	 AILTups = {Map UL2 UL2AILTup}
	 A1ILRec = {Helpers.aILTups2A1ILRec AILTups
		    o(principles: '*'
		      dimensions: '*'
		      classes: '*'
		      entries: '*'
		      usedimensions: '*') o Coord File}
	 PrinciplesILs = A1ILRec.principles
	 DimensionsILs = A1ILRec.dimensions
	 ClassesILs = A1ILRec.classes
	 EntriesILs = A1ILRec.entries
	 UsedimensionsILs = A1ILRec.usedimensions
	 IL = elem(tag: grammar
		   principles: PrinciplesILs
		   dimensions: DimensionsILs
		   classes: ClassesILs
		   entries: EntriesILs
		   usedimensions: UsedimensionsILs
		   %%
		   coord: Coord
		   file: File)
      in
	 grammar#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defdim
      [] defdim(CUL UL1) then
	 IDCIL = {Helpers.cUL2CIL CUL}
	 UL2 = UL1.sem
	 AILTups = {Map UL2 UL2AILTup}
	 A1ILRec = {Helpers.aILTups2A1ILRec AILTups
		    o(attrs: '?'
		      entry: '?'
		      label: '?'
		      types: '*'
		      principles: '*'
		      outputs: '*'
		      useoutputs: '*') o Coord File}
	 AttrsIL = {CondSelect A1ILRec attrs elem(tag: 'type.record'
						  args: nil
						  %%
						  coord: Coord
						  file: File)}
	 EntryIL = {CondSelect A1ILRec entry elem(tag: 'type.record'
						  args: nil
						  %%
						  coord: Coord
						  file: File)}
	 LabelIL = {CondSelect A1ILRec label elem(tag: 'type.domain'
						  args: nil
						  %%
						  coord: Coord
						  file: File)}
	 TypesILs = A1ILRec.types
	 PrinciplesILs = A1ILRec.principles
	 OutputsILs = A1ILRec.outputs
	 UseOutputsILs = A1ILRec.useoutputs
	 IL = elem(tag: dimension
		   id: IDCIL
		   attrs: AttrsIL
		   entry: EntryIL
		   label: LabelIL
		   types: TypesILs
		   principles: PrinciplesILs
		   outputs: OutputsILs
		   useoutputs: UseOutputsILs
		   %%
		   coord: Coord
		   file: File)
      in
	 dimensions#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% usedim
      [] usedim(CUL) then
	 CIL = {Helpers.cUL2CIL CUL}
      in
	 usedimensions#CIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% output
      [] output(CUL) then
	 IDCIL = {Helpers.cUL2CIL CUL}
	 IL = elem(tag: output
		   idref: IDCIL
		   %%
		   coord: Coord
		   file: File)
      in
	 outputs#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useoutput
      [] useoutput(CUL) then
	 IDCIL = {Helpers.cUL2CIL CUL}
	 IL = elem(tag: useoutput
		   idref: IDCIL
		   %%
		   coord: Coord
		   file: File)
      in
	 useoutputs#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defattrstype
      [] defattrstype(UL1) then
	 _#IL = {UL2AILTup UL1}
      in
	 attrs#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defentrytype
      [] defentrytype(UL1) then
	 _#IL = {UL2AILTup UL1}
      in
	 entry#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% deflabeltype
      [] deflabeltype(UL1) then
	 _#IL = {UL2AILTup UL1}
      in
	 label#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% deftype
      [] deftype(CUL UL1) then
	 CIL = {Helpers.cUL2CIL CUL}
	 %%
	 _#IL1 = {UL2AILTup UL1}
	 IL =
	 elem(tag: typedef
	      id: CIL
	      type: IL1
	      %%
	      coord: Coord
	      file: File)
      in
	 types#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% useprinciple
      [] useprinciple(CUL UL1) then
	 IDCIL = {Helpers.cUL2CIL CUL}
	 UL2 = UL1.sem
	 AILTups = {Map UL2 UL2AILTup}
	 A1ILRec = {Helpers.aILTups2A1ILRec AILTups
		    o(dimensions: '?'
		      args: '?') o Coord File}
	 DimensionsILs = {CondSelect A1ILRec dimensions nil}
	 ArgsILs = {CondSelect A1ILRec args nil}
	 IL = elem(tag: useprinciple
		   idref: IDCIL
		   dimensions: DimensionsILs
		   args: ArgsILs
		   %%
		   coord: Coord
		   file: File)
      in
	 principles#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dims
      [] dims(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
      in
	 dimensions#ILs
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% args
      [] args(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
      in
	 args#ILs
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defclass
      [] defclass(CUL UL1 UL2) then
	 CIL = {Helpers.cUL2CIL CUL}
	 %%
	 VULs = UL1.sem
	 VILs = {Map VULs Helpers.vUL2VIL}
	 %%
	 ULs = UL2.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL = elem(tag: conj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
	 %%
	 IL1 =
	 elem(tag: classdef
	      id: CIL
	      vars: VILs
	      body: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 classes#IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% defentry
      [] defentry(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL = elem(tag: conj
		   args: ILs
		   %%
		   coord: Coord
		   file: File)
	 IL1 =
	 elem(tag: entry
	      body: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 entries#IL1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type
      [] 'type.domain'(UL1) then
	 CULs = UL1.sem
	 CILs = {Map CULs Helpers.cUL2CIL}
	 IL =
	 elem(tag: 'type.domain'
	      args: CILs
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.set'(UL1) then
	 _#IL = {UL2AILTup UL1}
	 IL1 =
	 elem(tag: 'type.set'
	      arg: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL1
      [] 'type.iset'(UL1) then
	 _#IL = {UL2AILTup UL1}
	 IL1 =
	 elem(tag: 'type.iset'
	      arg: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL1
      [] 'type.tuple'(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: 'type.tuple'
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.list'(UL1) then
	 _#IL = {UL2AILTup UL1}
	 IL1 =
	 elem(tag: 'type.list'
	      arg: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL1
      [] 'type.valency'(UL1) then
	 _#IL = {UL2AILTup UL1}
	 IL1 =
	 elem(tag: 'type.valency'
	      arg: IL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL1
      [] 'type.card'(...) then
	 IL =
	 elem(tag: 'type.card'
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.record'(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: 'type.record'
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.emptyrecord'(...) then
	 IL =
	 elem(tag: 'type.record'
	      args: nil
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.vec'(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: 'type.vec'
	      arg1: IL1
	      arg2: IL2
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.int'(...) then
	 IL =
	 elem(tag: 'type.int'
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.ints'(...) then
	 IL =
	 elem(tag: 'type.ints'
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.string'(...) then
	 IL =
	 elem(tag: 'type.string'
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.bool'(...) then
	 IL =
	 elem(tag: 'type.bool'
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.ref'(CUL) then
	 CIL = {Helpers.cUL2CIL CUL}
	 IL =
	 elem(tag: 'type.ref'
	      idref: CIL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.labelref'(VUL) then
	 VIL = {Helpers.vUL2VIL VUL}
	 IL =
	 elem(tag: 'type.labelref'
	      arg: VIL
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
      [] 'type.variable'(VUL) then
	 VIL = {Helpers.vUL2VIL VUL}
	 A = {Helpers.vIL2A VIL}
	 %%
	 IL =
	 elem(tag: 'type.variable'
	      data: A
	      %%
	      coord: Coord
	      file: File)
      in
	 type#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% class
      [] 'class.dim'(CUL UL1) then
	 CIL = {Helpers.cUL2CIL CUL}
	 _#IL1 = {UL2AILTup UL1}
	 IL =
	 elem(tag: 'class.dimension'
	      idref: CIL
	      arg: IL1
	      %%
	      coord: Coord
	      file: File)
      in
	 body#IL
      [] 'class.ref'(CUL) then
	 CIL = {Helpers.cUL2CIL CUL}
	 IL =
	 elem(tag: 'class.ref'
	      idref: CIL
	      args: nil
	      %%
	      coord: Coord
	      file: File)
      in
	 body#IL
      [] 'class.ref'(CUL UL1) then
	 CIL = {Helpers.cUL2CIL CUL}
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: 'class.ref'
	      idref: CIL
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 body#IL
      [] conj(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: conj
	      args: [IL1 IL2]
	      %%
	      coord: Coord
	      file: File)
      in
	 conj#IL
      [] disj(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: disj
	      args: [IL1 IL2]
	      %%
	      coord: Coord
	      file: File)
      in
	 disj#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% concat
      [] concat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: concat
	      args: [IL1 IL2]
	      %%
	      coord: Coord
	      file: File)
      in
	 concat#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% order
      [] order(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: order
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 order#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% bounds
      [] bounds(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: bounds
	      arg1: IL1
	      arg2: IL2
	      %%
	      coord: Coord
	      file: File)
      in
	 bounds#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constant
      [] constant(Token) then
	 CIL = {Helpers.token2IL Token}
      in
	 constant#CIL 
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constantOrVariable
      [] constantOrVariable(Token) then
	 CIL = {Helpers.token2IL Token}
      in
	 constantOrVariable#CIL 
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% integer
      [] integer(Token) then
	 IIL = {Helpers.token2IL Token}
      in
	 integer#IIL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% top/bot
      [] top(...) then
	 IL = elem(tag: top
		   %%
		   coord: Coord
		   file: File)
      in
	 top#IL
      [] bot(...) then
	 IL = elem(tag: bot
		   %%
		   coord: Coord
		   file: File)
      in
	 bot#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% featurepath
      [] featurepath(UL1 UL2 UL3 UL4) then
	 RootA = UL1.sem
	 DimensionVIL = {Helpers.vUL2VIL UL2}
	 AspectA = UL3.sem
	 CULs = UL4.sem
	 FieldCILs = {Map CULs Helpers.cUL2CIL}
	 IL =
	 elem(tag: featurepath
	      root: RootA
	      dimension: DimensionVIL
	      aspect: AspectA
	      fields: FieldCILs
	      %%
	      coord: Coord
	      file: File)
      in
	 featurepath#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% set
      [] set(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: set
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 set#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% list
      [] list(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: list
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 list#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% record
      [] record(UL1) then
	 ULs = UL1.sem
	 ILs = {Map ULs
		fun {$ UL2}
		   _#IL = {UL2AILTup UL2}
		in
		   IL
		end}
	 IL =
	 elem(tag: record
	      args: ILs
	      %%
	      coord: Coord
	      file: File)
      in
	 record#IL
      [] emptyrecord(...) then
	 IL =
	 elem(tag: record
	      args: nil
	      %%
	      coord: Coord
	      file: File)
      in
	 record#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% setgen
      [] setgen(UL1) then
	 _#IL1 = {UL2AILTup UL1}
	 IL =
	 elem(tag: setgen
	      arg: IL1
	      %%
	      coord: Coord
	      file: File)
      in
	 setgen#IL
      [] emptysetgen(...) then
	 IL =
	 elem(tag: setgen
	      arg: elem(tag: conj
			args: nil
			%%
			coord: Coord
			file: File)
	      %%
	      coord: Coord
	      file: File)
      in
	 setgen#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% annotation
      [] annotation(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL =
	 elem(tag: annotation
	      arg1: IL1
	      arg2: IL2
	      %%
	      coord: Coord
	      file: File)
      in
	 annotation#IL
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% features
      [] constantFeat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL = IL1#IL2
      in
	 constantFeat#IL
      [] termFeat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL = IL1#IL2
      in
	 termFeat#IL
      [] varTermFeat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL = IL1#IL2
      in
	 varTermFeat#IL
      [] typeFeat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL = IL1#IL2
      in
	 typeFeat#IL
      [] cardFeat(UL1 UL2) then
	 _#IL1 = {UL2AILTup UL1}
	 _#IL2 = {UL2AILTup UL2}
	 IL = IL1#IL2
      in
	 cardFeat#IL
      [] '!'(...) then
	 IL = elem(tag: 'card.wild'
		   arg: '!'
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.wild'#IL
      [] '?'(...) then
	 IL = elem(tag: 'card.wild'
		   arg: '?'
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.wild'#IL
      [] '*'(...) then
	 IL = elem(tag: 'card.wild'
		   arg: '*'
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.wild'#IL
      [] '+'(...) then
	 IL = elem(tag: 'card.wild'
		   arg: '+'
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.wild'#IL
      [] cardSet(UL1) then
	 IULs = UL1.sem
	 IILs = {Map IULs Helpers.iUL2IIL}
	 IL = elem(tag: 'card.set'
		   args: IILs
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.set'#IL
      [] cardInterval(IUL1 IUL2) then
	 IIL1 = {Helpers.iUL2IIL IUL1}
	 IIL2 = {Helpers.iUL2IIL IUL2}
	 IL = elem(tag: 'card.interval'
		   arg1: IIL1
		   arg2: IIL2
		   %%
		   coord: Coord
		   file: File)
      in
	 'card.interval'#IL
      else
	 Coord = {CondSelect UL coord noCoord}
      in
	 raise error1('functor':'Compiler/UL/UL2IL.ozf' 'proc':'UL2AILTup' msg:'Illformed UL expression.' info:o(UL) coord:Coord file:File) end
      end
   end
end
