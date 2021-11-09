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
      if {Helpers.checkModel 'LinkingBelowStart.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#downL]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     %% Linking Below and Startpoint
		     %% m -l->1 d =>
		     %%   Start(l) neq emptyset =>
		     %%     m -Start(l)->2 ->*2 d
		     StartLALMRec =
		     {ArgRecProc 'Start' o('^': Node1)}
		     StartLM = StartLALMRec.LA
		     %%
		     Node1D2DownLMs =
		     {Map D2LAs
			 fun {$ LA} Node1.D2DIDA.model.downL.LA end}
		     Node1D2DownLM =
		     {Select.union Node1D2DownLMs StartLM}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FD.nega {FS.reified.equal StartLM FS.value.empty}}
		       {FS.reified.include Node2.index Node1D2DownLM}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
