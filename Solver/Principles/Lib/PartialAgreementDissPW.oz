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
      Lat1 = {PW.t2Lat attrs('D2' 'agr') NodeRecs G Principle}
      Lat2 = {PW.t2Lat tproj(attrs('D2' 'agr') 4) NodeRecs G Principle}
      Lat3 = {PW.t2Lat tproj(attrs('D2' 'agr') 2) NodeRecs G Principle}
      Lat4 = {PW.t2Lat tproj(attrs('D2' 'agr') 1) NodeRecs G Principle}
      Lat5 = {PW.t2Lat tproj(attrs('D2' 'agr') 3) NodeRecs G Principle}
      Lat6 = {PW.t2Lat eq([label('D1') tdom(entry('D3' 'partialAgree'))]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.forallNodes NodeRecs
              fun {$ UsrV1NodeRec}
                 local Auto2I = {ByNeed fun {$}
                     {PW.forallDom Lat5
                      fun {$ UsrT3A UsrT3I}
                         local Auto1I = {ByNeed fun {$}
                             {PW.existsDom Lat4
                              fun {$ Usr1T1A Usr1T1I}
                                 {PW.existsDom Lat3
                                  fun {$ Usr2T2A Usr2T2I}
                                     {PW.existsDom Lat2
                                      fun {$ Usr3T4A Usr3T4I}
                                         {PW.eq
                                          {Lat1.aIs2I [Usr1T1A Usr2T2A UsrT3A Usr3T4A]}
                                          UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.attrs.'agr'}
                                      end}
                                  end}
                              end}
                           end}
                         in
                          {PW.existsDom Lat4
                           fun {$ UsrT1A UsrT1I}
                              {PW.existsDom Lat3
                               fun {$ UsrT2A UsrT2I}
                                  {PW.existsDom Lat2
                                   fun {$ UsrT4A UsrT4I}
                                      {PW.equi 
                                       {PW.eq
                                        {Lat1.aIs2I [UsrT1A UsrT2A UsrT3A UsrT4A]}
                                        UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.attrs.'agr'}
                                       fun {$}
                                          Auto1I
                                       end}
                                   end}
                               end}
                           end}
                         end %local
                      end}
                   end}
                 in
                  {PW.forallDom Lat6
                   fun {$ UsrLA UsrLI}
                      {PW.impl 
                       {PW.conj 
                        {PW.ledge
                         UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD1}}
                        fun {$}
                           {PW.'in'
                            UsrLI
                            UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'partialAgree'}
                        end}
                       fun {$}
                          Auto2I
                       end}
                   end}
                 end %local
              end}
          end}
         = 1
        end %local
       end %local
      end %local
   end
end
