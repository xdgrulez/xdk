%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
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
   in
      %% check features
      if {Helpers.checkModel 'Climbing.oz' Nodes
	  [D1DIDA#equp
	   D1DIDA#mothers
	   D2DIDA#equp
	   D1DIDA#up
	   D2DIDA#mothers]} then
	 SubgraphsB = {ArgRecProc 'Subgraphs' o}==2
	 MotherCardsB = {ArgRecProc 'MotherCards' o}==2
	 %%
	 D1EqupMs = {Map Nodes
		     fun {$ Node} Node.D1DIDA.model.equp end}
      in
	 for Node in Nodes do
	    %% climbing
	    %% mothers_D1(v) subseteq equp_D2(v)
	    {FS.subset Node.D1DIDA.model.mothers Node.D2DIDA.model.equp}
	    
	    if SubgraphsB then
	       %% equp_D1_mothers_D2(v) =
	       %%   union { equp_D1(v') | v' in mothers_D2(v) }
	       D1EqupD2MothersM =
	       {Select.union D1EqupMs Node.D2DIDA.model.mothers}
	    in
	       %% up_D1(v) subseteq equp_D1_mothers_D2(v)
	       {FS.subset Node.D1DIDA.model.up D1EqupD2MothersM}
	    end
	    
	    if MotherCardsB then
	       %% |mothers_D1(v)| = |mothers_D2(v)|
	       {FD.equal
		{FS.card Node.D1DIDA.model.mothers}
		{FS.card Node.D2DIDA.model.mothers}}
	    end
	 end
      end
   end
end
