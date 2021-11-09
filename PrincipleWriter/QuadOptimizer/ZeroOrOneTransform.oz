%%
%%  Module: ZeroOrOneTransform
%%
%%  Exports one single transform - the - that generates zeroOrOne(X)
%%  from disjunctions containing zero(X) and one(X) as terms.
%%
functor
import
   TopDown(easy:Easy
	   mkMatch:MkMatch
	   matchMap:MatchMap
	   mkCombine:MkCombine
	   ifMatched:IfMatched
	   mkGreedyClosure:MkClosure) at 'TopDownMatch.ozf'
   Helpers(eqSems:EqSems) at 'MatchHelpers.ozf'
   MkTransf at 'MkTransform.ozf'
export
   The % : the transform
   Reduce % : the associated reduce function
   Closure % : the applicative closure of Reduce 
prepare
   fun {Id X} X end
define
   fun {Inverse X Y}
      if X == one then Y == zero
      else Y == one end
   end
   proc {Combine Disj#Lifted Cand Rslt Ok}
      Ok = {Inverse {Label Lifted} {Label Cand}}
      andthen {EqSems Lifted.1 Cand.1}
      if Ok then
	 Rslt = zeroOrOne(Cand.1)#fun {$ Disj2}
				     disj(Disj Disj2)
				  end
      end
   end
   fun {ApplyCombine Combine L X}
      {Combine L(X)}
   end

   SubPat =
   o(one:ApplyCombine
     zero:ApplyCombine
     lettrace:Easy(2 SubPat)
     srcvar:Easy(2 SubPat)
     disj:
	[
	 fun {$ Arg _ X Y}
	    {Search Arg Y fun {$ NewY#Lifted}  
			     disj(X NewY)#Lifted
			  end}
	 end
	 fun {$ Arg _ X Y}
	    {Search Arg X fun {$ NewX#Lifted} 
			     disj(NewX Y)#Lifted
			  end}
	 end
	]
     
    )

   fun {Search AuxArg Tree MapF}
      {MatchMap SubPat AuxArg Tree MapF}
   end

   fun {LiftAndFalsify X} false#X end
   fun {InvApply X#F} {F X} end
   
   MainPat =
   o(disj:fun {$ _ _ X Y}
	     RsltX = {Search LiftAndFalsify X Id}
	  in
	     {IfMatched RsltX
	      fun {$ RsltX}
		 {Search {MkCombine RsltX Combine} Y InvApply}
	      end}
	  end)

   Reduce = {MkMatch MainPat}
   Closure = {MkClosure Reduce}
   The = {MkTransf.saturate.topDown o(disj:Closure)}
end
