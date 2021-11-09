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
      DIDA = {DVA2DIDA 'D'}
   in      
      if {Helpers.checkModel 'GraphMakeEdges1.oz' Nodes
	  [DIDA#down
	   DIDA#up
	   DIDA#daughters
	   DIDA#mothers]} then
	 for Node1 in Nodes do
	    Model1 = Node1.DIDA.model
	 in
	    for Node2 in Nodes do
	       Model2 = Node2.DIDA.model
	    in	       
	       %% v2 in down(v1) iff v1 in up(v2)
	       {FD.equi
		{FS.reified.include Node2.index Model1.down}
		{FS.reified.include Node1.index Model2.up} 1}
		  
	       %% v2 in daughters(v1) iff v1 in mothers(v2)
	       {FD.equi
		{FS.reified.include Node2.index Model1.daughters}
		{FS.reified.include Node1.index Model2.mothers} 1}
	    end
	 end
      end
   end
end
