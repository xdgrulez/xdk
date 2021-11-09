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
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'TreeConditions.oz' Nodes
	  [DIDA#daughters
	   DIDA#mothers
	   DIDA#eq
	   DIDA#eqdown]} then
	 %% get node set NodeSetM
	 NodeSetM = Nodes.1.nodeSet
	 %%
	 RootsM = {FS.subset $ NodeSetM}
	 %% precisely one root
	 {FD.equal {FS.card RootsM} 1}
	 %% 
	 Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
	 %%
	 DaughtersMs = {Map Models
			fun {$ Model} Model.daughters end}
      in
	 {FS.partition RootsM|DaughtersMs NodeSetM}
	 %%
	 for Model in Models I in 1..{Length Models} do
	    %% |labels(v)|=|mothers(v)|
	    {FD.equal
	     {FS.card Model.labels}
	     {FS.card Model.mothers}}
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
   end
end
