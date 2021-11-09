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
   NounLAs = [subj iobj obj]
   %%
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      D2DIDA = {DVA2DIDA 'D2'} %% id
   in
      %% MfOrder3 principle (xdg/parser/dg/Plugins-nl.oz)
      %% subj < iobj < obj
      if {Helpers.checkModel 'Dutch.oz' Nodes
	  [D2DIDA#daughtersL]} then
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
      in
	 for Node in Nodes do
	    PosNounsDaughterMs =
	    {Map NounLAs
	     fun {$ LA}
		M = Node.D2DIDA.model.daughtersL.LA
	     in
		{Select.union PosMs M}
	     end}
	 in
	    {FS.int.seq PosNounsDaughterMs}
	 end
      end
      %% MfOrder4 principle (xdg/parser/dg/Plugins-nl.oz)
      if {Helpers.checkModel 'Dutch.oz' Nodes
	  [D2DIDA#daughtersL
	   D2DIDA#up]} then
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
	 %%
	 NounDaughtersMs =
	 {Map Nodes
	  fun {$ Node}
	     Ms = {Map NounLAs
		   fun {$ LA} Node.D2DIDA.model.daughtersL.LA end}
	     M = {FS.unionN Ms}
	  in
	     M
	  end}
      in
	 for Node in Nodes I in 1..{Length Nodes} do
	    NounDaughtersUpM =
	    {Select.union NounDaughtersMs Node.D2DIDA.model.up}
	    PosNounDaughtersUpM = {Select.union PosMs NounDaughtersUpM}
	    %%
	    NounDaughtersM = {Nth NounDaughtersMs I}
	    PosNounDaughtersM = {Select.union PosMs NounDaughtersM}
	 in
	    {FS.int.seq [PosNounDaughtersUpM PosNounDaughtersM]}
	 end
      end
   end
end
