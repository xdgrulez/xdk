%%
%%  Module PWTreeAccess
%%
%%  Exports pattern builders to grant easy access to PW trees. As such,
%%  they are specific to the PW and should be updated as the PW semantic
%%  tree language - and the scope of the transforms - change. This module
%%  is a specialization of GornUtils for having more efficiency in
%%  the PW case.
%%
functor
import
   TopDownMatch(
      'fail':Fail
      'else':Else) at 'TopDownMatch.ozf'
   Gorn(make:MkGornMoves) at 'GornUtils.ozf'
export
   Make
   MkSumAdjoin % not used in the quad optimizer
   Committed
   AlternativeFst % not used in the quad optimizer
   AlternativeSnd % not used in the quad optimizer
   alternative:AlternativeFst % not used in the quad optimizer
prepare
   RecordToListInd = Record.toListInd
define
   %% Make: PatDiff -> Combine -> GornUtils - given a pattern PatDiff to
   %% be combined by function Combine (usually Adjoin) with a default
   %% access pattern (see below), Make returns a set of Gorn utilities
   %% (see module GornUtils.make) for the combined pattern.
   fun {Make PatDiff Combine}
      Pat
      GMoves = {MkGornMoves Pat}
      o(eitherWay:EitherWay
	easy:Easy1
	mkEasy:MkEasy
	doChildrenPat:DoChildrenPat
	...) = GMoves
      Easy3 = {MkEasy 3}
      Easy2 = {MkEasy 2}
      Default = o(
		   s:Easy2
		   defprinciple:Easy3
		   letdim:Easy3
		   constraints:Easy1
		   '|':EitherWay
		   forall:Easy3
		   exists:Easy3
		   existsone:Easy3
		   setForall:Easy3
		   setExists:Easy3
		   setExistsOne:Easy3
		   let:[Easy2 Easy3]
		   lettrace:Easy2
		   srcvar:Easy2
		   anno:Easy1
		   constant:Fail
		   Else:DoChildrenPat
		   )
   in
      thread Pat = {Combine Default PatDiff} end
      GMoves
   end

   %% Committed: PatDiff -> GornUtils - equivalent to calling
   %% {Make PatDiff Adjoin}. This is the only builder actually
   %% used in the quad optimizer.
   fun {Committed PatDiff} {Make PatDiff Adjoin} end

   local
      fun {CondSum SumF Pat F SubPat}
	 if {HasFeature Pat F}
	 then {SumF Pat.F SubPat}
	 else SubPat end
      end
   in
      fun {MkSumAdjoin SumF}
	 fun {$ Pat1 Pat2}
	    Pat2L = {RecordToListInd Pat2}
	    DiffL = {Map Pat2L
		     fun {$ F#SubPat2}
			F#{CondSum SumF Pat1 F SubPat2}
		     end}
	 in
	    {AdjoinList Pat1 DiffL}
	 end
      end
   end
   fun {AlternativeFst PatDiff OverlapOrId}
      Combine = {MkSumAdjoin fun {$ X Y} {OverlapOrId [Y X]} end}
   in
      {Make PatDiff Combine}
   end
      
   fun {AlternativeSnd PatDiff OverlapOrId}
      Combine = {MkSumAdjoin fun {$ X Y} {OverlapOrId [X Y]} end}
   in
      {Make PatDiff Combine}
   end
end
