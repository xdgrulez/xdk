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
      D2LabelLat = {DIDA2LabelLat D2DIDA}
      D1LAs = D1LabelLat.constants
      D2LAs = D2LabelLat.constants
   in
      if {Helpers.checkModel 'LinkingMotherEnd.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#mothersL]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     %% Linking Mother and Endpoint
		     %% m -l->1 d =>
		     %%   End(l) neq emptyset =>
		     %%     d -End(l)->2 m
		     EndLALMRec =
		     {ArgRecProc 'End' o('^': Node1)}
		     EndLM = EndLALMRec.LA
		     %%
		     Node1D2MothersLMs =
		     {Map D2LAs
		      fun {$ LA} Node1.D2DIDA.model.mothersL.LA end}
		     Node1D2MothersM =
		     {Select.union Node1D2MothersLMs EndLM}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FD.nega {FS.reified.equal EndLM FS.value.empty}}
		       {FS.reified.include Node2.index Node1D2MothersM}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
