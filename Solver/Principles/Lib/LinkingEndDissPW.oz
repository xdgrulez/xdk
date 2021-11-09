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
         fun {$ UsrV1NodeRec}
            {PW.eq
             {FS.intersect
              {PW.ifThenElseSet
               {PW.oneOrMoreMothersL
                UsrV1NodeRec 'iobj' {Principle.dVA2DIDA UsrD2}}
               NodeRecs.1.nodeSet
               {FS.diff
                NodeRecs.1.nodeSet
                UsrV1NodeRec.{Principle.dVA2DIDA UsrD1}.model.mothersL.'mf1'}}
              {PW.ifThenElseSet
               {PW.oneOrMoreMothersL
                UsrV1NodeRec 'obj' {Principle.dVA2DIDA UsrD2}}
               NodeRecs.1.nodeSet
               {FS.diff
                NodeRecs.1.nodeSet
                UsrV1NodeRec.{Principle.dVA2DIDA UsrD1}.model.mothersL.'mf2'}}}
             NodeRecs.1.nodeSet}
         end}
        = 1
       end %local
      end %local
   end
end
