%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)

%%
functor
import
%   Space(waitStable)

   Distributor(distributeDs distributeMs) at 'Distributor.ozf'
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
   in
      if {Helpers.checkModel 'OrderDist.oz' Nodes nil} then
	 DIDA = {DVA2DIDA 'D'}
	 %% distribute self
	 SelfDs = {Map Nodes
		   fun {$ Node} Node.DIDA.model.'self' end}
      in
	 {Distributor.distributeDs SelfDs FD}
      end
   end
end
