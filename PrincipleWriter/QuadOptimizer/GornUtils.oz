%%  Module: GornUtils
%%
%%  This module exports utilities extending the TopDownMatch
%%  engine so as to inform the Gorn addresses of match results.
%%  This is very handy when building tree transforms if the
%%  results (modulo Gorn addresses) are intended to replace
%%  the respective matched subtree. In this case, a transform
%%  is obtained by applying GornAdjoin (see MatchHelpers)
%%  to the original tree and the Gorn address-decorated results.
%%   These GornAdjoinable results are said Gorn differences.
%%
functor
import
   MatchHelpers(getSem:GetSem
		gornAdjoin:GornAdjoin
		gornAdjoinFst:GornAdjoinFst
		unaryFunctionAdapter:UnaryFunctionAdapter) at 'MatchHelpers.ozf'
   TopDownMatch(dl:Dl
		match:Match
		matchMap:MatchMap
		'fail':Fail
		final:Final
		fst:Fst
		apply:Apply
		choose:Choose
		ifMatched:IfMatched
		ifMatchedElse:IfMatchedElse) at 'TopDownMatch.ozf'
   %Ozcar(breakpoint:BP)
prepare
   fun {Snd X} X.2 end
   Partition = List.partition
export
   Replace
   CondReplace
   adjoin:GornAdjoinPat
   Make
   gornAdjoin:GornAdjoinPat
   CondGornAdjoin
   MkSaturateTopDown
   MkSaturateBottomUp
   MkReplace
   MkTransf
   MkSimpleTransf
   MkApplyTransf
   MkCondApplyTransf
   Overlap
   MkReduce
