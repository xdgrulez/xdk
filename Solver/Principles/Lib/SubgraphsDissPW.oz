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
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        {PW.forallNodes NodeRecs
         fun {$ UsrVNodeRec}
            {PW.eq
             {FS.intersect
              {FS.union
               {FS.diff
                NodeRecs.1.nodeSet
                UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.downL.'th'}
               {FS.union
                UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.downL.'bt1'
                UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.downL.'pa1bt1'}}
              {FS.union
               {FS.diff
                NodeRecs.1.nodeSet
                UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.downL.'rh'}
               {FS.union
                UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.downL.'bt2'
                UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.downL.'pa2bt2'}}}
             NodeRecs.1.nodeSet}
         end}
        = 1
       end %local
      end %local
   end
end
