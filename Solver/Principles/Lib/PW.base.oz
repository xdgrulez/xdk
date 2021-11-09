%\define FLATZINC_FLAWED
functor
import
   System(show)
%   Inspector(inspect)
   
   FD at 'FD.ozf'
   FS at 'FS.ozf'
   Select at 'Select.ozf'
   
   Helpers(noDoubles) at 'Helpers.ozf'
   ListUtils(subtractNth:SubtractNth) at 'ListUtils.ozf'

   Opti(isIn) at 'Opti.ozf'

   Domain(make) at '../../../Compiler/Lattices/Domain.ozf'
   Set(make) at '../../../Compiler/Lattices/Set.ozf'
   Tuple1(make) at '../../../Compiler/Lattices/Tuple.ozf'
   
   Prechk(
      decheck:Decheck
      conj:PreConj
      disj:PreDisj
      impl:PreImpl
      equi:PreEqui
      'in':PreIn
      'notin':PreNotin
      boolDotSet:PreBoolDotSet
      ifThenElseSet:PreIfThenElseSet
      zero:Zero
      one:One
      zeroOrOne:ZeroOrOne
      oneOrMore:OneOrMore) at 'PW.prechecked.ozf'
export
   T2Lat
   %%
   ForallDom
   ExistsDom
   ExistsOneDom
   ForallNodes
   ExistsNodes
   ExistsOneNodes
   %%
   SetForallDom
   SetExistsDom
   SetExistsOneDom
   SetForallNodes
   SetExistsNodes
   SetExistsOneNodes
   %%
   Nega
   Conj
   Disj
   Impl
   Equi
   Eq
   Neq
   %%
   In
   Notin
   Subseteq
   Disjoint
   Intersect
   Union
   Minus
   %%
   Ledge
   Edge
   Ldom
   Dom
   Domeq
   Prec
   Word
   %%
   BoolDotSet
   IfThenElseSet
   one:DecheckedOne
   oneOrMore:DecheckedOneOrMore
   zero:DecheckedZero
   zeroOrOne:DecheckedZeroOrOne
   OneMotherL
   OneMother
   ZeroOrOneMothersL
   ZeroOrOneMothers
   OneOrMoreMothersL
   OneOrMoreMothers
   ZeroMothersL
   ZeroMothers
   %%
   OneDaughterL
   OneDaughter
   ZeroOrOneDaughtersL
   ZeroOrOneDaughters
   OneOrMoreDaughtersL
   OneOrMoreDaughters
   ZeroDaughtersL
   ZeroDaughters
   %%
   Projective
   %%
   EqPrecDaughtersL
   DaughtersLPrecEq
   DaughtersLPrecDaughtersL
   %%
   DisjointDaughtersL
   DisjointSubtreesL
   %%
   MkDyn
prepare
   ListNumber = List.number
   MapInd = List.mapInd
