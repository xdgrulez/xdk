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
   in
      %% check features
      if {Helpers.checkModel 'Barriers.oz' Nodes
	  [D2DIDA#down
	   D1DIDA#mothers
	   D2DIDA#up
	   D2DIDA#labels]} then
	 D2DownMs = {Map Nodes
		     fun {$ Node} Node.D2DIDA.model.down end}
	 %%
	 BlocksMs = {Map Nodes
		     fun {$ Node}
			BlocksM = {ArgRecProc 'Blocks' o('_':Node)}
		     in
			BlocksM
		     end}
      in
	 for Node in Nodes do
	    %% get all nodes below my D1 mother on D2
	    %% down_D2_mothers_D1(v) = union { down_D2(v') | v' in
	    %% mothers_D1(v) }
	    D2DownD1MothersM = {Select.union D2DownMs Node.D1DIDA.model.mothers}
	    %% from this set, keep only those nodes which are above
	    %% me, these are then between my D1 mother and myself on
	    %% D2
	    %% between(v) = down_D2_mothers_D1(v) intersect up_D2(v)
	    BetweenM = {FS.intersect D2DownD1MothersM Node.D2DIDA.model.up}
	    %% get all edge labels which are blocked by the nodes in
	    %% between(v)
	    %% blocked(v) = union { blocks(v') | v' in between(v) }
	    BlockedLM = {Select.union BlocksMs BetweenM}
	 in
	    %% my incoming edge labels set must be disjoint from the
	    %% set of blocked labels.
	    %% labels_D2(v) disjoint blocked(v)
	    {FS.disjoint Node.D2DIDA.model.labels BlockedLM}
	 end
      end
   end
end
