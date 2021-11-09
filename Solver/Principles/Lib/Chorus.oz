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
   in
      %% check features
      if {Helpers.checkModel 'Chorus.oz' Nodes
	  [D2DIDA#eqdown
	   D1DIDA#downL
	   D2DIDA#mothers]} then
	 D2EqdownMs = {Map Nodes
		       fun {$ Node} Node.D2DIDA.model.eqdown end}
      in
	 for Node in Nodes do
	    Dom1LM = {ArgRecProc 'Chorus' o('_': Node)}
	    %%
	    D1DownLMs = {Map D1LAs
			 fun {$ LA} Node.D1DIDA.model.downL.LA end}
	    D1DownLM = {Select.union D1DownLMs Dom1LM}
	    %%
	    D2MothersM = Node.D2DIDA.model.mothers
	    D2EqdownM = {Select.union D2EqdownMs D2MothersM}
	 in
	    {FS.subset D1DownLM D2EqdownM}
	 end
      end
   end
end
