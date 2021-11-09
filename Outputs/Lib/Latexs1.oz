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
   
   Latex(printDags) at 'Latex/Latex.ozf'
export
   Open
   Close
define
   %% Open: DIDA I OutputRec -> U
   %% Prints the LaTeX code (using xdag.sty) for dimension DIDA,
   %% solution I, and output record OutputRec.
   proc {Open DIDA I OutputRec}
      OptRec = o(rootLabels: [root root1 root2]
		 dummyLabels: [dummy del]
		 ghostWords: ['.' '?']
		 %%
		 showDom: true)
      UsedGraphDIDAs = OutputRec.usedGraphDIDAs
   in
      {Latex.printDags UsedGraphDIDAs I OutputRec OptRec}
   end
   %% Close: DIDA -> U
   %% Does nothing.
   proc {Close DIDA}
      skip
   end
end
