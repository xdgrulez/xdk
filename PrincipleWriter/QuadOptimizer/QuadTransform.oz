%%
%%  Module QuadTransform
%%
%%  This module implements the so-called quad transform, the heart of
%%  the quad optimizer. It applies as many "quad reduces" as possible
%%  to a given tree. Each quad reduce may only succeed if applied to
%%  a tree whose root is a node quantifier, which it will attempt to
%%  eliminate. As a result of each successful reduce, a constraint whose
%%  original cost is a polynomial P(n) - where n is the number of nodes -
%%  will be implemented with a cost Q(n) such that:
%%
%%      degree(Q(N)) = degree(P(N)) - 1
%%
functor
import
%   System(show)

   BottomUpMatch(mkCoercer:MkCoercer
		 match:BuMatch
		 'fail':BuFail
		 any:Any) at 'BottomUpMatch.ozf'
   TopDownMatch('fail':TdFail
		unify:Unify
		easy:Easy
		mkMatch:MkMatch) at 'TopDownMatch.ozf'
   MatchHelpers(samePat:SamePat
		constantTree2A:ConstTree2A
	        getSemLabel:SemLbl) at 'MatchHelpers.ozf'
   FindVar(freeOf:FreeOfVar
	   collect:CollectVars) at 'FindVar.ozf'
   GornUtils(condGornAdjoin:CondGornAdjoin
	     mkApplyTransf:MkApplyTransf
	     mkSimpleTransf:MkSimpleTransf) at 'GornUtils.ozf'
   QDeepener(deepestTransf:DeepestTransf
	     mkDeepestTransf:MkDeepestTransf) at 'QDeepener.ozf'
   MkTransf at 'MkTransform.ozf'
   LiftBoolDotSetTransform at 'LiftBoolDotSetTransform.ozf'
   %Ozcar(breakpoint:BP)
export
   reduce:PublicReduce % : the core of the quad transform
   Closure
   The
