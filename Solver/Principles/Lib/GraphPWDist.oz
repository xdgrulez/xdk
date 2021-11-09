%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Distributor(distributeMs distributeMRecs) at 'Distributor.ozf'
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      if {Helpers.checkModel 'GraphPWDist.oz' Nodes
	  [DIDA#mothers
	   DIDA#daughtersL]} then
	 %% distribute mothers
	 MothersMs = {Map Nodes
		      fun {$ Node} Node.DIDA.model.mothers end}
	 {Distributor.distributeMs MothersMs FS}
	 %% distribute l-daughters
	 DaughtersLMRecs = {Map Nodes
			    fun {$ Node} Node.DIDA.model.daughtersL end}
      in
	 {Distributor.distributeMRecs DaughtersLMRecs FS}
      end
   end
end
