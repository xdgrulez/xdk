%%
%%  Module LiftBoolDotSetTransform
%%
%%  Exports one single transform that tries to bring boolDotSet
%%  expressions (introduced in an intermediate step of QuadTransform)
%%  as high up the tree as possible. This is used inside QuadTransform
%%  and improves propagation significantly.
%%
functor
import
   MatchTopDown(mkMatch:MkMatch
		mkGreedyClosure:MkClosure
		easy:Easy
		unify:Unify
		ifMatched:IfMatched
		ifMatchedElse:IfMatchedElse
		fst:Fst
		apply:Apply) at 'TopDownMatch.ozf'
   GornUtils(mkTransf:MkTransf
	     mkSaturateBottomUp:MkSaturateBottomUp
	     mkApplyTransf:MkApplyTransf
	     mkCondApplyTransf:MkCondApplyTransf
	     condReplace:CondReplace) at 'GornUtils.ozf'
export
   The
define
   SetOp2LogicOp = o(union:disj intersect:conj)
   SetOp2Dual = o(union:intersect intersect:union)
   
   %%
   %% LiftPass: transform that does the actual lifting.
   %%
   local
      IsLogicAsSet = {MkMatch
		      Unify(fun {$ _ _}
			       T = boolDotSet(_ nodeCompl(empty))
			    in
			       T#T
			    end)}
      IsParcRslt = {MkMatch
		    Unify(fun {$ Op _}
			     T = boolOpSet(Op _ _) in
			     T#T
			  end)}
      
      
      fun {CombineBoolDotSet Op BDS Term}
	 LogicOp = SetOp2LogicOp.Op
      in
	 {IfMatchedElse {Fst {IsLogicAsSet unit Term}} unit
	  fun {$ BDS1} 
	     {AdjoinAt BDS 1 LogicOp(BDS.1 BDS1.1)}
	  end
	  fun {$ _}
	     {IfMatchedElse {Fst {IsParcRslt Op Term}} unit
	      fun {$ BOpS}
		 boolOpSet(Op LogicOp(BDS.1 BOpS.2) BOpS.3)
	      end
	      fun {$ _}
		 boolOpSet(Op BDS.1 Term)
	      end}
	  end}
      end
      
      fun {CombineParcRslt PR Term}
	 Op = PR.1
	 LogicOp = SetOp2LogicOp.Op
      in
	 {IfMatchedElse {Fst {IsParcRslt Op Term}} unit
	  fun {$ PR1} 
	     boolOpSet(Op LogicOp(PR.2 PR1.2) Op(PR.3 PR1.3))
	  end
	  fun {$ _}
	     {AdjoinAt PR 3 Op(PR.3 Term)}
	  end}
      end
      
      fun {OneSuchThat MatchF Arg X Y}
	 {IfMatchedElse {Fst {MatchF Arg X}} unit
	  fun {$ XRslt}
	     XRslt#Y
	  end
	  fun {$ _}
	     {IfMatched {Fst {MatchF Arg Y}}
	      fun {$ YRslt}
		 YRslt#X
	      end}
	  end}
      end
	     
      fun {Promote _ Op X Y}
	 {IfMatchedElse {OneSuchThat IsLogicAsSet unit X Y} unit
	  fun {$ BDS#Term}
	     {CombineBoolDotSet Op BDS Term}
	  end
	  fun {$ _}
	     {IfMatched {OneSuchThat IsParcRslt Op X Y} 
	      fun {$ PR#Term}
		 {CombineParcRslt PR Term}
	      end}
	  end}
      end

      Pat = o(union:Promote
	      intersect:Promote
	      nodeCompl:
		 Easy(1
		      o(boolDotSet:
			   Apply(fun {$ _ T}
				    {IfMatched {Fst {IsLogicAsSet unit T}}
				     fun {$ BDS}
					{AdjoinAt BDS 1 neg(BDS.1)}
				     end}
				 end)
			boolOpSet: % De Morgan:
			   fun {$ _ _ Op B S}
			      boolOpSet(SetOp2Dual.Op neg(B) nodeCompl(S))
			   end)))
      
      Reduce = {MkMatch Pat}
      Closure = {MkClosure Reduce}
   in
      LiftPass = {MkCondApplyTransf
		  {{MkTransf MkSaturateBottomUp} Closure}}
   end
   %%
   %% SurfacePass: transform that undoes the boolDotSet expression
   %% (releasing the logic expression that was inside it) if it has
   %% reached the root.
   %% 
   local
      Pat = o(boolOpSet:fun {$ _ _ Op B S}
			   LogicOp = SetOp2LogicOp.Op
			in
			   replace(LogicOp(B S))
			end)
   in
      SurfacePass = {MkApplyTransf {MkMatch Pat}}
   end

   fun {The _ T} % = SurfacePass o LiftPass
      {CondReplace {SurfacePass unit {LiftPass unit T}}}
   end
end