%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      EntryIndexDs = {Map Nodes
		      fun {$ Node} Node.entryIndex end}
   in
      {FD.distribute ff EntryIndexDs}
   end
end
