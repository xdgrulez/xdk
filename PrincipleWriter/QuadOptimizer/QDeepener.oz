%%
%%  Module QDeepener
%%
%%  This module exports a transform builder that, given a transformation
%%  on PW trees TF: Arg -> Tree -> [Tree] and a quantifier expression
%%  QE of the form:
%%
%%       Q V::node: F
%%
%%  looks for the deepest locus in form F where quantification over V
%%  might happen keeping logical equivalence with QE, possibly under
%%  a different quantifier Q'. Once the locus is found, TF is applied to
%%  it and, if successful, the final result will be a Gorn difference
%%  with reference to F incorporating the result of TF.
%%
%%  Some rationale points of this module:
%%  A) avoid all subtrees that are completely free of V. These are left
%%     untouched;
%%  B) detect variables in nested quantifiers that cannot be directly
%%     related to V below the locus. This would imply illegal quantifier
%%     inversions, such as "exists V: ... forall V1:" into "forall V1:
%%     ... exists V:". Inversion is only allowed between equal quantifiers.
%%
%%  USAGE: DeepestApply: Arg -> GornDiff, where Arg must contain
%%  features 'q' (for Q as an atom), 'var' (for V as a tree) and
%%  'reduce': Arg -> Tree -> NewTree. Finally, the 'reduce' feature
%%  will be called as {Arg'.reduce Arg' Locus}, where Arg' contains
%%  all features originally passed in Arg, among which features 'q' and
%%  'banned' might have been updated during deepening.  
%%
%%  The logical equivalences applied by this module are as follows:
%%
%%  (In all the formulas below, A is always the only formula free of variable
%%  x. We do not show commutative equivalents though they are applied.
%%  Currently we do not exploit the associativity of operators. Therefore,
%%  even if A and D are free of variable x in ((A & B) & (C & D)),
%%  (A & B) and (C & D) aren't, so the whole expression is not amenable
%%  to further quantificator deepening.)
%%
%%  CQ x:(A & B) === A & (CQ x:B)
%%  CQ x:(A | B) === A | (CQ x:B)
%%  CQ x:(~B) === ~(dual(CQ) x:B)
%%  CQ x:(A => B) === A => (CQ x:B)
%%  CQ x:(B => A) === (dual(CQ) x:B) => A
%%  CQ x:(A <=> B) === (A => (CQ x:B)) & (dual(CQ) x:B) => A
%%
%%  where: CQ in {exists, forall}
%%         dual(exists) = forall
%%         dual(forall) = exists
%%
%%  OQ x:(A & B) === A & (OQ x:B)
%%  OQ x:(A | B) === ~A & (OQ x:B)
%%  OQ x:(~B) === (dual(CQ) x:B)
%%  OQ x:(A => B) === A & (OQ x:B)
%%  OQ x:(B => A) === ~A & (dual(OQ) x:B)
%%  OQ x:(A <=> B) === (A & (OQ x:B)) | (~A & (dual(OQ) x:B))
%%
%%  where: OQ in {existsone, allbutone}
%%         dual(existsone) = allbutone
%%         dual(allbutone) = existsone
%%
functor
import
%   System(show)

   TopDownMatch(apply:Apply
		continue:Continue
		'else':Else
		ifMatched:IfMatched
		ifMatchedElse:IfMatchedElse) at 'TopDownMatch.ozf'
   MatchHelpers(constantTree2A:ConstTree2A
		samePat:SamePat) at 'MatchHelpers.ozf'
   FindVar(freeOf:FreeOfVar) at 'FindVar.ozf'
   GornUtils(make:MkGornUtils
	     replace:Replace
	     condReplace:CondReplace
	     condGornAdjoin:CondGornAdjoin) at 'GornUtils.ozf'
   %Ozcar(breakpoint:BP)
export
   DeepestTransf
   MkDeepestTransf
