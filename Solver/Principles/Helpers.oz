%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   IsSubset
define
   %% IsSubset: Xs Ys -> B
   %% Returns true if Xs denotes a subset of Ys, and false if not.
   fun {IsSubset Xs Ys}
      {All Xs
       fun {$ X} {Member X Ys} end}
   end
end