define
   %fun {IdTransf _ T} T end
   
   %%
   %% Converting sets to logic expressions:
   %%
   SetToLogic = o(forall: % ... under a forall quantifier
		  fun {$ X} allNodes(X) end
		  exists: % ... under exists
		  fun {$ X} oneOrMore(X) end
		  existsone: % ... or under existsone
		  fun {$ X} one(X) end
		  allbutone: % ... or under allbutone
		  fun {$ X} one(nodeCompl(X)) end
		 )
   %%
   %% Types of operands in the transform:
   %%
   Set = {MkCoercer set
	  o(logic: fun {$ X} boolDotSet(X nodeCompl(empty)) end)}
   
   Const = {MkCoercer constant o}

   %%
   %% InnerPat: the BottomUpMatch pattern that generates the set
   %% equivalent of a logic expression
   %%
   local
      fun {NestedQ NewQ}
	 o(sig:[Any Any Set]
	   action: fun {$ _ _ V Dom Form} set(NewQ(V Dom Form)) end)
      end
      fun {CheckedNestedQ NewQ}
	 o(sig:[Any Any Set]
	   action: fun {$ Arg Q V Dom Form}
		      if {Arg.checkNestedQ Q Dom}
		      then set(NewQ(V Dom Form))
		      else BuFail end
		   end)
      end
   in
      InnerPat =
      o(
	 %% Treating nested quantifiers:
	 forall: {NestedQ setForall}
	 exists: {NestedQ setExists} 
	 existsone: {CheckedNestedQ setExistsOne}
	 %% The actual transformations:
	 impl:
	    o(sig:[Set Set]
	      action:fun {$ _ _ X Y} set(union(nodeCompl(X) Y)) end)
	 equi:
	    o(sig:[Set Set]
	      action:fun {$ _ _ X Y}
			set(union(nodeCompl(union(X Y))
				  intersect(X Y)))
		     end)
	 neg:
	    o(sig:[Set]
	      action:fun {$ _ _ X} set(nodeCompl(X)) end)
	 conj:
	    o(sig:[Set Set]
	      action:fun {$ _ _ X Y} set(intersect(X Y)) end)
	 disj:
	    o(sig:[Set Set]
	      action:fun {$ _ _ X Y} set(union(X Y)) end)
	 edge:
	    o(sig:[Const Const Const] % : unlabelled version
	      action:fun {$ Choose _ X Y D}
			set({Choose Y#daughters(X D) X#mothers(Y D)})
		     end)
	 ledge:
	    o(sig:[Const Const Const Const] % : labelled version
	      action:fun {$ Choose _ X Y L D}
			set({Choose Y#daughtersL(X L D) X#mothersL(Y L D)})
		     end)
	 dom:
	    o(sig:[Const Const Const] % : unlabelled version
	      action:fun {$ Choose _ X Y D}
			set({Choose Y#down(X D) X#up(Y D)})
		     end)
	 ldom:
	    o(sig:[Const Const Const Const] % : labelled version
	      action:fun {$ Choose _ X Y L D}
			set({Choose Y#downL(X L D) X#upEndL(Y L D)})
		     end)
	 domeq:
	    o(sig:[Const Const Const]
	      action:fun {$ Choose _ X Y D}
			set({Choose Y#eqdown(X D) X#equp(Y D)})
		     end)
	 eq:
	    o(sig:[Const Const]
	      action:fun {$ Choose _ X Y}
			set({Choose Y#nodeAsSet(X) X#nodeAsSet(Y)})
		     end)
	 neq:
	    o(sig:[Const Const]
	      action:fun {$ Choose _ X Y}
			set({Choose
			     Y#nodeCompl(nodeAsSet(X))
			     X#nodeCompl(nodeAsSet(Y))})
		     end)
	 constant:unit
	 )
   end

   %%
   %% MkChoose: Success -> ByeV -> Banned -> Choose - builds the
   %% Choose function given a free variable Success, the variable to
   %% eliminate (as a semantic tree) and a list Banned of the variables
   %% (as atoms) that cannot be involved in the elimination. Choose is
   %% central to the optimization process as it chooses between alternative
   %% optimizations for such key predicates as edge, dom and domeq. See
   %% explanation inside MkChoose.
   %%
   fun {MkChoose Success ByeV Banned}
      ByeA = {ConstTree2A ByeV}
      fun {IsBanned X} {Member X Banned} end 
   in
      %% Choose: XVarTree#XOpti -> YVarTree#YOpti -> ChosenOpti - has
      %% multiple functions, namely:
      %% A) check whether the variable we want to eliminate is
      %%    not related to one of the banned variables;
      %% B) signal that at least once there has been a succesfull
      %%    choice, by binding Success to unit;
      %% C) return the applicable optimization (XOpti or YOpti), depending
      %%    on whether XVarTree/YVarTree denotes ByeA.
      fun {$ XVarTree#XOpti YVarTree#YOpti}
	 XA = {ConstTree2A XVarTree}
	 YA = {ConstTree2A YVarTree}
	 XAYA = [XA YA]
      in
	 if XA == YA orelse {Not {Member ByeA XAYA}} then
	    BuFail
	 else
	    %% From now on, we know that either XA or YA == ByeA:
	    ChosenOpti = if ByeA == XA then XOpti else YOpti end 
	 in
	    if {Some {CollectVars ChosenOpti} IsBanned} then
	       BuFail
	    else
	       Success = unit % : goal (B)
	       ChosenOpti
	    end
	 end
      end
   end

   local
      %%
      %% SubseteqTransf: Tree1 -> Tree2 - very simple transform that is
      %% only applied to the root of Tree1, yielding Tree2. It performs
      %% the following changes:
      %% . allNodes(union(nodeCompl(X) Y))
      %%   ---> subseteq(X Y)
      %% . allNodes(union(nodeCompl(union(X Y)) intersect(X Y)))
      %%   ---> eq(X Y)
      %%
      GenerateSubseteq =
      {MkApplyTransf
       {MkSimpleTransf
	o(allNodes:
	     Easy([Unify(fun {$ _ _} X Y in
			    union(nodeCompl(union(X Y)) intersect(X Y))#
			    fun {$} eq(X Y) end
			 end)
		   Unify(fun {$ _ _} X Y in
			    union(nodeCompl(X) Y)#
			    fun {$} subseteq(X Y) end
			 end)
		  ]))}}
      LiftBoolDotSet = {MkApplyTransf LiftBoolDotSetTransform.the}
      GenQAndSubseteq = {MkApplyTransf
			 {MkDeepestTransf
			  fun {$ Arg T}
			     {GenerateSubseteq unit {SetToLogic.(Arg.q) T}}
			  end}}
   in
      %%
      %% ActualReduce Arg -> FormTree -> OptiFormTree - if possible,
      %% converts form FormTree into its optimized form given the
      %% info in record Arg, whose features are:
      %%  . q: the quantifier (as an atom: exists, existsone or forall)
      %%    of the variable we want to eliminate;
      %%  . var: the variable (as a semantic tree) we want to eliminate;
      %%  . banned: list of variables that cannot get involved in the
      %%    optimizations.
      %% Notice that ActualReduce is not public.
      %%
      fun {ActualReduce Arg FormTree}
	 InnerV = Arg.var
	 Success
	 fun {Cut T} % : avoids going down trees that are free of InnerV
	    if {SemLbl T} \= constant andthen {FreeOfVar InnerV T}
	    then [logic(T)] else nil end
	 end
	 Rslt = {BuMatch InnerPat Cut
		 {MkChoose Success InnerV Arg.banned}
		 FormTree}
      in
	 if Rslt == nil orelse {IsFree Success} then nil
	 else
	    {Arg.report}
	    {GenQAndSubseteq Arg {LiftBoolDotSet unit Rslt}}
%	    {GenQAndSubseteq Arg Rslt}
	 end
      end
   end

   Qs = [exists forall existsone] 
   %%
   %% Final touches: here is the public reduce, built upon ApplyDeepest 
   %% (and indirectly upon ActualReduce), and the derived transform.
   %%
   local
      Pat = {SamePat Qs TryReduce}
      fun {TryReduce Arg Q InnerV Dom Form}
	 if {SemLbl Dom} == node then
	    Arg1 = o(q:Q
		     qtype:if {Member Q [exists forall]}
			   then gen else one end
		     var:InnerV
		     banned:nil
		     report:proc {$} {Arg.report InnerV} end
		     checkNestedQ:Arg.checkNestedQ
		     reduce:ActualReduce)
	 in
	    {CondGornAdjoin Form {DeepestTransf Arg1 Form}}
	 else TdFail end
      end
   in
      PublicReduce = {MkMatch Pat}
      Closure = PublicReduce
      The = {MkTransf.saturate.bottomUp {SamePat Qs Closure}}
   end
end