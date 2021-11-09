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
      ArgRecProc = Principle.argRecProc
   in
      %% check features
      if {Helpers.checkModel 'Agr.oz' Nodes nil} then
	 for Node in Nodes do
	    AgrD = {ArgRecProc 'Agr' o('_': Node)}
	    AgrsM = {ArgRecProc 'Agrs' o('_': Node)}
	 in
	    {FS.include AgrD AgrsM}
	 end
      end
   end
end
