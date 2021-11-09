%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   Inspector(inspect)
%   System(show)

   FD(sup plus times)

   FS(value)

   FD1(plus times) at '../../Solver/Principles/Lib/FD.ozf'
export
   Clean

   CrunchTups
   
   MapDSpec
   MapMSpec
   ExpandMSpec
   
   IsIntList

   CIL2A
   IIL2I
   CILIIL2AI
   A2CIL
   I2IIL
   AI2CILIIL
   VIL2A
   A2VIL

   AllEqual

   ListUnion
   
   AppendList

   Sum
   SumDs
   Prod
   ProdDs
   
   Order2Pairs

   EncodeFeaturepath
   Encode
   Multiply
   DecodeFeaturepath
   Decode
   PrettyFeaturepath
   Pretty
   Glb

   ILs2Ms
prepare
   ListDrop = List.drop
   ListFoldLInd = List.foldLInd
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
   RecordFilterInd = Record.filterInd
   RecordAll = Record.all
   RecordMap = Record.map
   RecordMapInd = Record.mapInd
   RecordToList = Record.toList
define
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
	 raise error1('functor':'Compiler/Lattices/Helpers.ozf' 'proc':'Clean' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
      end
   end
   %%
   V2A = VirtualString.toAtom
   %%
   fun {CrunchTups Tups Lats}
      Tups1 = {Map Tups
	       fun {$ Tup} {RecordMap Tup fun {$ A} [A] end} end}
      Tups2 = {CollapseTups Tups1}
      Tups3 = {FilterTups Tups2 Lats}
      fun {As2A As}
	 A1|As1 = As
	 V = {FoldL As1
	      fun {$ AccV A} AccV#'|'#A end A1}
	 V1 = if {Width V}==0 then V else '('#V#')' end
	 A = {V2A V1}
      in
	 A
      end
      fun {Tup2A Tup}
	 Ass = {RecordToList Tup}
      in
	 if Ass==nil then
	    '$'
	 else
	    As1|Ass1 = Ass
	    A1 = {As2A As1}
	    V = {FoldL Ass1
		 fun {$ AccV As} 
		    A = {As2A As}
		 in
		    AccV#' \& '#A
		 end '$ '#A1}
	    A = {V2A V}
	 in
	    A
	 end
      end
      fun {Tups2A Tups}
	 Tup1|Tups1 = Tups
	 A1 = {Tup2A Tup1}
	 V = {FoldL Tups1
	      fun {$ AccV Tup}
		 A = {Tup2A Tup}
	      in
		 AccV#' | '#A
	      end A1}
	 V1 = if {Width V}==0 then V else '('#V#')' end
	 A = {V2A V1}
      in
	 A
      end
      A = {Tups2A Tups3}
   in
      A
   end
   %% Diff: Tup1 Tup2 -> (I#X#Y)s
   fun {DiffTups Tup1 Tup2}
      Xs = {RecordToList Tup1}
      Ys = {RecordToList Tup2}
      Dict = {NewDictionary}
      for
	 I in 1..{Length Xs}
	 X in Xs
	 break:Break
      do
	 Y = {Nth Ys I}
      in
	 if {Not X==Y} then
	    if {HasFeature Dict diffs} then
	       Dict.diffs := (I#X#Y)|Dict.diffs
	       {Break}
	    else
	       Dict.diffs := [I#X#Y]
	    end
	 end
      end
   in
      {CondSelect Dict diffs nil}
   end
   %% Collapse: Tups -> Tups1
   %% e.g.:
   %% [[third]#[masc]#[pl]#[def]#[nom]
   %%  [third]#[masc]#[sg]#[def]#[nom]
   %%  [first]#[masc]#[sg]#[def]#[nom]]
   %% ->
   %% [[third]#[masc]#[sg pl]#[def]#[nom]
   %%  [first]#[masc]#[sg]   #[def]#[nom]]
   fun {CollapseTups Tups}
      fun {CollapseTups1 Tups}
	 if {Length Tups}<2 then
	    %% cannot (and need not) collapse Tups if |Tups|<2
	    Tups
	 else
	    %% take a look at the first two tuples Tup1 and Tup2 of Tups
	    %% and bind the remaining tuples to Tups1
	    Tup1|Tup2|Tups1 = Tups
	    %% find out the differences between Tup1 and Tup2
	    IXYTups = {DiffTups Tup1 Tup2}
	    %% collapse Tup1 and Tup2 based on the differences found
	    Tups2 =
	    case {Length IXYTups}
	    of 0 then
	       %% 1) Tup1 and Tup2 are equal, just keep Tup1
	       [Tup1]
	    [] 1 then
	       %% 2) if Tup1 and Tup2 are different at precisely one
	       %% position I, append the projections at that position
	       %% to get Tup3
	       IXYTup = IXYTups.1
	       I#_#Y = IXYTup
	       Tup3 =
	       {RecordMapInd Tup1
		fun {$ J X}
		   if J==I then
		      {Append X Y}
		   else
		      X
		   end
		end}
	    in
	       [Tup3]
	    else
	       %% 3) if Tup1 and Tup2 are different at more than one
	       %% position, keep both (cannot collapse).
	       [Tup1 Tup2]
	    end
	    %% collapse the remaining tuples Tups1
	    Tups3 = {CollapseTups1 Tups1}
	    %% reunite the result of collapsing the first two tuples
	    %% (Tups2) and the result of collapsing the remaining
	    %% tuples (Tups3) to get Tups4
	    Tups4 = {Append Tups2 Tups3}
	 in
	    Tups4
	 end
      end
      %% collapse Tups
      Tups1 = {CollapseTups1 Tups}
   in
      %% Return Tups1 if Tups have not changed anymore through
      %% collapsation, continue collapsing Tups1 otherwise.
      if Tups==Tups1 then
	 Tups1
      else
	 {CollapseTups Tups1}
      end
   end
   %% FilterTups: Tups Lats -> Tups1
   %% e.g.:
   %% [[third]#[masc]#[sg pl]#[def]#[nom]
   %%  [first]#[masc]#[sg]   #[def]#[nom]]
   %% ->
   %% [[third]#[masc]#[def]#[nom]
   %%  [first]#[masc]#[sg]#[def]#[nom]]
   fun {FilterTups Tups Lats}
      ProjICardITups = {ListMapInd Lats
			fun {$ ProjI Lat}
			   CardI = Lat.card
			in
			   ProjI#CardI
			end}
      ProjICardIRec = {ListToRecord o ProjICardITups}
      Tups1 =
      {Map Tups
       fun {$ Tup}
	  {RecordFilterInd Tup
	   fun {$ ProjI As}
	      CardI = ProjICardIRec.ProjI
	   in
	      {Length As}<CardI
	   end}
       end}
   in
      Tups1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MapDSpec: DSpec Proc -> DSpec1
   %% The syntax of a description of a finite domain integer is:
   %%    dom_descr   ::= simpl_descr | compl(simpl_descr)
   %%    simpl_descr ::= range_descr | [range_descr+]
   %%    range_descr ::= integer | integer#integer
   %%    integer     ::= {0,...,134 217 726}
   fun {MapDSpec DSpec Proc}
      fun {MapDSpec1 DSpec}
	 case DSpec
	 of compl(DSpec) then
	    compl({MapDSpec1 DSpec})
	 [] I1#I2 then
	    {Proc I1}#{Proc I2}
	 elseif {IsList DSpec} then
	    {Map DSpec MapDSpec1}
	 else
	    {Proc DSpec}
	 end
      end
   in
      {MapDSpec1 DSpec}
   end
   %% MapMSpec: MSpec Proc -> MSpec1
   %% The syntax of a description of a finite set of integers is:
   %%    set_descr   ::= simpl_descr | compl(simpl_descr)
   %%    simpl_descr ::= range_descr | nil | [range_descr+]
   %%    range_descr ::= integer | integer#integer
   %%    integer     ::= {0,...,134 217 726}
   fun {MapMSpec MSpec Proc}
      fun {MapMSpec1 MSpec}
	 case MSpec
	 of compl(MSpec) then
	    compl({MapMSpec1 MSpec})
	 [] I1#I2 then
	    {Proc I1}#{Proc I2}
	 elseif {IsList MSpec} then
	    {Map MSpec MapMSpec1}
	 else
	    {Proc MSpec}
	 end
      end
   in
      {MapMSpec1 MSpec}
   end
   fun {ExpandMSpec MSpec Proc}
      fun {ExpandMSpec1 MSpec}
	 case MSpec
	 of I1#I2 then
	    for I in I1..I2 collect:Collect do
	       X = {Proc I}
	    in
	       {Collect X}
	    end
	 elseif {IsList MSpec} then
	    for MSpec1 in MSpec append:Append do
	       Xs = {ExpandMSpec1 MSpec1}
	    in
	       {Append Xs}
	    end
	 else
	    X = {Proc MSpec}
	 in
	    [X]
	 end
      end
   in
      {ExpandMSpec1 MSpec}
   end
   %% IsIntList: X -> B
   %% Returns true if X is a list of integers, and false otherwise.
   fun {IsIntList X}
      if {IsList X} then
	 {All X IsInt}
      else
	 false
      end
   end
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
   %% CILIIL2AI: CILIIL -> AI
   %% Transforms an IL constant/integer CILIIL into the corresponding
   %% atom/integer AI.
   fun {CILIIL2AI CILIIL}
      case CILIIL.tag
      of constant then {CIL2A CILIIL}
      [] integer then {IIL2I CILIIL}
      else raise error1('functor':'Compiler/Lattices/Helpers.ozf' 'proc':'CILIIL2AI' msg:'IL constant or integer expected.' info:o(CILIIL) coord:noCoord file:noFile) end
      end
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
   %% AI2CILIIL: AI -> CILIIL
   %% Transforms an atom/integer AI into the corresponding IL
   %% constant/integer CILIIL.
   fun {AI2CILIIL AI}
      if {IsAtom AI} then {A2CIL AI}
      elseif {IsInt AI} then {I2IIL AI}
      else raise error1('functor':'Compiler/Lattices/Helpers.ozf' 'proc':'AI2CILIIL' msg:'Atom or integer expected.' info:o(AI) coord:noCoord file:noFile) end
      end
   end
   %% VIL2A: VIL -> A
   %% Transforms an IL variable VIL into the corresponding atom A.
   fun {VIL2A VIL} VIL.data end
   %% A2VIL: A -> VIL
   %% Transforms an atom into the corresponding IL variable VIL.
   fun {A2VIL A}
      elem(tag: variable
	   data: A)
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AllEqual: Xs -> B
   %% Returns true if all elements in Xs are equal, and false if not.
   fun {AllEqual Xs}
      Ys =
      {FoldL Xs
       fun {$ Acc X}
	  if {Member X Acc} then Acc
	  else X|Acc end
       end nil}
   in
      Ys==nil orelse {Length Ys}==1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ListUnion: Xs Ys -> Zs
   %% Returns the "union" Zs of the lists Xs and Ys.
   %% X, Y and Z can be of any type.
   %% The "union" is defined as the concatenation of Xs and Ys, where
   %% all elements in Xs which also occur in Ys are removed.
   %% E.g.: {ListUnion [a b c] [a d e]} yields [b c a d e].
   fun {ListUnion Xs Ys}
      Zs =
      {FoldR Xs
       fun {$ X AccXs}
	  if {Member X AccXs} then
	     AccXs
	  else
	     X|AccXs
	  end
       end Ys}
   in
      Zs
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Sum: Is -> I
   %% Calculates the sum of all Is.
   fun {Sum Is}
      {FoldL Is fun {$ AccI I} AccI+I end 0}
   end
   %% SumDs: Ds -> D
   %% Calculates the sum of all Ds.
   fun {SumDs Ds}
      {FoldL Ds fun {$ AccD D} {FD1.plus AccD D} end 0}
   end
   %% Prod: Is -> I
   %% Calculates the product of all Is.
   fun {Prod Is}
      {FoldL Is fun {$ AccI I} AccI*I end 1}
   end
   %% ProdDs: Ds -> D
   %% Calculates the product of all Ds.
   fun {ProdDs Ds}
      {FoldL Ds fun {$ AccD D} {FD1.times AccD D} end 1}
   end
   %% Order2Pairs: Xs -> Xss
   %% Transforms the order Xs into the list of lists Xss representing
   %% the order relation of Xs. E.g.:
   %%   [a b c] => [[a b] [a c] [b c]]
   fun {Order2Pairs Xs}
      {ListFoldLInd Xs
       fun {$ I AccXss X}
	  Ys = {ListDrop Xs I}
	  Xss = {Map Ys fun {$ Y} [X Y] end}
       in
	  {Append AccXss Xss}
       end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% EncodeFeaturepath: IL -> SL
   %% Encodes an IL feature path.
   fun {EncodeFeaturepath IL}
      elem(tag: featurepath 
	   root: RootA
	   dimension: VIL
	   dimension_idref: IDA
	   aspect: AspectA
	   fields: FieldCILs ...) = IL
      DVA = {VIL2A VIL}
      FieldAs = {Map FieldCILs CIL2A}
      SL = featurepath(root: RootA
		       dimension: DVA
		       dimension_idref: IDA
		       aspect: AspectA
		       fields: FieldAs)
   in
      SL
   end
   %%
   %% DecodeFeaturepath: SL -> IL
   %% Decodes a SL feature path.
   fun {DecodeFeaturepath SL}
      featurepath(root: RootA
		  dimension: DVA
		  dimension_idref: DIDA
		  aspect: AspectA
		  fields: FieldAs ...) = SL
      VIL = {A2VIL DVA}
      FieldCILs = {Map FieldAs A2CIL}
   in
      elem(tag: featurepath 
	   root: RootA
	   dimension: VIL
	   dimension_idref: DIDA
	   aspect: AspectA
	   fields: FieldCILs)
   end
   %%
   %% Encode: IL Lat Extra -> SLs
   %% Encodes an IL expression IL into a list of SL expression SLs.
   %%
   %% Extra is a tuple AClassILTChRec#AClassSLsDict#FillPartialRecB
   %% including a record and a dictionary to gain speed, and the
   %% boolean FillPartialRecB. If FillPartialRecB==true, the missing
   %% attributes of partially specified records are filled with the
   %% respective top values, otherwise the attributes are ignored and
   %% not filled.
   fun {Encode IL Lat Extra}
      SLs =
      case IL
      of elem(tag: 'class.ref'
	      key: KeyA ...) then
% comment out the following three lines when activating the optimization
% (as soon as Mozart is fixed wrt this bug...)	 
	 AClassILTChRec = Extra.1
	 IL = AClassILTChRec.KeyA
	 SLs = {Encode IL Lat Extra}
% the BIG bug is here! If we use the caching below, the grammar file
% BIG/10.ExportXDG.xml breaks the grammar file compiler (strangely
% does not happen when garbage collection is switched off in the Oz
% Panel).
% 	 AClassILTChRec = Extra.1
% 	 AClassSLsDict = Extra.2
% 	 SLs =
% 	 if {HasFeature AClassSLsDict KeyA} then
% 	    SLs = AClassSLsDict.KeyA
% 	 in
% 	    SLs
% 	 else
% 	    IL = AClassILTChRec.KeyA
% 	    SLs = {Encode IL Lat Extra}
% 	    AClassSLsDict.KeyA := SLs
% 	 in
% 	    SLs
% 	 end
% 	 SLs
      in
	 SLs
      [] elem(tag: featurepath ...) then
	 SL = {EncodeFeaturepath IL}
      in
	 [SL]
      [] elem(tag: conj
	      args: ILs ...) then
	 SLss = {Map ILs
		 fun {$ IL}
		    SLs = {Encode IL Lat Extra}
		 in
		    SLs
		 end}
	 SLss1 = {Multiply SLss}
	 SLs = {Map SLss1
		fun {$ SLs}
		   SL =
		   {FoldL SLs
		    fun {$ AccSL SL}
		       {Lat.glb AccSL SL}
		    end Lat.top}
		in
		   SL
		end}
      in
	 SLs
      [] elem(tag: disj
	      args: ILs ...) then
	 SLs =
	 for IL in ILs append:Append do
	    SLs = {Encode IL Lat Extra}
	 in
	    {Append SLs}
	 end
      in
	 SLs
      [] elem(tag: top ...) then
	 [Lat.top]
      [] elem(tag: bot ...) then
	 [Lat.bot]
      else
	 SLs = {Lat.encodeProc IL Extra}
      in
	 SLs
      end
   in
      SLs
   end
   %%
   fun {Multiply Xss}
      Xss1 =
      if Xss==nil then
	 [nil]
      else
	 Xs1|Xss1 = Xss
	 Xss2 = {Map Xs1
		 fun {$ X} [X] end}
      in
	 {FoldL Xss1
	  fun {$ AccXss Xs}
	     for AccXs in AccXss collect:Collect do
		for X in Xs do
		   Xss = {Append AccXs [X]}
		in
		   {Collect Xss}
		end
	     end
	  end Xss2}
      end
   in
      Xss1
   end
   %%
   %% Decode: SL DecodeDetProc DecodeNonDetProc -> IL
   %% Decodes a SL expression SL.  Uses DecodeDetProc for decoding if
   %% {IsDet SL}, and DecodeNonDetProc otherwise.
   fun {Decode SL DecodeDetProc DecodeNonDetProc}
      if {IsDet SL} then
	 case SL
	 of featurepath(...) then
	    {DecodeFeaturepath SL}
	 else
	    {DecodeDetProc SL}
	 end
      else
	 {DecodeNonDetProc SL}
      end
   end      
   %%
   %% PrettyFeaturepath: SL -> OL
   %% Prettifies a SL feature path.
   fun {PrettyFeaturepath SL}
      featurepath(root: RootA
		  dimension: DVA
		  dimension_idref: DIDA
		  aspect: AspectA
		  fields: FieldAs ...) = SL
      V =
      RootA#'.'#DVA#'('#DIDA#')'#'.'#AspectA#
      {FoldL FieldAs
       fun {$ AccV A} AccV#'.'#A end ''}
      A = {V2A V}
   in
      A
   end
   %% Pretty: SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB -> IL
   %% Prettifies a SL expression SL.
   %% Uses PrettyDetProc for decoding if {IsDet1 SL}, and
   %% PrettyNonDetProc otherwise.
   %% If AbbrB then abbreviates lattice top and lattice bottom (here,
   %% Top is lattice top, Bot is lattice bottom).
   fun {Pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      if {IsDet1 SL} then
	 case SL
	 of featurepath(...) then {PrettyFeaturepath SL}
	 elseif AbbrB andthen SL==Top then top
	 elseif AbbrB andthen SL==Bot then bot
	 else {PrettyDetProc SL AbbrB}
	 end
      else
	 {PrettyNonDetProc SL AbbrB}
      end
   end
   %%
   V2A = VirtualString.toAtom
   %%
   fun {IsDet1 SL}
      if {IsDet SL} andthen {IsRecord SL} then
	 {RecordAll SL IsDet1}
      elseif {IsDet SL} andthen {IsList SL} then
	 {All SL IsDet1}
      else
	 {IsDet SL}
      end
   end
   %%
   %% Glb: SL1 SL2 TopSL GlbProc -> SL
   %% Calculates the greatest lower bound of SL1 and SL2, using
   %% lattice top TopSL, and GlbProc: SL1 SL2 -> SL.
   %% Only starts GlbProc if necessary to gain speed.
   fun {Glb SL1 SL2 TopSL GlbProc}
      if SL1==TopSL then SL2
      elseif SL2==TopSL then SL1
      elseif SL1==SL2 then SL1
      else {GlbProc SL1 SL2}
      end
   end
   %%
   %% ILs2Ms: ILs Lat Extra -> Ms
   %% Convert list of ILs to Ms. Lat is the domain lattice.
   fun {ILs2Ms ILs Lat Extra}
      Iss = {Map ILs
	     fun {$ IL}
		Is = {Lat.encode IL Extra}
	     in
		Is
	     end}
      Iss1 = {Multiply Iss}
   in
      {Map Iss1 FS.value.make}
   end
end
