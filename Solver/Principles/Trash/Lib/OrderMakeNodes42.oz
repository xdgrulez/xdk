%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
prepare
   RecordForAll = Record.forAll
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'OrderMakeNodes.oz' Nodes
	  [DIDA#eqdown]} then
	 %% get label lattice LabelLat
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 %% get node set NodeSetM
	 NodeSetM = Nodes.1.nodeSet
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model
	    %%
	    {RecordForAll Model.selfSet proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.subset Model.yield NodeSetM}
	    {FS.subset Model.yieldS NodeSetM}
	    {RecordForAll Model.yieldL proc {$ M} {FS.subset M NodeSetM} end}
	    %% get args
	    OnM = {ArgRecProc 'On' o('_': Node)}
	 in
   	    %% self(v) in on(v)
	    {FS.include Model.'self' OnM}
	    %% pos(v) = uplus{ self_s(v) | s in selfs }
  	    {FS.partition Model.selfSet Node.pos}
  	    %% |self_l(v)| = 1 iff self(v) == l
 	    for LA in LabelLat.constants do
 	       LD = {LabelLat.aI2I LA}
 	    in
	       {FD.equi
		{FD.reified.equal {FS.card Model.selfSet.LA} 1}
		{FD.reified.equal Model.'self' LD} 1}
  	    end
	 end
      end
   end
end
