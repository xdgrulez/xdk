%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   
   Dag(showDag closeDags) at 'Dag/Dag.ozf'
export
   Open
   Close
define
   %% Open: DIDA I OutputRec -> U
   %% Opens a NewTkDAG window for dimension DIDA, solution I, and
   %% output record OutputRec.
   proc {Open DIDA I OutputRec}
      OptRec = o(rootLabels: nil
		 dummyLabels: nil
		 ghostWords: nil
		 %%
		 showNew: true
		 showDom: true)
   in
      {Dag.showDag DIDA I OutputRec OptRec}
   end
   %% Close: DIDA -> U
   %% Closes all NewTkDAG windows for dimension DIDA, and resets
   %% NodesDict and EdgesDict.
   proc {Close DIDA}
      {Dag.closeDags}
   end
end
