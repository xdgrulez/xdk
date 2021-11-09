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
      Lat1 = {PW.t2Lat eq([label('D1') tproj(tdom(entry('D3' 'order')) 1)]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([label('D1') tproj(tdom(entry('D3' 'order')) 3)]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([tdom(entry('D3' 'order')) ttuple([tproj(tdom(entry('D3' 'order')) 1) tproj(tdom(entry('D3' 'order')) 2) tproj(tdom(entry('D3' 'order')) 3) label('D2')]) ttuple([tproj(tdom(entry('D3' 'order')) 1) tproj(tdom(entry('D3' 'order')) 2) label('D1') tproj(tdom(entry('D3' 'order')) 4)]) ttuple([tproj(tdom(entry('D3' 'order')) 1) tproj(tdom(entry('D3' 'order')) 2) label('D1') label('D2')]) ttuple([tproj(tdom(entry('D3' 'order')) 1) label('D2') tproj(tdom(entry('D3' 'order')) 3) tproj(tdom(entry('D3' 'order')) 4)]) ttuple([tproj(tdom(entry('D3' 'order')) 1) label('D2') tproj(tdom(entry('D3' 'order')) 3) label('D2')]) ttuple([tproj(tdom(entry('D3' 'order')) 1) label('D2') label('D1') tproj(tdom(entry('D3' 'order')) 4)]) ttuple([tproj(tdom(entry('D3' 'order')) 1) label('D2') label('D1') label('D2')]) ttuple([label('D1') tproj(tdom(entry('D3' 'order')) 2) tproj(tdom(entry('D3' 'order')) 3) tproj(tdom(entry('D3' 'order')) 4)]) ttuple([label('D1') tproj(tdom(entry('D3' 'order')) 2) tproj(tdom(entry('D3' 'order')) 3) label('D2')]) ttuple([label('D1') tproj(tdom(entry('D3' 'order')) 2) label('D1') tproj(tdom(entry('D3' 'order')) 4)]) ttuple([label('D1') tproj(tdom(entry('D3' 'order')) 2) label('D1') label('D2')]) ttuple([label('D1') label('D2') tproj(tdom(entry('D3' 'order')) 3) tproj(tdom(entry('D3' 'order')) 4)]) ttuple([label('D1') label('D2') tproj(tdom(entry('D3' 'order')) 3) label('D2')]) ttuple([label('D1') label('D2') label('D1') tproj(tdom(entry('D3' 'order')) 4)]) ttuple([label('D1') label('D2') label('D1') label('D2')])]) NodeRecs G Principle}
      Lat4 = {PW.t2Lat eq([label('D2') tproj(tdom(entry('D3' 'order')) 4)]) NodeRecs G Principle}
      Lat5 = {PW.t2Lat eq([label('D2') tproj(tdom(entry('D3' 'order')) 2)]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.forallDom Lat1
              fun {$ UsrLA UsrLI}
                 local Auto6I = {ByNeed fun {$}
                     {PW.eq
                      UsrLI
                      {Lat1.aI2I '^'}}
                   end}
                 in
                  {PW.forallDom Lat5
                   fun {$ UsrL1A UsrL1I}
                      local Auto5I = {ByNeed fun {$}
                          {PW.forallNodes NodeRecs
                           fun {$ UsrV1NodeRec}
                              {PW.impl 
                               {PW.oneOrMore
                                {FS.intersect
                                 UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrLA
                                 UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothersL.UsrL1A}}
                               fun {$}
                                  {PW.prec
                                   UsrV1NodeRec UsrVNodeRec}
                               end}
                           end}
                        end}
                      in
                       {PW.forallDom Lat2
                        fun {$ UsrL2A UsrL2I}
                           local Auto3I = {ByNeed fun {$}
                               {PW.impl 
                                {PW.eq
                                 UsrL2I
                                 {Lat2.aI2I '^'}}
                                fun {$}
                                   Auto5I
                                end}
                             end}
                           in
                            {PW.forallDom Lat4
                             fun {$ UsrL3A UsrL3I}
                                {PW.impl 
                                 {PW.'in'
                                  {Lat3.aIs2I [UsrLA UsrL1A UsrL2A UsrL3A]}
                                  UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'order'}
                                 fun {$}
                                    {PW.conj 
                                     {PW.conj 
                                      {PW.impl 
                                       Auto6I
                                       fun {$}
                                          {PW.forallNodes NodeRecs
                                           fun {$ UsrV1NodeRec}
                                              {PW.impl 
                                               {PW.oneOrMore
                                                {FS.intersect
                                                 UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrL2A
                                                 UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothersL.UsrL3A}}
                                               fun {$}
                                                  {PW.prec
                                                   UsrVNodeRec UsrV1NodeRec}
                                               end}
                                           end}
                                       end}
                                      fun {$}
                                         Auto3I
                                      end}
                                     fun {$}
                                        {PW.forallNodes NodeRecs
                                         fun {$ UsrV1NodeRec}
                                            local Auto1I = {ByNeed fun {$}
                                                {PW.oneOrMore
                                                 {FS.intersect
                                                  UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrLA
                                                  UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothersL.UsrL1A}}
                                              end}
                                            in
                                             {PW.forallNodes NodeRecs
                                              fun {$ UsrV2NodeRec}
                                                 {PW.impl 
                                                  {PW.conj 
                                                   Auto1I
                                                   fun {$}
                                                      {PW.oneOrMore
                                                       {FS.intersect
                                                        UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrL2A
                                                        UsrV2NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothersL.UsrL3A}}
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
                        end}
                      end %local
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
