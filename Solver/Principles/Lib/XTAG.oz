%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Helpers(checkModel makeRelation) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
prepare
   RecordForAll = Record.forAll
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'XTAG.oz' Nodes
	  [DIDA#eqdown
	   DIDA#daughtersL
	   DIDA#eq]} then
	 ArgRecProc = Principle.argRecProc
	 %%
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 LAs = LabelLat.constants
	 A2I = LabelLat.aI2I
	 %%
	 NodeSetM = Nodes.1.nodeSet
	 %%
	 EqdownMs = {Map Nodes
		     fun {$ Node} Node.DIDA.model.eqdown end}
	 %%
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
	 %%
	 DomLALMRec = {Helpers.makeRelation LabelLat dom FS}
	 PrecLALMRec = {Helpers.makeRelation LabelLat prec FS}
      in
	 %% initialize sets
	 for Node in Nodes do
	    {FS.subset Node.DIDA.model.cover NodeSetM}
	    {RecordForAll Node.DIDA.model.coverL
	     proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.subset Node.DIDA.model.foot NodeSetM}
	    %%
	    Node.DIDA.model.cover = {FS.partition Node.DIDA.model.coverL}
	 end
	 %% 1. The cover of an address, i.e., coverL(v)(l), is the
	 %% disjoint union of the nodes below l, the anchor (if it has
	 %% address l), and the cover of the foot (if it has address
	 %% l).
	 for Node in Nodes do
	    for LA in LAs do
	       LI = {A2I LA}
	       %%
	       DownM = {Select.union EqdownMs Node.DIDA.model.daughtersL.LA}
	       %%
	       AnchorLD = {ArgRecProc 'Anchor' o('_': Node)}
	       AnchorM = {FS.subset $ Node.DIDA.model.eq}
	       {FD.equi
		{FD.reified.equal LI AnchorLD}
		{FS.reified.equal AnchorM Node.DIDA.model.eq} 1}
	       {FD.equi
		{FD.nega
		 {FD.reified.equal LI AnchorLD}}
		{FS.reified.equal AnchorM FS.value.empty} 1}
	       %%
	       FootLM = {ArgRecProc 'Foot' o('_': Node)}
	       FootM = {FS.subset $ Node.DIDA.model.foot}
	       {FD.impl
		{FS.reified.include LI FootLM}
		{FS.reified.equal FootM Node.DIDA.model.foot} 1}
	       {FD.impl
		{FD.nega
		 {FS.reified.include LI FootLM}}
		{FS.reified.equal FootM FS.value.empty} 1}
	    in
	       Node.DIDA.model.coverL.LA = {FS.partition [DownM AnchorM FootM]}
	    end
	 end
	 %% 2. If a node v' has been adjoined into v at address l,
	 %% then the cover of the foot of v', i.e., foot(v'), is the
	 %% cover of those addresses l' of the mother node which are
	 %% dominated by l.
	 for Node1 in Nodes do
	    Node1CoverMs = {Map LAs
			    fun {$ LA} Node1.DIDA.model.coverL.LA end}
	 in
	    for Node2 in Nodes do
	       for LA in LAs do
		  if {Not {Opti.isIn Node2.index Node1.DIDA.model.daughtersL.LA}=='out'} then
		     DomLM = DomLALMRec.LA
		     Node1CoverM = {Select.union Node1CoverMs DomLM}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.DIDA.model.daughtersL.LA}
		      {FS.reified.equal Node2.DIDA.model.foot Node1CoverM} 1}
		  end
	       end
	    end
	 end
	 %% 3. The covers of all nodes are convex.
	 for Node in Nodes do
	    CoverPosM = {Select.union PosMs Node.DIDA.model.cover}
	 in
	    {FS.int.convex CoverPosM}
	 end
	 %% 4. The covers of all nodes are ordered with respect to
	 %% their addresses.
	 for Node in Nodes do
	    CoverMs = {Map LAs
		       fun {$ LA} Node.DIDA.model.coverL.LA end}
	 in
	    for LA in LAs do
	       CoverLPosM = {Select.union PosMs Node.DIDA.model.coverL.LA}
	       %%
	       PrecLM = PrecLALMRec.LA
	       PrecCoverM = {Select.union CoverMs PrecLM}
	       PrecCoverPosM = {Select.union PosMs PrecCoverM}
	    in
	       {FS.int.seq [CoverLPosM PrecCoverPosM]}
	    end
	 end
      end
   end
end
