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
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'Order2MakeNodes.oz' Nodes
	  [DIDA#eqdown]} then
	 %% get node set NodeSetM
	 NodeSetM = Nodes.1.nodeSet
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model
	    %%
	    {FS.subset Model.yield NodeSetM}
	    {FS.subset Model.yieldS NodeSetM}
	    {RecordForAll Model.yieldL proc {$ M} {FS.subset M NodeSetM} end}
	 in
  	    %% |yield(v)| = |eqdown(v)|
	    {FD.equal
	     {FS.card Model.yield}
	     {FS.card Model.eqdown}}
	 end
      end
   end
end
