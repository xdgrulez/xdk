functor
import
   MatchHelpers(eqSems:EqSems) at 'MatchHelpers.ozf'
   Helpers(index:Index) at 'Helpers.ozf'
   TopDown(unify:Unify
	   'fail':Fail
	   match:Match
	   mkMatch:MkMatch
	   mkGreedyClosure:MkClosure) at 'TopDownMatch.ozf'
   MkTransf at 'MkTransform.ozf'
%   Ozcar(breakpoint:BP)
export
   The
prepare
   fun {Const X}
      fun {$ _} X end
   end
   ListToRecord = List.toRecord
   RecordMap = Record.map
define
   Unifiables =
   [fun {$ _ _} V V1 L1 L2 D in
       forall(V1 _
	      forall(L1 _
		     forall(L2 _ 
			    impl(conj(ledge(V V1 L1 D) ledge(V V1 L2 D))
				 eq(anno(L1 _) anno(L2 _))))))
       #fun {$}
	   if {EqSems V V1} then Fail else disjointDaughtersL(V D) end
	end
    end
    %%
    fun {$ _ _} V V1 L1 L2 D in
       forall(V1 _
	      forall(L1 _
		     forall(L2 _ 
			    impl(conj(ldom(V V1 L1 D) ldom(V V1 L2 D))
				 eq(anno(L1 _) anno(L2 _))))))
       #fun {$}
	   if {EqSems V V1} then Fail else disjointSubtreesL(V D) end
	end
    end
    %%
    fun {$ _ _} V V1 L D Prec in
       forall(V1 _ impl(ledge(V V1 L D) Prec))
       #fun {$}
	   {Match [Unify(prec(V V1)#eqPrecDaughtersL(V L D))
		   Unify(prec(V1 V)#daughtersLPrecEq(V L D))]
	    _ Prec}
	end
    end
    %%
    fun {$ _ _} V V1 V2 L L1 D in
       forall(V1 _
	      forall(V2 _
		     impl(conj(ledge(V V1 L D)
			       ledge(V V2 L1 D))
			  prec(V1 V2))))
       #fun {$}
	   if {EqSems V V1} orelse {EqSems V V2} then Fail
	   else daughtersLPrecDaughtersL(V L L1 D) end
	end
    end
    %%
    fun {$ _ _} V V1 V2 V3 D in
%       {BP}
       forall(V _
	      forall(V1 _
		     conj(impl(conj(edge(V V1 D)
				    prec(V V1))
			       forall(V2 _
				      impl(conj(prec(V V2)
						prec(V2 V1))
					   dom(V V2 D))))
			  impl(conj(edge(V V1 D)
				    prec(V1 V))
			       forall(V3 _
				      impl(conj(prec(V1 V3)
						prec(V3 V))
					   dom(V V3 D)))))))
       #fun {$} projective(D) end
    end
   ]

   fun {MkKey Unifiable}
      Term#_ = {Unifiable unit unit}
   in
      {Label Term}
   end

   fun {MkUnify F} Unify(F) end
   Pat = {ListToRecord o {Index Unifiables MkKey MkUnify}}
   Reduce = {MkMatch Pat}
   Closure = {MkClosure Reduce}
   The = {MkTransf.saturate.topDown {RecordMap Pat {Const Closure}}}
end
