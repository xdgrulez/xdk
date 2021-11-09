%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
export
   DistributeDs
   DistributeMs
   DistributeMRecs
prepare
   RecordToList = Record.toList
define
   proc {DistributeDs Ds FD}
      {FD.distribute ff Ds}
   end
   %%
   proc {DistributeMs Ms FS}
      {FS.distribute naive Ms}
   end
   %%
   proc {DistributeMRecs MRecs FS}
      {FS.distribute naive
       {FoldL MRecs fun {$ AccMs MRec}
		       Ms = {RecordToList MRec}
		    in
		       {Append AccMs Ms}
		    end nil}}
   end
end
