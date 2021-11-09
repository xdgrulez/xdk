%%
%%  Module FindVar
%%
%%  This module implements search for applications of variables
%%  in a PW tree. None of them count variables that are only declared
%%  but never used.
%%
functor
import
%   System(show)

   TopDown(apply:Apply
	   'fail':Fail
	   final:Final) at 'TopDownMatch.ozf'
   MatchHelpers(constantTreeIsVar:ConstantTreeIsVar
		constantTree2A:ConstTree2A
		singlGornDiff:SinglGornDiff
		getSemLabel:SemLbl
		traversedSems:TraversedSems) at 'MatchHelpers.ozf'
   Helpers(mkAccum:MkAccum
	   pushUnique:PushUnique) at 'Helpers.ozf'
   PWTreeAccess(committed:MkAccess) at 'PWTreeAccess.ozf'
   %System(show:Show)
   %Browser(browse:Browse)
   %Ozcar(breakpoint:BP)
export
   NoAction
   ForAll
   Find
   FreeOf
   Collect
   Spurious
define

   fun {NoAction _} unit end
   
   %% ForAll: Action -> Tree -> GornDiff - looks for applicative
   %% occurrences of variables in Tree, returning a Gorn
   %% difference GornDiff locating them. The site of a variable V
   %% in GornDiff is calculated by applying {Action VA}, where
   %% VA is V as an atom.
   local
      Pat
      o(match:Match ...) = {MkAccess Pat}
      !Pat = o(label:Fail
	       constant:Apply(fun {$ Action ConstT}
				 if {ConstantTreeIsVar ConstT} then
				    ConstA = {ConstTree2A ConstT}
				 in
				    {Action ConstA}
				 else Fail end
			      end)
	      )
   in
      ForAll = Match
   end

   %% Find: Action0 -> VConstTree -> Tree -> GornDiff - similar
   %% to ForAll, but only applies Action0 to occurrences of variable
   %% VConstTree.
   fun {Find Action0 VConstT T}
      V1A = {ConstTree2A VConstT}
      fun {Action V2A}
	 if V1A == V2A then {Action0 V1A} else Fail end
      end
   in
      {ForAll Action T}
   end
   
   %% FreeOf: VConstTree -> Tree -> Bool - checks whether a tree is
   %% free of applicative occurrences of variable VConstTree.
   fun {FreeOf VConstTree Tree}
      {Final {Find NoAction VConstTree Tree}} == nil
   end
   
   %% Collect: Tree -> Vars - returns a list with no repetitions of
   %% all variables (as atoms) applied in a PW tree.
   fun {Collect Tree}
      Accum = {MkAccum nil PushUnique}
      fun {Action VA}
	 {Accum.accum VA}
	 Fail
      end
   in
      {Wait {Final {ForAll Action Tree}}}
      {Accum.access}
   end

   local
      AllQs = [exists existsone forall setExists setExistsOne setForall]
      fun {IsQ T} {Member {SemLbl T} AllQs} end
   in
      fun {Spurious VConstT T}
	 Diff = {Final {Find NoAction VConstT T}}
%	 fun {Debug} VA = {ConstTree2A VConstT} in
%	    {Show spurious(VA)}
%	    true
%	 end
      in
	 {SinglGornDiff Diff} andthen {Not {Some {TraversedSems T Diff} IsQ}}
      end
   end
end