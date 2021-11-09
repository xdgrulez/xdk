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
prepare
   RecordForAllInd = Record.forAllInd
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'In1.oz' Nodes
	  [DIDA#mothersL]} then
	 for Node in Nodes do
	    LAInMRec = {ArgRecProc 'In' o('_': Node)}
	 in
	    {RecordForAllInd LAInMRec
	     proc {$ LA InM}
		%% |motherset_l(v)| in in_l(v)
		CardMothersLD = {FS.card Node.DIDA.model.mothersL.LA}
	     in
		{FS.include CardMothersLD InM}
	     end}
	 end
      end
   end
end
