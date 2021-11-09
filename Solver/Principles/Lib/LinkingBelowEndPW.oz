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
      Lat1 = {PW.t2Lat eq([tdom(entry('D3' 'linkBelowEnd')) ttuple([tproj(tdom(entry('D3' 'linkBelowEnd')) 1) label('D2')]) ttuple([label('D1') tproj(tdom(entry('D3' 'linkBelowEnd')) 2)]) ttuple([label('D1') label('D2')])]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([label('D2') tproj(tdom(entry('D3' 'linkBelowEnd')) 2)]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([label('D1') tproj(tdom(entry('D3' 'linkBelowEnd')) 1)]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.forallNodes NodeRecs
              fun {$ UsrV1NodeRec}
                 {PW.forallDom Lat3
                  fun {$ UsrLA UsrLI}
                     {PW.impl 
                      {PW.conj 
                       {PW.ledge
                        UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD1}}
                       fun {$}
                          {PW.existsDom Lat2
                           fun {$ UsrL1A UsrL1I}
                              {PW.'in'
                               {Lat1.aIs2I [UsrLA UsrL1A]}
                               UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'linkBelowEnd'}
                           end}
                       end}
                      fun {$}
                         {PW.existsDom Lat2
                          fun {$ UsrL1A UsrL1I}
                             {PW.conj 
                              {PW.'in'
                               {Lat1.aIs2I [UsrLA UsrL1A]}
                               UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'linkBelowEnd'}
                              fun {$}
                                 {PW.oneOrMore
                                  {FS.intersect
                                   UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.eqdown
                                   UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothersL.UsrL1A}}
                              end}
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
