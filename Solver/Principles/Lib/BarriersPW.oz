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
      Lat1 = {PW.t2Lat eq([label('D2') tdom(entry('D3' 'blocks'))]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.forallNodes NodeRecs
              fun {$ UsrV2NodeRec}
                 {PW.impl 
                  {PW.conj 
                   {PW.oneOrMore
                    {FS.intersect
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.mothers
                     UsrV2NodeRec.{Principle.dVA2DIDA UsrD2}.model.up}}
                   fun {$}
                      {PW.dom
                       UsrV2NodeRec UsrVNodeRec {Principle.dVA2DIDA UsrD2}}
                   end}
                  fun {$}
                     {PW.forallDom Lat1
                      fun {$ UsrLA UsrLI}
                         {PW.impl 
                          {PW.oneOrMoreMothersL
                           UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD2}}
                          fun {$}
                             {PW.notin
                              UsrLI
                              UsrV2NodeRec.{Principle.dVA2DIDA UsrD3}.entry.'blocks'}
                          end}
                      end}
                  end}
              end}
          end}
         = 1
        end %local
       end %local
      end %local
   end
end
