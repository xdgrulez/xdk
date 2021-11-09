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
      Lat1 = {PW.t2Lat eq([label('D1') tdom(entry('D3' 'lockDaughters'))]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             local Auto1I = {ByNeed fun {$}
                 {PW.setForallNodes NodeRecs
                  fun {$ UsrV2NodeRec}
                     {PW.ifThenElseSet
                      {PW.disj 
                       {PW.eq
                        UsrV2NodeRec.index
                        UsrVNodeRec.index}
                       fun {$}
                          {PW.oneOrMore
                           {FS.intersect
                            UsrV2NodeRec.{Principle.dVA2DIDA UsrD1}.model.eqdown
                            UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.mothersL.'th'}}
                       end}
                      NodeRecs.1.nodeSet
                      {FS.union
                       {FS.union
                        UsrV2NodeRec.{Principle.dVA2DIDA UsrD2}.model.daughtersL.'agm'
                        UsrV2NodeRec.{Principle.dVA2DIDA UsrD2}.model.daughtersL.'patm'}
                       {FS.diff
                        NodeRecs.1.nodeSet
                        UsrV2NodeRec.{Principle.dVA2DIDA UsrD2}.model.daughters}}}
                  end}
               end}
             in
              {PW.forallDom Lat1
               fun {$ UsrLA UsrLI}
                  {PW.impl 
                   {PW.'in'
                    UsrLI
                    UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'lockDaughters'}
                   fun {$}
                      {PW.subseteq
                       UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrLA
                       Auto1I}
                   end}
               end}
             end %local
          end}
         = 1
        end %local
       end %local
      end %local
   end
end
