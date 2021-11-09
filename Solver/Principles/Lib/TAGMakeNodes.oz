functor
import
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      proc {Codomain R C}
	 {Record.forAll R proc {$ S} {FS.subset S C} end}
      end
      %%
      proc {Weigh S1 D S2}
	 D2 = {FD.int 1#2}
      in
	 {FD.sum [D 1] '=:' D2}
	 {Select.fs unit(FS.value.empty S1) D2 S2}
      end
      %%
      proc {Cond D S1 S2 S3}
	 D2 = {FD.int 1#2}
      in
	 {FD.sum [D 1] '=:' D2}
	 {Select.fs unit(S2 S1) D2 S3}
      end
      %%
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      if {Helpers.checkModel 'TAGMakeNodes.oz' Nodes nil} then
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 NodeSet = Nodes.1.nodeSet
	 Models = {List.map Nodes fun {$ N} N.DIDA.model end}

	 %% lists of below(w)(l), for all nodes w, sorted by label
	 BelowL =
	 {Record.mapInd {Record.make unit LabelLat.constants}
	  fun {$ L _} {List.map Models fun {$ N} N.belowL.L end} end}
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model
	    
	    %% get arguments
	    Anchor = {ArgRecProc 'Anchor' o('_': Node)}
	    Dominates = {ArgRecProc 'Dominates' o('_': Node)}
	    Foot = {ArgRecProc 'Foot' o('_': Node)}
	    Leaves = {ArgRecProc 'Leaves' o('_': Node)}

	    %% initialise variables
	    {Codomain Model.anchorsL NodeSet}
	    {Codomain Model.belowL NodeSet}
	    {Codomain Model.pasteL NodeSet}
	    {Codomain Model.pastedL NodeSet}
	    {Codomain Model.yieldL NodeSet}
	    {Codomain Model.leaveYieldL NodeSet}

	    {FS.subset Model.yield NodeSet}

	    %% list of paste(w)(l), for the current node
	    PasteL = {List.map LabelLat.constants fun {$ L} Model.pasteL.L end}

	    %% paste(w) = U {paste(w)(l) | exists w' with w' -l-> w}
	    Paste = {Select.union PasteL Model.labels}

	    %% list of pasted(w)(l), for the current node
	    PastedL =
	    {List.map LabelLat.constants fun {$ L} Model.pastedL.L end}

	    %% list of yield(w)(l), for the current node
	    YieldL = {List.map LabelLat.constants fun {$ L} Model.yieldL.L end}
	 in
	    for L in LabelLat.constants do
	       LI = {LabelLat.aI2I L}
	    in
	       %% anchor(w)(l) = {w} if l is anchor of w, empty otherwise
	       Model.anchorsL.L =
	       {Weigh Model.eq {FS.reified.include LI Anchor}}

	       %% below(w)(l) = U {yield(w)(l') | l dominates l'}
	       Model.belowL.L = {Select.union YieldL Dominates.L}
	       
	       %% pasteL(w)(l) = U {below(w')(l) | w' is mother of w}
	       Model.pasteL.L = {Select.union BelowL.L Model.mothersL.L}
	       
	       %% pasted(w)(l) = paste(w), if l is foot of w, empty otherwise
	       Model.pastedL.L = {Weigh Paste {FS.reified.include LI Foot}}

	       %% yield(w)(l) = anchors(w)(l) + down(w)(l) + pasted(w)(l)

	       %% NOTE that down(w)(l) = inserted(w)(l) from the paper
	       
	       %% OPTIMISATION.  The below(w)(l) component mentioned in the
	       %% paper is not needed here, as the convexity principle is
	       %% imposed on Model.yield (see below).  The remaining components
	       %% actually partition yield(w)(l).

	       Model.yieldL.L =
	       {FS.partition [Model.anchorsL.L
			      Model.downL.L
			      Model.pastedL.L
			      Model.belowL.L]}

	       %% leaveYield(w)(l) =
	       %% yield(w)(l), if l is a leaf, empty otherwise
	       %%
	       %% NOTE: This is no longer true.  As Denys suggested:
	       %% If l is not a leaf, we can at least order its
	       %% anchor.  (We could even do a little more: We could
	       %% order that part of its yield that lies on the same
	       %% side of its foot node than its anchor.)
	       Model.leaveYieldL.L =
	       {Cond {FS.reified.include LI Leaves}
		Model.yieldL.L Model.daughtersL.L}
	    end

	    %% yield(w) = U yield(w)(l) (= yield(w)(root))
	    Model.yield = {FS.unionN Model.yieldL}

	    %% OPTIMISATION to increase propagation
	    Model.yield = {FS.partition Model.eqdown|PastedL}
	 end
      end
   end
end
