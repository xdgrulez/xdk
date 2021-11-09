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
   Constraint
define
   proc {Constraint NodeRecs G Principle FD FS Select PW ByNeed}
      Lat1 = {PW.t2Lat eq([label('D2') tdom(entry('D1' 'link'))]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        {PW.forallNodes NodeRecs
         fun {$ UsrVNodeRec}
            {PW.forallDom Lat1
             fun {$ UsrLA UsrLI}
                {PW.impl 
                 {PW.'in'
                  UsrLI
                  UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.entry.'link'}
                 fun {$}
                    {PW.subseteq
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.daughtersL.UsrLA
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.up}
                 end}
             end}
         end}
        = 1
       end %local
      end %local
   end
end
