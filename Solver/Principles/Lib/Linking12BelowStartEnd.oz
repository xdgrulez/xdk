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
      if {Helpers.checkModel 'Linking12BelowStartEnd.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#daughters
	   D2DIDA#daughtersL
	   D2DIDA#mothers
	   D2DIDA#mothersL]} then
	 D2DaughtersMs = {Map Nodes
			  fun {$ Node} Node.D2DIDA.model.daughters end}
	 D2MothersMs = {Map Nodes
			fun {$ Node} Node.D2DIDA.model.mothers end}
      in
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     local
			%% Linking 12Below and Startpoint
			%% m -l->1 d =>
			%%   Start(l) neq emptyset =>
			%%     m -Start(l)->2 ->?2 d
			StartLALMRec =
			{ArgRecProc 'Start' o('^': Node1)}
			StartLM = StartLALMRec.LA
			%%
			Node1D2DaughtersLMs =
			{Map D2LAs
			 fun {$ LA} Node1.D2DIDA.model.daughtersL.LA end}
			Node1D2Daughters1M =
			{Select.union Node1D2DaughtersLMs StartLM}
			Node1D2Daughters2M =
			{Select.union D2DaughtersMs Node1D2Daughters1M}
			Node1D2Daughters12M =
			{FS.union Node1D2Daughters1M Node1D2Daughters2M}
		     in
			{FD.impl
			 {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
			 {FD.impl
			  {FD.nega {FS.reified.equal StartLM FS.value.empty}}
			  {FS.reified.include Node2.index Node1D2Daughters12M}} 1}
		     end
		     %%
		     local
			%% Linking 12Below and Endpoint
			%% m -l->1 d =>
			%%   End(l) neq emptyset =>
			%%     m ->?2 -End(l)->2 d
			EndLALMRec =
			{ArgRecProc 'End' o('^': Node1)}
			EndLM = EndLALMRec.LA
			%%
			Node2D2MothersLMs =
			{Map D2LAs
			 fun {$ LA} Node2.D2DIDA.model.mothersL.LA end}
			Node2D2Mothers1M =
			{Select.union Node2D2MothersLMs EndLM}
			Node2D2Mothers2M =
			{Select.union D2MothersMs Node2D2Mothers1M}
			Node2D2Mothers12M =
			{FS.union Node2D2Mothers1M Node2D2Mothers2M}
		     in
			{FD.impl
			 {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
			 {FD.impl
			  {FD.nega {FS.reified.equal EndLM FS.value.empty}}
			  {FS.reified.include Node1.index Node2D2Mothers12M}} 1}
		     end
		  end
	       end
	    end
	 end
      end
   end
end
