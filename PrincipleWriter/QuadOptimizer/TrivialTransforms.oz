%%
%%  Module: TrivialTransforms
%%
%%  Exports a collection of trivial tree transforms, namely:
%%
%%  . zero: its main function is to generate the zero constraint on
%%    set cardinalities. The kinds of reduction it performs are the
%%    following:
%%       allNodes(nodeCompl(S)) --> zero(S)
%%       zero(nodeCompl(S)) --> allNodes(S)
%%       nodeCompl(nodeCompl(S)) --> S
%%       neg(neg(F)) --> F
%%       neg(zero(S)) --> oneOrMore(S)
%%       neg(oneOrMore(S)) --> zero(S)
%%
%%  . memo: creates all kinds of memoizable constraints by combining
%%    expressions of the form:
%%       X(Y(...))
%%    where
%%       X in {zero one oneOrMore zeroOrOne} and
%%       Y in {mothers mothersL daughters daughtersL}
%%    into such expressions as zeroMothers(...), oneOrMoreDaughtersL(...),
%%    etc.
%%
%%  . false: simplifies disjunctions by eliminating literal false terms
%%    inserted by other transforms such as zeroOrOneTransform.
%%
functor
import
   MatchTopDown(mkMatch:MkMatch
		mkGreedyClosure:MkClosure
		mkSimplify:MkSimplify
		mkSimplifyBranch:MkSimplifyBranch
		easy:Easy
		unify:Unify) at 'TopDownMatch.ozf'
   MkTransf at 'MkTransform.ozf'
export
   Zero
   Memo
   MemoMatch
   False
   Impl
prepare
   fun {Const X}
      fun {$ _} X end
   end
   RecordMap = Record.map
define
   %%
   %% The Zero transform:
   %%
   local
      IntoZero = {MkSimplify zero#1}
      IntoAll = {MkSimplify allNodes#1}
      fun {Shrink _ _ X} X end
      Pat =
      o(
	 allNodes: Easy(1 o(nodeCompl: IntoZero))
	 zero: Easy(1 o(nodeCompl: IntoAll))
	 nodeCompl: Easy(1 o(nodeCompl: Shrink))
	 neg: Easy(1 o(neg: Shrink
		       zero: {MkSimplify oneOrMore#1}
		       oneOrMore: IntoZero))
	 )
      Reduce = {MkMatch Pat}
      Closure = {MkClosure Reduce}
   in
      Zero = {MkTransf.saturate.bottomUp {RecordMap Pat {Const Closure}}}
   end

   %%
   %% The Memo transform:
   %%
   local
      Pat =
      o(
	 one:
	    Easy(1 {MkSimplifyBranch
		    [ mothers#(oneMother#2)
		      mothersL#(oneMotherL#3)
		      daughters#(oneDaughter#2)
		      daughtersL#(oneDaughterL#3)
		    ]})
	 zero:
	    Easy(1 {MkSimplifyBranch
		    [ mothers#(zeroMothers#2)
		      mothersL#(zeroMothersL#3)
		      daughters#(zeroDaughters#2)
		      daughtersL#(zeroDaughtersL#3)
		    ]})
	 zeroOrOne:
	    Easy(1 {MkSimplifyBranch
		    [ mothers#(zeroOrOneMothers#2)
		      mothersL#(zeroOrOneMothersL#3)
		      daughters#(zeroOrOneDaughters#2)
		      daughtersL#(zeroOrOneDaughtersL#3)
		    ]})
	 oneOrMore:
	    Easy(1 {MkSimplifyBranch
		    [ mothers#(oneOrMoreMothers#2)
		      mothersL#(oneOrMoreMothersL#3)
		      daughters#(oneOrMoreDaughters#2)
		      daughtersL#(oneOrMoreDaughtersL#3)
		    ]})
	 )
      Match = {MkMatch Pat}
      Reduce = Match
      Closure = Reduce
   in
      Memo = {MkTransf.saturate.bottomUp {RecordMap Pat {Const Closure}}}
      MemoMatch = Match
   end

   %%
   %% The False transform:
   %%
   local
      Pat = [Unify(fun {$ _ L} X in 
		      L(false X)#
		      fun {$} X end
		   end)
	     Unify(fun {$ _ L} X in 
		      L(X false)#
		      fun {$} X end
		   end)]
      Reduce = {MkMatch Pat}
      Closure = Reduce
   in
      False = {MkTransf.saturate.bottomUp o(disj:Closure)}
   end
   %%
   %% The Impl transform:
   %%
   local
      Pat = o(disj:[Unify(fun {$ _ _} X Y in 
			     disj(neg(X) Y)#
			     fun {$} impl(X Y) end
			  end)
		    Unify(fun {$ _ L} X Y in 
			     disj(X neg(Y))#
			     fun {$} impl(Y X) end
			  end)
		   ])
      Reduce = {MkMatch Pat}
      Closure = Reduce
   in
      Impl = {MkTransf.saturate.bottomUp o(disj:Closure)}
   end
end