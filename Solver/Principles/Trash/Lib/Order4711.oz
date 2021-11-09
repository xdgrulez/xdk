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
      Lat1 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'order')) 1)]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([tdom(entry('D' 'order')) ttuple([tproj(tdom(entry('D' 'order')) 1) label('D')]) ttuple([label('D') tproj(tdom(entry('D' 'order')) 2)]) ttuple([label('D') label('D')])]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'order')) 2)]) NodeRecs G Principle}
   in
      local UsrD = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat1
            fun {$ UsrLA UsrLI}
               local Auto2I = {ByNeed fun {$}
                   {PW.eq
                    UsrLI
                    {Lat1.aI2I '^'}}
                 end}
               in
                local Auto1I = {ByNeed fun {$}
                    {PW.daughtersLPrecEq
                     UsrVNodeRec NodeRecs UsrLA {Principle.dVA2DIDA UsrD}}
                  end}
                in
                 {PW.forallDom Lat3
                  fun {$ UsrL1A UsrL1I}
                     {PW.impl 
                      {PW.'in'
                       {Lat2.aIs2I [UsrLA UsrL1A]}
                       UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'order'}
                      fun {$}
                         {PW.conj 
                          {PW.conj 
                           {PW.impl 
                            Auto2I
                            fun {$}
                               {PW.eqPrecDaughtersL
                                UsrVNodeRec NodeRecs UsrL1A {Principle.dVA2DIDA UsrD}}
                            end}
                           fun {$}
                              {PW.impl 
                               {PW.eq
                                UsrL1I
                                {Lat3.aI2I '^'}}
                               fun {$}
                                  Auto1I
                               end}
                           end}
                          fun {$}
                             {PW.daughtersLPrecDaughtersL
                              UsrVNodeRec NodeRecs UsrLA UsrL1A {Principle.dVA2DIDA UsrD}}
                          end}
                      end}
                  end}
                end %local
               end %local
            end}
        end}
       = 1
      end %local
   end
end