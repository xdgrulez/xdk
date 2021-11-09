%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   System(show)
   
%   Inspector(inspect)

   FS(value reflect intersect intersectN union unionN sup)

   FS1(var subset) at '../../Solver/Principles/Lib/FS.ozf'
   
   Select(fs) at '../../Solver/Principles/Lib/Select.ozf'

   Helpers(cIL2A i2IIL encodeFeaturepath encode decode
	   glb pretty listUnion order2Pairs iLs2Ms
	   mapDSpec mapMSpec isIntList crunchTups multiply) at 'Helpers.ozf'

   Flat(make) at 'Flat.ozf'
export
   Make
define
   %% Make: DomainLat TypeA -> Lat
   %% Makes a set lattice with domain DomainLat.
   %% TypeA = a|i specifies whether the lattice is accumulative (a) or
   %% intersective (i).
   %% SL = M (if Lat is a domain, int or a domainTuple).
   fun {Make DomainLat TypeA}
      TagA = DomainLat.tag
   in
      case DomainLat.tag
      of domain then
	 {MakeDomainSet DomainLat TypeA}
      [] int then
	 {MakeIntSet DomainLat TypeA}
      [] domainTuple then
	 {MakeDomainTupleSet DomainLat TypeA}
      else
	 raise error1('functor':'Compiler/Lattices/Tuple.ozf' 'proc':'Make' msg:'The domain of a set must be a finite domain, and cannot of type: '#TagA info:o(DomainLat) coord:noCoord file:noFile) end
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeDomainSet: DomainLat TypeA -> Lat
   %% Makes a domain set lattice with domain DomainLat (where
   %% DomainLat is a domain lattice).
   %% TypeA = a|i specifies whether the lattice is accumulative (a) or
   %% intersective (i).
   %% SL = M.
   fun {MakeDomainSet DomainLat TypeA}
      %% cardinality
      %% the cardinality of the power set of D equals 2^(D.card)
      CardI = DomainLat.card
      if CardI==0 then
	 raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'MakeDomainSet' msg:'Cannot create set over empty domain (hint: this could be caused by using a graph principle on a dimension with an empty set of edge labels).' info:o(DomainLat) coord:noCoord file:noFile) end
      end
      CardI1 = {Pow 2 CardI}
      %%
      if {Not TypeA==a orelse TypeA==i} then
	 raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'MakeDomainSet' msg:'Unknown set type (can be either a or i).' info:o(TypeA) coord:noCoord file:noFile) end
      end
      %% top
      Top = case TypeA
	    of a then FS.value.empty
	    [] i then {FS.value.make 1#CardI}
	    end
      %% bot
      Bot = case TypeA
	    of a then {FS.value.make 1#CardI}
	    [] i then FS.value.empty
	    end
      %% glb
      fun {GlbProc M1 M2}
	 case TypeA
	 of a then {FS.union M1 M2}
	 [] i then {FS.intersect M1 M2}
	 end
      end
      fun {Glb SL1 SL2}
	 {Helpers.glb SL1 SL2 Top GlbProc}
      end
      %% select
      fun {Select1 Ms D} {Select.fs Ms D} end
      %% makeVar
      fun {MakeVar} {FS1.var.upperBound 1#CardI} end
      %% encode
      fun {EncodeProc IL Extra}
	 case IL
	 of elem(tag: set
		 args: ILs1 ...) then
	    {Helpers.iLs2Ms ILs1 DomainLat Extra}
	 [] elem(tag: order
		 args: ILs1 ...) then
	    ILss = {Helpers.order2Pairs ILs1}
	    ILs2 = {Map ILss
		    fun {$ ILs}
		       elem(tag: list
			    args: ILs)
		    end}
	 in
	    {Helpers.iLs2Ms ILs2 DomainLat Extra}
	 [] elem(tag: top ...) then
	    [Top]
	 [] elem(tag: bot ...) then
	    [Bot]
	 [] elem(tag: bounds
		 arg1: IL1
		 arg2: IL2 ...) then
	    Ms1 = {EncodeProc IL1 Extra}
	    if {Not {Length Ms1}==1} then
	       Coord1 = {CondSelect IL1 coord noCoord}
	       File1 = {CondSelect IL1 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainSet)' msg:'The lower bound of a set must not be a disjunction.' info:o(IL1) coord:Coord1 file:File1) end
	    end
	    M1 = Ms1.1
	    %%
	    Ms2 = {EncodeProc IL2 Extra}
	    if {Not {Length Ms2}==1} then
	       Coord2 = {CondSelect IL2 coord noCoord}
	       File2 = {CondSelect IL2 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainSet)' msg:'The upper bound of a set must not be a disjunction.' info:o(IL2) coord:Coord2 file:File2) end
	    end
	    M2 = Ms2.1
	    %%
	    M = {FS1.var.decl}
	    {FS1.subset M1 M}
	    {FS1.subset M M2}
	 in
	    [M]
	 else
	    Coord = {CondSelect IL coord noCoord}
	    File = {CondSelect IL file noFile}
	 in
	    raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainSet)' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc M}
	 Is = {FS.reflect.lowerBoundList M}
	 ILs = {Map Is DomainLat.decode}
      in
	 elem(tag: set
	      args: ILs)
      end
      fun {DecodeNonDetProc M}
	 LBMSpec = {FS.reflect.lowerBound M}
	 LBMSpec1 = {Helpers.mapMSpec LBMSpec DomainLat.decode}
	 UBMSpec = {FS.reflect.upperBound M}
	 UBMSpec1 = {Helpers.mapMSpec UBMSpec DomainLat.decode}
	 DSpec = {FS.reflect.card M}
      in
	 elem(tag: '_'
	      args: [LBMSpec1 UBMSpec1 DSpec])
      end
      fun {Decode M}
	 {Helpers.decode M DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc M AbbrB}
	 Is = {FS.reflect.lowerBoundList M}
	 As = {Map Is
	       fun {$ I} {DomainLat.pretty I AbbrB} end}
      in
	 As
      end
      fun {PrettyNonDetProc M AbbrB}
	 DSpec = {FS.reflect.card M}
	 I = {FS.reflect.cardOf.upperBound M}
      in
	 if I>50 then
	    LBMSpec = {FS.reflect.lowerBound M}
	    LBMSpec1 = {Helpers.mapMSpec LBMSpec
			fun {$ MSpec} {DomainLat.pretty MSpec AbbrB} end}
	    UBMSpec = {FS.reflect.upperBound M}
	    UBMSpec1 = {Helpers.mapMSpec UBMSpec
			fun {$ MSpec} {DomainLat.pretty MSpec AbbrB} end}
	 in
	    '_'(LBMSpec1 UBMSpec1 DSpec)
	 else
	    LBMIs = {FS.reflect.lowerBoundList M}
	    UBMIs = {FS.reflect.upperBoundList M}
	    LBMAs = {Map LBMIs
		     fun {$ I} {DomainLat.pretty I AbbrB} end}
	    UBMAs = {Map UBMIs
		     fun {$ I} {DomainLat.pretty I AbbrB} end}
	 in
	    '_'(LBMAs UBMAs DSpec)
	 end
      end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 o(fd: 0
	   fs: 1)
      end
      %% build lattice
      Lat =
      elem(tag: domainSet
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select1
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   domain: DomainLat
	   card: CardI1
	   setTypeA: TypeA
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeIntSet: IntLat TypeA -> Lat
   %% Makes a set of integers lattice with domain IntLat (where IntLat
   %% is an int lattice).
   %% TypeA = a|i specifies whether the lattice is
   %% accumulative (a) or intersective (i).
   %% SL = M.
   fun {MakeIntSet IntLat TypeA}
      if {Not TypeA==a orelse TypeA==i} then
	 raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'MakeIntSet' msg:'Unknown set type (can be either a or i).' info:o(TypeA) coord:noCoord file:noFile) end
      end
      %%
      SupI = FS.sup
      %% top
      Top = case TypeA
	    of a then FS.value.empty
	    [] i then {FS.value.make 1#SupI}
	    end
      %% bot
      Bot = case TypeA
	    of a then {FS.value.make 1#SupI}
	    [] i then FS.value.empty
	    end
      %% glb
      fun {GlbProc M1 M2}
	 case TypeA
	 of a then {FS.union M1 M2}
	 [] i then {FS.intersect M1 M2}
	 end
      end
      fun {Glb SL1 SL2}
	 {Helpers.glb SL1 SL2 Top GlbProc}
      end
      %% select
      fun {Select1 Ms D} {Select.fs Ms D} end
      %% makeVar
      fun {MakeVar} {FS1.var.upperBound 1#SupI} end
      %% encode
      fun {EncodeProc IL Extra}
	 case IL
	 of elem(tag: set
		 args: ILs1 ...) then
	    {Helpers.iLs2Ms ILs1 IntLat Extra}
	 [] elem(tag: order
		 args: ILs1 ...) then
	    ILss = {Helpers.order2Pairs ILs1}
	    ILs2 = {Map ILss
		    fun {$ ILs}
		       elem(tag: list
			    args: ILs)
		    end}
	 in
	    {Helpers.iLs2Ms ILs2 IntLat Extra}
	 [] elem(tag: top ...) then
	    [Top]
	 [] elem(tag: bot ...) then
	    [Bot]
	 [] elem(tag: bounds
		 arg1: IL1
		 arg2: IL2 ...) then
	    Ms1 = {EncodeProc IL1 Extra}
	    if {Not {Length Ms1}==1} then
	       Coord1 = {CondSelect IL1 coord noCoord}
	       File1 = {CondSelect IL1 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeIntSet)' msg:'The lower bound of a set must not be a disjunction.' info:o(IL1) coord:Coord1 file:File1) end
	    end
	    M1 = Ms1.1
	    %%
	    Ms2 = {EncodeProc IL2 Extra}
	    if {Not {Length Ms2}==1} then
	       Coord2 = {CondSelect IL2 coord noCoord}
	       File2 = {CondSelect IL2 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeIntSet)' msg:'The upper bound of a set must not be a disjunction.' info:o(IL2) coord:Coord2 file:File2) end
	    end
	    M2 = Ms2.1
	    %%
	    M = {FS1.var.decl}
	    {FS1.subset M1 M}
	    {FS1.subset M M2}
	 in
	    [M]
	 else
	    Coord = {CondSelect IL coord noCoord}
	    File = {CondSelect IL file noFile}
	 in
	    raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeIntSet)' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc M}
	 Is = {FS.reflect.lowerBoundList M}
	 ILs = {Map Is IntLat.decode}
      in
	 elem(tag: set
	      args: ILs)
      end
      fun {DecodeNonDetProc M}
	 LBMSpec = {FS.reflect.lowerBound M}
	 UBMSpec = {FS.reflect.upperBound M}
	 DSpec = {FS.reflect.card M}
      in
	 elem(tag: '_'
	      args: [LBMSpec UBMSpec DSpec])
      end
      fun {Decode SL}
	 {Helpers.decode SL DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc M AbbrB}
	 Is = {FS.reflect.lowerBoundList M}
      in
	 Is
      end
      fun {PrettyNonDetProc M AbbrB}
	 DSpec = {FS.reflect.card M}
	 I = {FS.reflect.cardOf.upperBound M}
      in
	 if I>50 then
	    LBMSpec = {FS.reflect.lowerBound M}
	    UBMSpec = {FS.reflect.upperBound M}
	 in
	    '_'(LBMSpec UBMSpec DSpec)
	 else
	    LBMIs = {FS.reflect.lowerBoundList M}
	    UBMIs = {FS.reflect.upperBoundList M}
	 in
	    '_'(LBMIs UBMIs DSpec)
	 end
      end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 o(fd: 0
	   fs: 1)
      end
      %% build lattice
      Lat =
      elem(tag: intSet
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select1
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   domain: IntLat
	   setTypeA: TypeA
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeDomainTupleSet: Lat TypeA -> Lat
   %% Makes a domain tuple set lattice with domain Lat (where Lat is a
   %% domain tuple lattice).
   %% TypeA = a|i specifies whether the lattice is accumulative (a) or
   %% intersective (i).
   %% SL = M.
   fun {MakeDomainTupleSet DomainLat TypeA}
      DomainLat1 = {MakeDomainSet DomainLat TypeA}
      %% top
      Top = DomainLat1.top
      %% bot
      Bot = DomainLat1.bot
      %% glb
      Glb = DomainLat1.glb
      %% select
      Select1 = DomainLat1.select
      %% makeVar
      MakeVar = DomainLat1.makeVar
      %%
      Card = DomainLat1.card
      %% (encode set generator expression)
      %% A2M: A -> M
      %% Creates the set of all tuples (encoded as integers) with the
      %% property that at least of its projections includes A.
      AMDict = {NewDictionary}
      fun {A2M A}
	 if {HasFeature AMDict A} then
	    AMDict.A
	 else
	    DomainLats = DomainLat.domains
	    Ass =
	    {Map DomainLats
	     fun {$ DomainLat2}
		As = DomainLat2.constants
	     in
		if {Member A As} then [A] else As end
	     end}
	    Ass1 = {Helpers.multiply Ass}
	    Is = {Map Ass1
		  fun {$ As1}
		     I = {DomainLat.aIs2I As1}
		  in
		     I
		  end}
	    M = {FS.value.make Is}
	 in
	    AMDict.A := M
	    M
	 end
      end
      fun {EncodeProc1 IL}
	 if IL.tag==featurepath then
	    {Helpers.encodeFeaturepath IL}
	 else
	    case IL
	    of elem(tag: conj
		    args: ILs ...) then
	       Ms = {Map ILs EncodeProc1}
	       M = case TypeA
		   of i then Top
		   [] a then Bot
		   end
	    in
	       {FS.intersectN M|Ms}
	    [] elem(tag: disj
		    args: ILs ...) then
	       Ms = {Map ILs EncodeProc1}
	       M = case TypeA
		   of i then Bot
		   [] a then Top
		   end
	    in
	       {FS.unionN M|Ms}
	    else
	       A = {Helpers.cIL2A IL}
	       M = {A2M A}
	    in
	       M
	    end
	 end
      end
      fun {EncodeProc IL Extra}
	 case IL
	 of elem(tag: setgen
		 arg: Arg ...) then
	    M = {EncodeProc1 Arg}
	 in
	    [M]
	 [] elem(tag: set
		 args: ILs ...) then
	    {Helpers.iLs2Ms ILs DomainLat Extra}
	 [] elem(tag: order
		 args: ILs ...) then
	    ILss = {Helpers.order2Pairs ILs}
	    ILs1 = {Map ILss
		    fun {$ ILs}
		       elem(tag: list
			    args: ILs)
		    end}
	 in
	    {Helpers.iLs2Ms ILs1 DomainLat Extra}
	 [] elem(tag: bounds
		 arg1: IL1
		 arg2: IL2 ...) then
	    Ms1 = {EncodeProc IL1 Extra}
	    if {Not {Length Ms1}==1} then
	       Coord1 = {CondSelect IL1 coord noCoord}
	       File1 = {CondSelect IL1 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainTupleSet)' msg:'The lower bound of a set must not be a disjunction.' info:o(IL1) coord:Coord1 file:File1) end
	    end
	    M1 = Ms1.1
	    %%
	    Ms2 = {EncodeProc IL2 Extra}
	    if {Not {Length Ms2}==1} then
	       Coord2 = {CondSelect IL2 coord noCoord}
	       File2 = {CondSelect IL2 file noFile}
	    in
	       raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainTupleSet)' msg:'The upper bound of a set must not be a disjunction.' info:o(IL2) coord:Coord2 file:File2) end
	    end
	    M2 = Ms2.1
	    %%
	    M = {FS1.var.decl}
	    {FS1.subset M1 M}
	    {FS1.subset M M2}
	 in
	    [M]
	 else
	    Coord = {CondSelect IL coord noCoord}
	    File = {CondSelect IL file noFile}
	 in
	    raise error1('functor':'Compiler/Lattices/Set.ozf' 'proc':'EncodeProc (MakeDomainTupleSet)' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc M}
	 IL = {DomainLat1.decode M}
      in
	 IL
      end
      fun {DecodeNonDetProc M}
	 LBMSpec = {FS.reflect.lowerBound M}
	 LBMSpec1 = {Helpers.mapMSpec LBMSpec DomainLat.decode}
	 UBMSpec = {FS.reflect.upperBound M}
	 UBMSpec1 = {Helpers.mapMSpec UBMSpec DomainLat.decode}
	 DSpec = {FS.reflect.card M}
      in
	 elem(tag: '_'
	      args: [LBMSpec1 UBMSpec1 DSpec])
      end
      fun {Decode SL}
	 {Helpers.decode SL DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc M AbbrB}
	 Tups = {DomainLat1.pretty M AbbrB}
	 DomainLats = DomainLat.domains
      in
	 %% This part is quite hacky: do not "crunch", i.e., do not
	 %% use set generator notation for sets over tuples with two
	 %% equal projections which include the atom '^', i.e., do not
	 %% use set generator notation for the strict partial orders
	 %% of the lexicalized order principle.
	 %%
	 %% Todo: "crunch" into specialized notation for strict
	 %% partial orders.
	 if AbbrB andthen
	    {Not ({Length DomainLats}==2 andthen
		  DomainLats.1.constants=={Nth DomainLats 2}.constants andthen
		  {Member '^' DomainLats.1.constants})}
	 then
	    A = {Helpers.crunchTups Tups DomainLats}
	 in
	    A
	 else
	    Tups
	 end
      end
      fun {PrettyNonDetProc M AbbrB}
	 LBMSpec = {FS.reflect.lowerBound M}
	 LBMSpec1 = {Helpers.mapMSpec LBMSpec
		     fun {$ MSpec} {DomainLat.pretty MSpec AbbrB} end}
	 LBMSpec2 =
	 if AbbrB andthen
	    {Helpers.isIntList LBMSpec} andthen {Not LBMSpec==nil} then
	    DomainLats = DomainLat.domains
	 in
	    {Helpers.crunchTups LBMSpec1 DomainLats}
	 else
	    LBMSpec1
	 end
	 %%
	 UBMSpec = {FS.reflect.upperBound M}
	 UBMSpec1 = {Helpers.mapMSpec UBMSpec
		     fun {$ MSpec} {DomainLat.pretty MSpec AbbrB} end}
	 UBMSpec2 =
	 if AbbrB andthen
	    {Helpers.isIntList UBMSpec} andthen {Not UBMSpec==nil} then
	    DomainLats = DomainLat.domains
	 in
	    {Helpers.crunchTups UBMSpec1 DomainLats}
	 else
	    UBMSpec1
	 end
	 %%
	 DSpec = {FS.reflect.card M}
      in
	 '_'(LBMSpec2 UBMSpec2 DSpec)
      end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      Count = DomainLat1.count
      %% build lattice
      Lat =
      elem(tag: domainTupleSet
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select1
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   domain: DomainLat
	   card: Card
	   setTypeA: TypeA
	   %%
	   encodeProc: EncodeProc
	   encodeProc1: EncodeProc1)
   in
      Lat
   end
end

