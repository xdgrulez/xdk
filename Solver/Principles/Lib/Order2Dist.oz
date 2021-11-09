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
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'Order2Dist.oz' Nodes
	  [DIDA#pos]} then
	 %% distribute pos
	 PosMs = {Map Nodes
		   fun {$ Node} Node.DIDA.model.pos end}
      in
	 {Distributor.distributeMs PosMs FS}
      end
   end
end