define
   fun {Replace T} replace(T) end

   %% CondReplace: Rslt -> DecoratedRslt - decorates Rslt with the
   %% "replace" keyword (see MatchHelpers.gornAdjoin) if Rslt is
   %% not failed.
   fun {CondReplace Rslt}
      {IfMatched {Fst Rslt} Replace}
   end
   
   %% GornAdjoinPat: T -> GornDiff -> NewT - simple wrapper for
   %% MatchHelpers.gornAdjoin that allows T and GornDiff to be
   %% themselves results of matching. Checks whether T and GornDiff
   %% are not failed. If GornDiff is failed, NewT = T.
   fun {GornAdjoinPat T GornDiff}
      {IfMatched {Fst T}
       fun {$ FstT}
	  {GornAdjoin FstT {Final GornDiff}}
       end}
   end

   %% CondGornAdjoinPat: T -> GornDiff -> NewT - similar to GornAdjoin
   %% but if GornDiff is failed so is NewT.
   fun {CondGornAdjoin T GornDiff}
      {IfMatched GornDiff fun {$ GornDiff} {GornAdjoinPat T GornDiff} end}
   end

   %% Make: Pat -> Kit - given a TopDownMatch pattern Pat, returns
   %% the corresponding suite of basic Gorn utilities. Notice that these
   %% utilities are usually used to build Pat itself, in a recursive
   %% fashion. The utilities are:
   %%
   %% . Kit.pattern - the pattern used to create the utilities (parameter
   %%   to Make) and implicitly assumed in all matching operations
   %%   performed by the other utilities;
   %%
   %% . Kit.match: Arg -> T -> Matches - exactly like TopDownMatch.match,
   %%   only assuming Kit.pattern the pattern to use;
   %%
   %% . Kit.matchMap: Arg -> T -> MapF -> Matches - ditto;
   %%
   %% . Kit.goDown: I -> Arg -> SubTree -> Matches - for usage inside
   %%   function patterns (see example in QuadInnerReduce.oz), this
   %%   performs matching on SubTree with auxiliary argument Arg and
   %%   implicit Kit.pattern. Matches are
   %%   decorated with address I (an integer);
   %% 
   %% . Kit.doChildren: Arg -> T -> Matches - for usage inside function
   %%   patterns (see MkSaturateTopDown below), performs matching on
   %%   every child of T, decorating the results accordingly.
   %%
   %% . Kit.doChildrenPat - pattern version of doChildren.
   %%
   %% . Kit.mkEasy I -> Pat: creates a pattern that simply goes down
   %%   the I-th child of a tree;
   %%
   %% . Kit.easy - short for {Kit.mkEasy 1};
   %%
   %% . Kit.eitherWay - convenience pattern to go down the two
   %%   branches of a binary node alternatively;
   %%
   %% . Kit.threeWay - convenience pattern to go down the three
   %%   branches of a ternary node alternatively;
   %%
   fun {Make Pat}
      fun {MyMatch Arg WayDown}
	 {Match Pat Arg WayDown}
      end
      fun {MyMatchMap Arg WayDown MapF}
	 {MatchMap Pat Arg WayDown MapF}
      end
      fun {GoDown I Arg WayDown}
	 {IfMatched {MyMatch Arg WayDown} fun {$ Rslt} I#Rslt end}
      end
      fun {GoDownT I Arg T}
	 {GoDown I Arg {GetSem T}.I}
      end
      fun {DoChildren Arg T} Sem in
	 if {IsRecord T} andthen {IsRecord Sem = {GetSem T}} then 
	    SemWidth = {Width Sem}
	 in
	    case SemWidth of
	       0 then Fail
	    [] 1 then % : an optimization. The else clause would suffice.
	       {GoDown 1 Arg Sem.1} 
	    else {Match Choose(1 SemWidth MkEasy) Arg T} end
	 else Fail end
      end
      DoChildrenPat = Apply(DoChildren)
			       
      fun {MkEasy I}
	 Apply(fun {$ Arg T} {GoDownT I Arg T} end)
      end
   in
      o(
	 doChildren:DoChildren
	 doChildrenPat:DoChildrenPat
	 easy:{MkEasy 1}
	 mkEasy:MkEasy
	 eitherWay:
	    [
	     fun {$ Arg _ X _} {GoDown 1 Arg X} end
	     fun {$ Arg _ _ Y} {GoDown 2 Arg Y} end
	    ]
	 threeWay:
	    [
	     fun {$ Arg _ X _ _} {GoDown 1 Arg X} end
	     fun {$ Arg _ _ Y _} {GoDown 2 Arg Y} end
	     fun {$ Arg _ _ _ Z} {GoDown 3 Arg Z} end
	    ]
	 oneWay:fun {$ Arg _ X} {GoDown 1 Arg X} end
	 match:MyMatch
	 matchMap:MyMatchMap
	 goDown:GoDown
	 goDownT:GoDownT
	 pattern:Pat
	 )
   end

   %% MkSaturateTopDown: DoChildren -> (SatF -> Pat) - given a DoChildren
   %% utility (created by Make) and a tree transform SatF, yields a
   %% pattern that transforms a given tree T by applying SatF to all
   %% subtrees of T, in a top-down fashion.
   fun {MkSaturateTopDown DoChildren}
      fun {$ SatF0}
	 SatF = {UnaryFunctionAdapter SatF0}
      in
	 Apply(fun {$ Arg T}
		  T1 = {Fst {SatF Arg T}}
	       in
		  {IfMatchedElse T1 T
		   fun {$ T1}
		      {CondReplace {GornAdjoinPat T1 {DoChildren Arg T1}}}
		   end
		   fun {$ T}
		      {DoChildren Arg T}
		   end}
	       end)
      end
   end
   
   %% MkSaturateBottomUp: DoChildren -> (SatF -> Pat) - given a DoChildren
   %% utility (created by Make) and a tree transform SatF, yields a
   %% pattern that transforms a given tree T by applying SatF to all
   %% subtrees of T, in a bottom-up fashion.
   fun {MkSaturateBottomUp DoChildren}
      fun {$ SatF0}
	 SatF = {UnaryFunctionAdapter SatF0}
      in
	 Apply(fun {$ Arg T}
		  fun {SatF1 T} {SatF Arg T} end
		  T1 = {CondGornAdjoin T {DoChildren Arg T}}
		  T2 = {Fst {IfMatchedElse T1 T SatF1 SatF1}}
	       in
		  {IfMatchedElse T2 T1 Replace CondReplace}
	       end)
      end
   end
   
   %% MkReplace: DoChildren -> (SatF -> Pat) - an optimization
   %% of MkSaturateTopDown for the (rare) cases that if
   %% SatF succeeds for a node, the subtrees of the result
   %% should not be further processed.
   fun {MkReplace DoChildren}
      fun {$ F0}
	 F = {UnaryFunctionAdapter F0}
      in
	 Apply(fun {$ Arg T}
		  T1 = {Fst {F Arg T}}
	       in
		  {IfMatchedElse T1 T
		   Replace
		   fun {$ T} {DoChildren Arg T} end}
	       end)
      end
   end

   %% MkTransf: MkX -> (Reduce -> Transf) - a generic transform
   %% builder. Given MkX in {MkSaturateTopDown MkSaturateBottomUp
   %% MkReplace}, {MkTransform MkX} returns a builder that takes
   %% a reduce function and returns a transform, which is a function
   %% that takes a tree and applies a reduce everywhere in it
   %% as specified by MkX. The return of a transform is a Gorn
   %% difference that should be incorporated to the original tree.
   fun {MkTransf MkX}
      fun {$ F}
	 Pat
	 o(match:Match doChildren:DoChildren ...) = {Make Pat}
      in
	 Pat = {{MkX DoChildren} F}
	 Match
      end
   end

   fun {MkSimpleTransf Pat}
      fun {$ Arg Tree}
	 {CondReplace {Match Pat Arg Tree}}
      end
   end
   
   fun {MkApplyTransf Transf}
      fun {$ Arg MaybeT}
	 {IfMatched {Fst MaybeT}
	  fun {$ T} {GornAdjoinPat T {Transf Arg T}} end}
      end
   end

   fun {MkCondApplyTransf Transf}
      fun {$ Arg MaybeT}
	 {IfMatched {Fst MaybeT}
	  fun {$ T} {CondGornAdjoin T {Transf Arg T}} end}
      end
   end

   %% Overlap: Pat1 -> Pat2 - yields a pattern that fixes overlapping
   %% alternative patterns in Pat1. Two alternative patterns overlap if
   %% they are not mutually exclusive and they go down the same
   %% child of a tree.
   local
      fun {Collapse L T}
	 case L of nil then T
	 [] (XI#X)|Xs then
	    fun {SameI Rslt} Rslt.1 == XI end
	    ToGroup
	    Rest = {Partition Xs SameI ToGroup}
	    Collapsed = if ToGroup == nil then L.1 else
			   XI#{Collapse {Flatten X|{Map ToGroup Snd}} nil}
			end
	 in
	    Collapsed|{Collapse Rest T}
	 end
      end   
   in
      fun {Overlap Pat}
	 Apply(fun {$ Arg T}
		  case {Final {Match Pat Arg T}} of
		     nil then Fail
		  [] [Single] then Single
		  [] Multiple then T L = {Collapse Multiple T} in
		     Dl(L T)
		  end
	       end)
      end
   end

   %% MkReduce: GornDiffGen -> (Tree -> NewTree) - given a function
   %% GornDiffGen mapping trees into Gorn differences on those trees,
   %% yields a function mapping a tree T into the tree obtained by
   %% incorporating {GornDiffGen T} to T. NewTree is returned as an empty
   %% list (on failure of GornDiffGen) or a singleton list containing
   %% the new tree.
   fun {MkReduce GornDiffGen}
      fun {$ Tree}
	 Diff = {Final {GornDiffGen Tree}}
      in
	 case Diff of nil then nil else
	    [{GornAdjoinFst Tree Diff}]
	 end
      end
   end      
end
