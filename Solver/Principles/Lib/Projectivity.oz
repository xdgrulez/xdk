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
      if {Helpers.checkModel 'Projectivity.oz' Nodes
	  [DIDA#eqdown]} then
	 for Node in Nodes do
	    if {HasFeature Node.DIDA.model yield} then
	       {FS.int.convex Node.DIDA.model.yield}
	    else
	       {FS.int.convex Node.DIDA.model.eqdown}
	    end
	 end
      end
   end
end