define
   Qs = [exists forall existsone ] 
   local
      DualRec = o(1:2
		  2:1
		  exists:forall
		  forall:exists
		  existsone:allbutone
		  allbutone:existsone)
   in
      fun {Dual X} DualRec.X end
      fun {ArgWithDualQ Arg} {AdjoinAt Arg q {Dual Arg.q}} end
   end

   ApplyReducePat
   = Apply(fun {$ Arg T}
	      {CondReplace {Arg.reduce Arg T}}
	   end)
     
   o(goDown:GoDown match:Match ...)
   = {MkGornUtils
      {AdjoinAt
       {Adjoin
	o(conj:BinOp
	  disj:BinOp
	  impl:BinOp
	  equi:BinOp
	  neg:UnOp)
	{SamePat Qs CondBanVar}}  % : goal (B) above
       Else ApplyReducePat}}
      
   fun {BinOp Arg Op X Y}
      Q = Arg.q
      Action = Q2Op2Action.Q.Op
   in
      if {FreeOfVar Arg.var X} then
	 {Action 2 Arg X Y}
      elseif {FreeOfVar Arg.var Y} then
	 {Action 1 Arg Y X}
      else Continue(ApplyReducePat Arg) end
   end
      
   fun {UnOp Arg Op X} {Q2Op2Action.(Arg.q).Op Arg X} end
      
   fun {MkApplyReduceRslt Arg}
      Continue(ApplyReducePat Arg)
   end

   fun {MkReplaceBinOp BinOpCore}
      fun {$ I Arg FreeF BoundF}
	 fun {NewBoundF} {CondGornAdjoin BoundF {Match Arg BoundF}} end
	 fun {DualNewBoundF}
	    {CondGornAdjoin BoundF {Match {ArgWithDualQ Arg} BoundF}}
	 end
      in
	 {BinOpCore I Arg FreeF NewBoundF DualNewBoundF}
      end
   end

   fun {GoDownBound I Arg _ BoundForm}
      {GoDown I Arg BoundForm}
   end
      
   local
      fun {ClassicQImpl I Arg _ BoundForm}
	 Arg1 = if I == 1 then {ArgWithDualQ Arg} else Arg end
      in
	 {GoDown I Arg1 BoundForm}
      end
      ClassicQEqui = {MkReplaceBinOp
		      fun {$ _ Arg FreeF NewBoundF DualNewBoundF}
			 {IfMatched {NewBoundF}
			  fun {$ NewBoundF}
			     {IfMatchedElse {DualNewBoundF} Arg
			      fun {$ DualNewBoundF}
				 replace(conj(impl(FreeF NewBoundF)
					      impl(DualNewBoundF FreeF)))
			      end
			      MkApplyReduceRslt}
			  end}
		      end}
      fun {ClassicQNeg Arg X}
	 {GoDown 1 {ArgWithDualQ Arg} X}
      end
      ClassicQActions = o(conj:GoDownBound
			  disj:GoDownBound
			  impl:ClassicQImpl
			  equi:ClassicQEqui
			  neg:ClassicQNeg)
   in
      ClassicQ2Op2Action = o(exists:ClassicQActions
			     forall:ClassicQActions)
   end

   local
      OneQDisj = {MkReplaceBinOp
		  fun {$ _ _ FreeF NewBoundF _}
		     {IfMatched {NewBoundF}
		      fun {$ NewBoundF}
			 replace(conj(neg(FreeF) NewBoundF))
		      end}
		  end}
      OneQImpl = {MkReplaceBinOp
		  fun {$ I _ FreeF NewBoundF DualNewBoundF}
		     if I == 2 then
			{IfMatched {NewBoundF}
			 fun {$ NewBoundF}
			    replace(conj(FreeF NewBoundF))
			 end}
		     else
			{IfMatched {DualNewBoundF}
			 fun {$ DualNewBoundF}
			    replace(conj(DualNewBoundF neg(FreeF)))
			 end}
		     end
		  end}

      fun {OneQNeg Arg X}
	 {IfMatched {CondGornAdjoin X {Match {ArgWithDualQ Arg} X}}
	  Replace}
      end

      OneQEqui = {MkReplaceBinOp
		  fun {$ I Arg FreeF NewBoundF DualNewBoundF}
		     {IfMatched {NewBoundF}
		      fun {$ NewBoundF}
			 {IfMatchedElse {DualNewBoundF} Arg
			  fun {$ DualNewBoundF}
			     replace(disj(conj(FreeF NewBoundF)
					  conj(neg(FreeF) DualNewBoundF)))
			  end
			  MkApplyReduceRslt}
		      end}
		  end}
      OneQActions = o(conj:GoDownBound
		      disj:OneQDisj
		      impl:OneQImpl
		      equi:OneQEqui
		      neg:OneQNeg)
   in
      OneQ2Op2Action = o(existsone:OneQActions
			 allbutone:OneQActions)
   end

   Q2Op2Action = {Adjoin ClassicQ2Op2Action OneQ2Op2Action}
      
   fun {CondBanVar Arg Q V _ Form}
      if Arg.q == Q then
	 {GoDown 3 Arg Form}
      else
%	 {System.show qdeep#V}
	 VA = {ConstTree2A V}
	 Banned = {CondSelect Arg banned nil}
      in
	 {GoDown 3 {AdjoinAt Arg banned VA|Banned} Form}
      end
   end
   DeepestTransf = Match
   fun {MkDeepestTransf Reduce}
      fun {$ Arg T}
	 {DeepestTransf {AdjoinAt Arg reduce Reduce} T}
      end
   end
end