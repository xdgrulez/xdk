%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'Dag.oz' Nodes
	  [DIDA#daughters
	   DIDA#mothers
	   DIDA#equp
	   DIDA#eq
	   DIDA#up
	   DIDA#eqdown
	   DIDA#daughtersL
	   DIDA#down]} then
	 Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
	 ConnectedB = {ArgRecProc 'Connected' o}==2
	 if ConnectedB then
	    %% get node set NodeSetM
	    NodeSetM = Nodes.1.nodeSet
	    %%
	    RootsM = {FS.subset $ NodeSetM}
	    %% precisely one root
	    {FD.equal {FS.card RootsM} 1}
	    %%
	    DaughtersMs = {Map Models
			   fun {$ Model} Model.daughters end}
	    DaughtersM = {FS.unionN DaughtersMs}
	 in
	    {FS.partition [RootsM DaughtersM] NodeSetM}
	    %%
	    for Model in Models I in 1..{Length Models} do
	       %% a node is root iff it has no mother
	       {FD.equi
		{FS.reified.include I RootsM}
		{FD.reified.equal {FS.card Model.mothers} 0} 1}
	       
	       %% a node is root iff its eqdown-set contains all nodes
	       {FD.equi
		{FS.reified.include I RootsM}
		{FS.reified.equal Model.eqdown NodeSetM} 1}
	    end
	 end
	 %%
	 DisjointDaughtersB = {ArgRecProc 'DisjointDaughters' o}==2
	 if DisjointDaughtersB then
	    for Model in Models do
	       %% daughters(v) = uplus{ daughters_l(v) | l in labels }
	       Model.daughters = {FS.partition Model.daughtersL}
	    end
	 end
      in
	 for Model in Models do
	    %% equp(v) = eq(v) uplus up(v)
	    Model.equp = {FS.partition [Model.eq Model.up]}
	    %% eqdown(v) = eq(v) uplus down(v)
	    Model.eqdown = {FS.partition [Model.eq Model.down]}
	    %% eq(v) = equp(v) intersect eqdown(v)
	    Model.eq = {FS.intersect Model.equp Model.eqdown}
	    %% post additional constraints if the dag is ordered (= if the fields
	    %% yield, pos and yieldS exist)
	    if {HasFeature Model pos} andthen
	       {HasFeature Model yield} andthen
	       {HasFeature Model yieldS} then
	       %% yield(v) = pos(v) uplus yieldS(v)
	       Model.yield = {FS.partition [Model.pos Model.yieldS]}
	    end
	 end
      end
   end
end
