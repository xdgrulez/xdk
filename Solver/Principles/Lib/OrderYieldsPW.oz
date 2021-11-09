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
           {PW.zeroDaughtersL
            UsrVNodeRec '^' {Principle.dVA2DIDA UsrD}}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat1
            fun {$ UsrLA UsrLI}
               local Auto3I = {ByNeed fun {$}
                   {PW.eq
                    UsrLI
                    {Lat1.aI2I '^'}}
                 end}
               in
                local Auto2I = {ByNeed fun {$}
                    {PW.forallNodes NodeRecs
                     fun {$ UsrV1NodeRec}
                        {PW.impl 
                         {PW.ldom
                          UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                         fun {$}
                            {PW.prec
                             UsrV1NodeRec UsrVNodeRec}
                         end}
                     end}
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
                            Auto3I
                            fun {$}
                               {PW.forallNodes NodeRecs
                                fun {$ UsrV1NodeRec}
                                   {PW.impl 
                                    {PW.ldom
                                     UsrVNodeRec UsrV1NodeRec UsrL1A {Principle.dVA2DIDA UsrD}}
                                    fun {$}
                                       {PW.prec
                                        UsrVNodeRec UsrV1NodeRec}
                                    end}
                                end}
                            end}
                           fun {$}
                              {PW.impl 
                               {PW.eq
                                UsrL1I
                                {Lat3.aI2I '^'}}
                               fun {$}
                                  Auto2I
                               end}
                           end}
                          fun {$}
                             {PW.forallNodes NodeRecs
                              fun {$ UsrV1NodeRec}
                                 local Auto1I = {ByNeed fun {$}
                                     {PW.ldom
                                      UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                                   end}
                                 in
                                  {PW.forallNodes NodeRecs
                                   fun {$ UsrV2NodeRec}
                                      {PW.impl 
                                       {PW.conj 
                                        Auto1I
                                        fun {$}
                                           {PW.ldom
                                            UsrVNodeRec UsrV2NodeRec UsrL1A {Principle.dVA2DIDA UsrD}}
                                        end}
                                       fun {$}
                                          {PW.prec
                                           UsrV1NodeRec UsrV2NodeRec}
                                       end}
                                   end}
                                 end %local
                              end}
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
