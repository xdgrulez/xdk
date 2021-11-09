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
      if {Helpers.checkModel 'CSD.oz' Nodes
	  [DIDA#daughtersL
	   DIDA#mothers]} then
	 ArgRecProc = Principle.argRecProc
	 %%
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 LAs = LabelLat.constants
	 %%
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
      in
	 for Node in Nodes I in 1..{Length Nodes} do
	    NounLabelsM = {ArgRecProc 'NounLabels' o('_': Node)}
	    %%
	    NDaughtersMs =
	    {Map Nodes
	     fun {$ Node}
		AllDaughtersMs =
		{Map LAs
		 fun {$ LA} Node.DIDA.model.daughtersL.LA end}
	     in
		{Select.union AllDaughtersMs NounLabelsM}
	     end}
	    %%
	    NDaughtersUpM =
	    {Select.union NDaughtersMs Node.DIDA.model.up}
	    PosNDaughtersUpM = {Select.union PosMs NDaughtersUpM}
	    %%
	    NDaughtersM = {Nth NDaughtersMs I}
	    PosNDaughtersM = {Select.union PosMs NDaughtersM}
	 in
	    {FS.int.seq [PosNDaughtersUpM PosNDaughtersM]}
	 end
      end
   end
end
