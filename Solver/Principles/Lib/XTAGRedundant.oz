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
   ListLast = List.last
define
   A2S = Atom.toString
   %%
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ID = {DVA2DIDA 'D1'}
      LP = {DVA2DIDA 'D2'}
   in
      %% check features
      if {Helpers.checkModel 'XTAGRedundant.oz' Nodes
	  [ID#labels
	   LP#daughters
	   LP#labels
	   LP#mothers
	   LP#daughtersL]} then
	 ArgRecProc = Principle.argRecProc
	 %%
	 DIDA2LabelLat = G.dIDA2LabelLat
	 IDLabelLat = {DIDA2LabelLat ID}
	 IDLAs = IDLabelLat.constants
	 IDAdjLAs =
	 {Filter IDLAs
	  fun {$ LA}
	     LS = {A2S LA}
	  in
	     {ListLast LS}==&a
	  end}
	 IDA2I = IDLabelLat.aI2I
	 IDAdjLIs = {Map IDAdjLAs IDA2I}
	 IDAdjLM = {FS.value.make IDAdjLIs}
	 %%
	 LPLabelLat = {DIDA2LabelLat LP}
	 LPLAs = LPLabelLat.constants
	 %%
	 PosDs = {Map Nodes
		  fun {$ Node} {FS.include $ Node.pos} end}
	 %%
	 NodesI = {Length Nodes}
	 %%
	 PrecLALMRec = {Helpers.makeRelation LPLabelLat prec FS}
	 Dom1LALMRec = {Helpers.makeRelation LPLabelLat dom1 FS}
	 Prec1LALMRec = {Helpers.makeRelation LPLabelLat prec1 FS}
      in
	 for Node in Nodes do
	    Node.LP.model.cover =
	    {FS.partition [Node.LP.model.eqdown Node.LP.model.foot]}
	 end
	 %%
	 for Node in Nodes do
	    FootLM = {ArgRecProc 'Foot' o('_': Node)}
	 in
	    {FD.equi
	     {FS.reified.equal FootLM FS.value.empty}
	     {FS.reified.equal Node.LP.model.foot FS.value.empty} 1}
	    %%
	    {FD.equi
	     {FD.nega
	      {FS.reified.equal Node.ID.model.mothers FS.value.empty}}
	     {FS.reified.equal Node.ID.model.labels Node.ID.entry.'in'} 1}
	 end
	 %%
	 for Node1 in Nodes I1 in 1..NodesI do
	    Node1AnchorLD = {ArgRecProc 'Anchor' o('_': Node1)}
	    Node1FootLM = {ArgRecProc 'Foot' o('_': Node1)}
	    %%
	    Prec1LMs = {Map LPLAs
			fun {$ LA} Prec1LALMRec.LA end}
	    Prec1LM = {Select.union Prec1LMs Node1FootLM}
	    %%
	    PrecLMs = {Map LPLAs
		       fun {$ LA} PrecLALMRec.LA end}
	    PrecLM = {Select.union PrecLMs Node1FootLM}
	    %%
	    Node1PosD = {Nth PosDs I1}
	 in
	    for Node2 in Nodes I2 in 1..NodesI do
	       if {Not {Opti.isIn Node2.index Node1.LP.model.foot}=='out'} then
		  Node2PosD = {Nth PosDs I2}
	       in
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.foot}
		    {FD.reified.less Node2PosD Node1PosD}}
		   {FS.reified.include Node1AnchorLD PrecLM} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.foot}
		    {FD.reified.greater Node2PosD Node1PosD}}
		   {FS.reified.include Node1AnchorLD Prec1LM} 1}
	       end
	    end
	 end
	 %%
	 for Node1 in Nodes I1 in 1..NodesI do
	    Node1AnchorLD = {ArgRecProc 'Anchor' o('_': Node1)}
	    %%
	    PrecLMs = {Map LPLAs
		       fun {$ LA} PrecLALMRec.LA end}
	    PrecLM = {Select.fs PrecLMs Node1AnchorLD}
	    %%
	    Prec1LMs = {Map LPLAs
			fun {$ LA} Prec1LALMRec.LA end}
	    Prec1LM = {Select.fs Prec1LMs Node1AnchorLD}
	    %%
	    Dom1LMs = {Map LPLAs
		       fun {$ LA} Dom1LALMRec.LA end}
	    Dom1LM = {Select.fs Dom1LMs Node1AnchorLD}
	    %%
	    Node1PosD = {Nth PosDs I1}
	 in
	    for Node2 in Nodes I2 in 1..NodesI do
	       Node2AnchorLD = {ArgRecProc 'Anchor' o('_': Node2)}
	       Node2FootLM = {ArgRecProc 'Foot' o('_': Node2)}
	       %%
	       PrecLM2 = {Select.fs PrecLMs Node2AnchorLD}
	       Prec1LM2 = {Select.fs Prec1LMs Node2AnchorLD}
	       %%
	       Node2PosD = {Nth PosDs I2}
	    in
	       if {Not {Opti.isIn Node2.index Node1.LP.model.daughters}=='out'} then
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.reified.less Node2PosD Node1PosD}}
		   {FS.reified.subset
		    Node2.LP.model.labels {FS.union Prec1LM Dom1LM}} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.reified.greater Node2PosD Node1PosD}}
		   {FS.reified.subset
		    Node2.LP.model.labels {FS.union PrecLM Dom1LM}} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.conj
		     {FD.reified.less Node2PosD Node1PosD}
		     {FD.nega
		      {FS.reified.subset Node2.LP.model.labels Prec1LM}}}}
		   {FD.conj
		    {FS.reified.subset Node2.ID.model.labels IDAdjLM}
		    {FS.reified.subset Node2.LP.model.labels Dom1LM}} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.conj
		     {FD.reified.greater Node2PosD Node1PosD}
		     {FD.nega
		      {FS.reified.subset Node2.LP.model.labels PrecLM}}}}
		   {FD.conj
		    {FS.reified.subset Node2.ID.model.labels IDAdjLM}
		    {FS.reified.subset Node2.LP.model.labels Dom1LM}} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.reified.less Node2PosD Node1PosD}}
		   {FS.reified.subset Node2FootLM PrecLM2} 1}
		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node2.index Node1.LP.model.daughters}
		    {FD.reified.greater Node2PosD Node1PosD}}
		   {FS.reified.subset Node2FootLM Prec1LM2} 1}
	       end
	    end
	 end
	 %%
	 for Node1 in Nodes I1 in 1..NodesI do
	    Node1PosD = {Nth PosDs I1}
	 in
	    for Node2 in Nodes I2 in 1..NodesI do
	       Node2AnchorLD = {ArgRecProc 'Anchor' o('_': Node2)}
	       Node2FootLM = {ArgRecProc 'Foot' o('_': Node2)}
	       %%
	       Prec1LMs = {Map LPLAs
			   fun {$ LA} Prec1LALMRec.LA end}
	       Prec1LM = {Select.union Prec1LMs Node2.LP.model.labels}
	       %%
	       PrecLMs = {Map LPLAs
			  fun {$ LA} PrecLALMRec.LA end}
	       PrecLM = {Select.union PrecLMs Node2.LP.model.labels}
	       %%
	       Dom1LMs = {Map LPLAs
			  fun {$ LA} Dom1LALMRec.LA end}
	       Dom1LM = {Select.union Dom1LMs Node2.LP.model.labels}
	       %%
	       PrecLM1 = {Select.fs PrecLMs Node2AnchorLD}
	       Prec1LM1 = {Select.fs Prec1LMs Node2AnchorLD}
	       %%
	       Node2PosD = {Nth PosDs I2}
	    in
	       {FD.impl
		{FD.conj
		 {FD.reified.greater
		  {FS.card {FS.intersect Node1.LP.model.mothers Node2.LP.model.mothers}} 0}
		 {FD.conj
		  {FD.reified.less Node1PosD Node2PosD}
		  {FS.reified.subset Node2FootLM PrecLM1}}}
		{FS.reified.subset Node1.LP.model.labels {FS.unionN [Prec1LM Dom1LM]}} 1}
	       %%
	       {FD.impl
		{FD.conj
		 {FD.reified.greater
		  {FS.card {FS.intersect Node1.LP.model.mothers Node2.LP.model.mothers}} 0}
		 {FD.conj
		  {FD.reified.greater Node1PosD Node2PosD}
		  {FS.reified.subset Node2FootLM Prec1LM1}}}
		{FS.reified.subset Node1.LP.model.labels {FS.unionN [PrecLM Dom1LM]}} 1}
	    end
	 end
      end
   end
end