define
   A2S = Atom.toString
   %%
   fun {LatUnify Lat1 Lat2}
      TagA1 = Lat1.tag
      TagA2 = Lat2.tag
   in
      if {Not TagA1==TagA2} then
	 raise error1('functor':'Solver/Principles/Lib/PW.base.ozf' 'proc':'LatUnify' msg:'Error: type clash in PW principle. Tags: '#TagA1#' and '#TagA2#'.' info:o(Lat1 Lat2) coord:noCoord file:noFile) end
      else
	 case TagA1
	 of domain then
	    if {Not Lat1.constants==Lat2.constants} then
	       raise error1('functor':'Solver/Principles/Lib/PW.base.ozf' 'proc':'LatUnify' msg:'Error: domain type clash in PW principle.' info:o(Lat1.constants Lat2.constants Lat1 Lat2) coord:noCoord file:noFile) end
	    end
	 [] domainTuple then
	    for DomainLat in Lat1.domains I in 1..Lat1.card do
	       _ = {LatUnify DomainLat {Nth Lat2.domains I}}
	    end
	 [] set then
	    _ = {LatUnify Lat1.domain Lat2.domain}
	 end
      end
      Lat1
   end
   %%
   fun {T2Lat T NodeRecs G Principle}
      fun {T2Lat1 T}
	 case T
	 of dom(As) then
	    {Domain.make As}
	 [] label(A) then
	    S = {A2S A}
	    DIDA = if {Char.isUpper S.1} then {Principle.dVA2DIDA A}
		   else A
		   end
	 in
	    {G.dIDA2LabelLat DIDA}
	 [] node then
	    Is = {ListNumber 1 {Length NodeRecs} 1}
	 in
	    {Domain.make Is}
	 [] dim then
	    {Domain.make G.usedDIDAs}
	 [] 'attr' then
	    EntryAttrsAs =
	    for DIDA in G.usedDIDAs append:Append1 do
	       EntryLat = {G.dIDA2EntryLat DIDA}
	       EntryAs = {Arity EntryLat.record}
	       AttrsLat = {G.dIDA2AttrsLat DIDA}
	       AttrsAs = {Arity AttrsLat.record}
	       EntryAttrsAs = {Append EntryAs AttrsAs}
	       EntryAttrsAs1 = {Helpers.noDoubles EntryAttrsAs}
	    in
	       {Append1 EntryAttrsAs1}
	    end
	 in
	    {Domain.make EntryAttrsAs}
	 [] word then
	    {Domain.make G.as}
	 [] tset(Dom) then
	    DomLat = {T2Lat1 Dom}
	 in
	    {Set.make DomLat a}
	 [] ttuple(Doms) then
	    DomLats = {Map Doms T2Lat1}
	 in
	    {Tuple1.make DomLats}
	 [] tdom(SetT) then
	    SetLat = {T2Lat1 SetT}
	    DomLat = SetLat.domain
	 in
	    DomLat
	 [] tproj(TupleT I) then
	    TupleLat = {T2Lat1 TupleT}
	    DomLat = {Nth TupleLat.domains I}
	 in
	    DomLat
	 [] entry(A1 A2) then
	    S1 = {A2S A1}
	    DIDA = if {Char.isUpper S1.1} then {Principle.dVA2DIDA A1}
		   else A1
		   end
	    EntryLat = {G.dIDA2EntryLat DIDA}
	    Lat = EntryLat.record.A2
	 in
	    Lat
	 [] attrs(A1 A2) then
	    S1 = {A2S A1}
	    DIDA = if {Char.isUpper S1.1} then {Principle.dVA2DIDA A1}
		   else A1
		   end
	    AttrsLat = {G.dIDA2AttrsLat DIDA}
	    Lat = AttrsLat.record.A2
	 in
	    Lat
	 [] eq(T1|Ts) then
	    Lat1 = {T2Lat1 T1}
	    Lat =
	    {FoldL Ts
	     fun {$ AccLat T2}
		Lat2 = {T2Lat1 T2}
	     in
		{LatUnify AccLat Lat2}
	     end Lat1}
	 in
	    Lat
	 end
      end
   in
      {T2Lat1 T}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Logical quantifiers
   fun {QuantifyDom A DomLat Proc}
      CardI = DomLat.card
      DomSetM = {FS.value.make 1#CardI}
      %%
      M = {FS.var.decl}
   in
      {FS.subset M DomSetM}
      for A in DomLat.constants do
	 I = {DomLat.aI2I A}
      in
	 {FD.equi
	  {FS.reified.include I M}
	  {Proc A I} 1}
      end
      case A
      of forall then {FD.reified.equal {FS.card M} CardI}
      [] exists then {FD.reified.greatereq {FS.card M} 1}
      [] existsOne then {FD.reified.equal {FS.card M} 1}
      end
   end
   %%
   fun {ForallDom DomLat Proc}
      {QuantifyDom forall DomLat Proc}
   end
   %%
   fun {ExistsDom DomLat Proc}
      {QuantifyDom exists DomLat Proc}
   end
   %%
   fun {ExistsOneDom DomLat Proc}
      {QuantifyDom existsOne DomLat Proc}
   end
   %%
   fun {QuantifyNodes A NodeRecs Proc}
      NodeRecsI = {Length NodeRecs}
      NodeSetM = {FS.value.make 1#NodeRecsI}
      %%
      M = {FS.var.decl}
   in
      {FS.subset M NodeSetM}
      for NodeRec in NodeRecs do
	 {FD.equi
	  {FS.reified.include NodeRec.index M}
	  {Proc NodeRec} 1}
      end
      case A
      of forall then {FD.reified.equal {FS.card M} NodeRecsI}
      [] exists then {FD.reified.greatereq {FS.card M} 1}
      [] existsOne then {FD.reified.equal {FS.card M} 1}
      end
   end
   %%
   fun {ForallNodes NodeRecs Proc}
      {QuantifyNodes forall NodeRecs Proc}
   end
   %%
   fun {ExistsNodes NodeRecs Proc}
      {QuantifyNodes exists NodeRecs Proc}
   end
   %%
   fun {ExistsOneNodes NodeRecs Proc}
      {QuantifyNodes existsOne NodeRecs Proc}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Logical quantifiers (set versions)
   %%
   %% These are used by the quad optimizer
   fun {SetQuantifyDom DomLat Proc}
      {Map DomLat.constants
       fun {$ A}
	  I = {DomLat.aI2I A}
       in
	  {Proc A I}
       end}
   end
   %%
   fun {SetQuantifyNodes NodeRecs Proc}
      {Map NodeRecs Proc}
   end
   %%
   fun {SetForall Ms} {FS.intersectN Ms} end
   %%
   fun {SetExists Ms} {FS.unionN Ms} end
   %%
   proc {SetExistsOne Ms Rslt}
      UniqueMs = {MapInd Ms
		  fun {$ I M}
		     OthersUnion = {FS.unionN {SubtractNth Ms I}}
		  in
		     {FS.diff M OthersUnion}
		  end}
   in
      {FS.unionN UniqueMs}
   end
   %%
   fun {SetExistsOneNodes NodeRecs Proc}
      {SetExistsOne {SetQuantifyNodes NodeRecs Proc}}
   end
   %%
   fun {SetExistsNodes NodeRecs Proc}
      {SetExists {SetQuantifyNodes NodeRecs Proc}}
   end
   %%
   fun {SetForallNodes NodeRecs Proc}
      {SetForall {SetQuantifyNodes NodeRecs Proc}}
   end
   %%
   fun {SetExistsOneDom DomLat Proc}
      {SetExistsOne {SetQuantifyDom DomLat Proc}}
   end
   %%
   fun {SetExistsDom DomLat Proc}
      {SetExists {SetQuantifyDom DomLat Proc}}
   end
   %%
   fun {SetForallDom DomLat Proc}
      {SetForall {SetQuantifyDom DomLat Proc}}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% logical connectives
   fun {Nega D}
      {FD.nega D}
   end
   %%
   fun {Conj D1 Proc} {Decheck {PreConj D1 Proc}} end
   %%
   fun {Disj D1 Proc} {Decheck {PreDisj D1 Proc}} end
   %%
   fun {Impl D1 Proc} {Decheck {PreImpl D1 Proc}} end
   %%
   fun {Equi D1 Proc} {Decheck {PreEqui D1 Proc}} end
   %%
   fun {Eq X1 X2}
      case {Value.status X1}.1
      of int then X1=:X2
      [] fset then {FS.reified.equal X1 X2}
      end
   end
   %%
   fun {Neq X1 X2}
      {FD.nega {Eq X1 X2}}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Set connectives
   fun {In D M} {Decheck {PreIn D M}}  end
   %%
   fun {Notin D M} {Decheck {PreNotin D M}} end
   %%
   fun {BoolDotSet B M} {Decheck {PreBoolDotSet B M}} end
   %%
   fun {IfThenElseSet B M1 M2} {Decheck {PreIfThenElseSet B M1 M2}} end
   %%
   fun {Subseteq M1 M2}
      {FS.reified.subset M1 M2}
   end
   %%
   fun {Disjoint M1 M2}
      {FS.reified.disjoint M1 M2}
   end
   %%
   fun {Intersect M1 M2 M3}
      {FS.reified.equal {FS.intersect M1 M2} M3}
   end
   %%
   fun {Union M1 M2 M3}
      {FS.reified.equal {FS.union M1 M2} M3}
   end
   %%
   fun {Minus M1 M2 M3}
      {FS.reified.equal {FS.diff M1 M2} M3}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Multigraph connectives
   fun {Ledge NodeRec NodeRec1 LA DIDA} 
      {PreIn NodeRec1.index NodeRec.DIDA.model.daughtersL.LA}
   end
   %%
   fun {Edge NodeRec NodeRec1 DIDA}
      {PreIn NodeRec1.index NodeRec.DIDA.model.daughters}
   end
   %%
   fun {Ldom NodeRec NodeRec1 LA DIDA}
      {PreIn NodeRec1.index NodeRec.DIDA.model.downL.LA}
   end
   %%
   fun {Dom NodeRec NodeRec1 DIDA}
      {PreIn NodeRec1.index NodeRec.DIDA.model.down}
   end
   %%
   fun {Domeq NodeRec NodeRec1 DIDA}
      {PreIn NodeRec1.index NodeRec.DIDA.model.eqdown}
   end
   %%
   fun {Prec NodeRec NodeRec1}
\ifndef FLATZINC_FLAWED
      {FD.reified.less {FS.int.max NodeRec.pos} {FS.int.min NodeRec1.pos}}
\else
      _
\endif
   end
   %%
   fun {Word NodeRec A}
      if NodeRec.word==A then 1 else 0 end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Optimizations
   fun {DecheckedOne M}
      {Decheck {One M}}
   end
   fun {DecheckedOneOrMore M}
      {Decheck {OneOrMore M}}
   end
   fun {DecheckedZero M}
      {Decheck {Zero M}}
   end
   fun {DecheckedZeroOrOne M}
      {Decheck {ZeroOrOne M}}
   end
   fun {OneMotherL NodeRec LA DIDA}
      {One NodeRec.DIDA.model.mothersL.LA}
   end
   fun {OneMother NodeRec DIDA}
      {One NodeRec.DIDA.model.mothers}
   end
   %%
   fun {ZeroOrOneMothersL NodeRec LA DIDA}
      {ZeroOrOne NodeRec.DIDA.model.mothersL.LA}
   end
   fun {ZeroOrOneMothers NodeRec DIDA}
      {ZeroOrOne NodeRec.DIDA.model.mothers}
   end
   %%
   fun {OneOrMoreMothersL NodeRec LA DIDA}
      {OneOrMore NodeRec.DIDA.model.mothersL.LA}
   end
   fun {OneOrMoreMothers NodeRec DIDA}
      {OneOrMore NodeRec.DIDA.model.mothers}
   end
   %%
   fun {ZeroMothersL NodeRec LA DIDA}
      {Zero NodeRec.DIDA.model.mothersL.LA}
   end
   fun {ZeroMothers NodeRec DIDA}
      {Zero NodeRec.DIDA.model.mothers}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {OneDaughterL NodeRec LA DIDA}
      {One NodeRec.DIDA.model.daughtersL.LA}
   end
   fun {OneDaughter NodeRec DIDA}
      {One NodeRec.DIDA.model.daughters}
   end
   %%
   fun {ZeroOrOneDaughtersL NodeRec LA DIDA}
      {ZeroOrOne NodeRec.DIDA.model.daughtersL.LA}
   end
   fun {ZeroOrOneDaughters NodeRec DIDA}
      {ZeroOrOne NodeRec.DIDA.model.daughters}
   end
   %%
   fun {OneOrMoreDaughtersL NodeRec LA DIDA}
      {OneOrMore NodeRec.DIDA.model.daughtersL.LA}
   end
   fun {OneOrMoreDaughters NodeRec DIDA}
      {OneOrMore NodeRec.DIDA.model.daughters}
   end
   %%
   fun {ZeroDaughtersL NodeRec LA DIDA}
      {Zero NodeRec.DIDA.model.daughtersL.LA}
   end
   fun {ZeroDaughters NodeRec DIDA}
      {Zero NodeRec.DIDA.model.daughters}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {Projective NodeRecs DIDA}
\ifndef FLATZINC_FLAWED
      D = {FD.int 0#1}
      PosMs = {Map NodeRecs
	       fun {$ NodeRec} NodeRec.pos end}
   in
      thread
	 or for NodeRec in NodeRecs do
	       {FS.int.convex {Select.union PosMs NodeRec.DIDA.model.eqdown}}
	    end
	    D=1
	 [] D=0
	 end
      end
      D
\else
      _
\endif
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {ReifiedIntSeq Mv}
\ifndef FLATZINC_FLAWED
      D = {FD.int 0#1}
   in
      thread
	 or {FS.int.seq Mv}
	    D=1
	 [] D=0
	 end
      end
      D
\else
      _
\endif
   end
   fun {EqPrecDaughtersL NodeRec NodeRecs LA DIDA}
      PosMs = {Map NodeRecs
	       fun {$ NodeRec} NodeRec.pos end}
   in
      {ReifiedIntSeq [{Select.union PosMs NodeRec.DIDA.model.eq}
		      {Select.union PosMs NodeRec.DIDA.model.daughtersL.LA}]}
   end
   %%
   fun {DaughtersLPrecEq NodeRec NodeRecs LA DIDA}
      PosMs = {Map NodeRecs
	       fun {$ NodeRec} NodeRec.pos end}
   in
      {ReifiedIntSeq [{Select.union PosMs NodeRec.DIDA.model.daughtersL.LA}
		      {Select.union PosMs NodeRec.DIDA.model.eq}]}
   end
   %%
   fun {DaughtersLPrecDaughtersL NodeRec NodeRecs LA LA1 DIDA}
      PosMs = {Map NodeRecs
	       fun {$ NodeRec} NodeRec.pos end}
   in
      {ReifiedIntSeq [{Select.union PosMs NodeRec.DIDA.model.daughtersL.LA}
		      {Select.union PosMs NodeRec.DIDA.model.daughtersL.LA1}]}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   fun {ReifiedPartition Mv M}
\ifndef FLATZINC_FLAWED
      D = {FD.int 0#1}
   in
      thread
	 or {FS.partition Mv M}
	    D=1
	 [] D=0
	 end
      end
      D
\else
      _
\endif
   end
   fun {DisjointDaughtersL NodeRec DIDA}
      {ReifiedPartition
       NodeRec.DIDA.model.daughtersL
       NodeRec.DIDA.model.daughters}
   end
   fun {DisjointSubtreesL NodeRec DIDA}
      {ReifiedPartition
       NodeRec.DIDA.model.downL
       NodeRec.DIDA.model.down}
   end
   %%
   fun {MkDyn PW}
      Dom = {PW dom}
      Edge = {PW edge}
   in
      o(
	 %%
	 xdom:
	    fun {$ NodeRec NodeRec1 DIDA}
	       {PreDisj
		{Dom NodeRec NodeRec1 DIDA}
		fun {$} {Dom NodeRec1 NodeRec DIDA} end}  
	    end
	 %%
	 xedge:
	    fun {$ NodeRec NodeRec1 DIDA}
	       {PreDisj
		{Edge NodeRec NodeRec1 DIDA}
		fun {$} {Edge NodeRec1 NodeRec DIDA} end}
	    end
	 %%
	 )
   end
end
