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
      D1DIDA = {DVA2DIDA 'D1'}
      D2DIDA = {DVA2DIDA 'D2'}
      DIDA2LabelLat = G.dIDA2LabelLat
      D1LabelLat = {DIDA2LabelLat D1DIDA}
      D1LAs = D1LabelLat.constants
      D2LabelLat = {DIDA2LabelLat D2DIDA}
      D2LAs = D2LabelLat.constants
   in
      %% check features
      if {Helpers.checkModel 'Subgraphs.oz' Nodes
	  [D1DIDA#downL
	   D2DIDA#downL]} then
	 %% Linking Subgraphs
	 %%
	 %% forall v in V: forall l in L_1:
	 %%   Start(v)(l) neq emptyset => 
	 %%     v -l->1+ D1 and v -(Start(v)(l))->2+ D2 and
	 %%       D1 subseteq D2
	 for Node in Nodes do
	    StartLALMRec =
	    {ArgRecProc 'Start' o('^': Node)}
	    %%
	    D2DownLMs = {Map D2LAs
			 fun {$ LA} Node.D2DIDA.model.downL.LA end}
	 in
	    for D1LA in D1LAs do
	       StartLM = StartLALMRec.D1LA
	       %%
	       D1M = Node.D1DIDA.model.downL.D1LA
	       D2M = {Select.union D2DownLMs StartLM}
	    in
	       {FD.impl
		{FD.nega {FS.reified.equal StartLM FS.value.empty}}
		{FS.reified.subset D1M D2M} 1}
	    end
	 end
      end
   end
end
