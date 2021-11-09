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
      Lat1 = {PW.t2Lat tset(attrs('D' 'agr')) NodeRecs G Principle}
   in
      local UsrD = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ UsrV1NodeRec}
           {PW.eq
            {FS.intersect
             {PW.ifThenElseSet
              {PW.'in'
               UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.attrs.'agr'
               {Lat1.encodeProc1 elem(tag:constant data:nom)}}
              NodeRecs.1.nodeSet
              {FS.diff
               NodeRecs.1.nodeSet
               UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.model.mothersL.'subj'}}
             {PW.ifThenElseSet
              {PW.'in'
               UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.attrs.'agr'
               {Lat1.encodeProc1 elem(tag:constant data:acc)}}
              NodeRecs.1.nodeSet
              {FS.diff
               NodeRecs.1.nodeSet
               UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.model.mothersL.'obj'}}}
            NodeRecs.1.nodeSet}
        end}
       = 1
      end %local
   end
end
