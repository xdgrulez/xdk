%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)

   Helpers(checkModel) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      D1DIDA = {DVA2DIDA 'D1'}
      D2DIDA = {DVA2DIDA 'D2'}
      DIDA2LabelLat = G.dIDA2LabelLat
      D1LabelLat = {DIDA2LabelLat D1DIDA}
      D1LAs = D1LabelLat.constants
   in
      if {Helpers.checkModel 'LinkingEnd.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#labels]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     %% LinkingEnd
		     %%
		     %% m -l->1 d =>
		     %%   End(l) neq emptyset =>
		     %%     -End(l)->2 d
		     EndLALMRec =
		     {ArgRecProc 'End' o('^': Node1)}
		     EndLM = EndLALMRec.LA
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FD.nega {FS.reified.equal EndLM FS.value.empty}}
		       {FD.reified.greater
			{FS.card {FS.intersect Node2.D2DIDA.model.labels EndLM}} 0}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
