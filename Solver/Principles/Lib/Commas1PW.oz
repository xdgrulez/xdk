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
      Lat1 = {PW.t2Lat eq([label('D2') tproj(tdom(entry('D3' 'commas')) 1)]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([label('D2') tproj(tdom(entry('D3' 'commas')) 3)]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([tdom(entry('D3' 'commas')) ttuple([tproj(tdom(entry('D3' 'commas')) 1) tproj(tdom(entry('D3' 'commas')) 2) tproj(tdom(entry('D3' 'commas')) 3) label('D1')]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) tproj(tdom(entry('D3' 'commas')) 2) label('D2') tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) tproj(tdom(entry('D3' 'commas')) 2) label('D2') label('D1')]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) label('D1') tproj(tdom(entry('D3' 'commas')) 3) tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) label('D1') tproj(tdom(entry('D3' 'commas')) 3) label('D1')]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) label('D1') label('D2') tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([tproj(tdom(entry('D3' 'commas')) 1) label('D1') label('D2') label('D1')]) ttuple([label('D2') tproj(tdom(entry('D3' 'commas')) 2) tproj(tdom(entry('D3' 'commas')) 3) tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([label('D2') tproj(tdom(entry('D3' 'commas')) 2) tproj(tdom(entry('D3' 'commas')) 3) label('D1')]) ttuple([label('D2') tproj(tdom(entry('D3' 'commas')) 2) label('D2') tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([label('D2') tproj(tdom(entry('D3' 'commas')) 2) label('D2') label('D1')]) ttuple([label('D2') label('D1') tproj(tdom(entry('D3' 'commas')) 3) tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([label('D2') label('D1') tproj(tdom(entry('D3' 'commas')) 3) label('D1')]) ttuple([label('D2') label('D1') label('D2') tproj(tdom(entry('D3' 'commas')) 4)]) ttuple([label('D2') label('D1') label('D2') label('D1')])]) NodeRecs G Principle}
      Lat4 = {PW.t2Lat eq([label('D1') tproj(tdom(entry('D3' 'commas')) 4)]) NodeRecs G Principle}
      Lat5 = {PW.t2Lat eq([label('D1') tproj(tdom(entry('D3' 'commas')) 2)]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
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
                  {PW.forallDom Lat5
                   fun {$ UsrL1A UsrL1I}
                      {PW.forallDom Lat2
                       fun {$ UsrL2A UsrL2I}
                          local Auto2I = {ByNeed fun {$}
                              {PW.eq
                               UsrL2I
                               {Lat2.aI2I '^'}}
                            end}
                          in
                           {PW.forallDom Lat4
                            fun {$ UsrL3A UsrL3I}
                               {PW.impl 
                                {PW.'in'
                                 {Lat3.aIs2I [UsrLA UsrL1A UsrL2A UsrL3A]}
                                 UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'commas'}
                                fun {$}
                                   {PW.forallNodes NodeRecs
                                    fun {$ UsrV1NodeRec}
                                       local Auto1I = {ByNeed fun {$}
                                           {PW.existsNodes NodeRecs
                                            fun {$ UsrV3NodeRec}
                                               {PW.conj 
                                                {PW.disj 
                                                 {PW.conj 
                                                  Auto3I
                                                  fun {$}
                                                     {PW.eq
                                                      UsrVNodeRec.index
                                                      UsrV3NodeRec.index}
                                                  end}
                                                 fun {$}
                                                    {PW.ledge
                                                     UsrVNodeRec UsrV3NodeRec UsrLA {Principle.dVA2DIDA UsrD2}}
                                                 end}
                                                fun {$}
                                                   {PW.ledge
                                                    UsrV3NodeRec UsrV1NodeRec UsrL1A {Principle.dVA2DIDA UsrD1}}
                                                end}
                                            end}
                                         end}
                                       in
                                        {PW.forallNodes NodeRecs
                                         fun {$ UsrV2NodeRec}
                                            {PW.impl 
                                             {PW.conj 
                                              Auto1I
                                              fun {$}
                                                 {PW.existsNodes NodeRecs
                                                  fun {$ UsrV3NodeRec}
                                                     {PW.conj 
                                                      {PW.disj 
                                                       {PW.conj 
                                                        Auto2I
                                                        fun {$}
                                                           {PW.eq
                                                            UsrVNodeRec.index
                                                            UsrV3NodeRec.index}
                                                        end}
                                                       fun {$}
                                                          {PW.ledge
                                                           UsrVNodeRec UsrV3NodeRec UsrL2A {Principle.dVA2DIDA UsrD2}}
                                                       end}
                                                      fun {$}
                                                         {PW.ledge
                                                          UsrV3NodeRec UsrV2NodeRec UsrL3A {Principle.dVA2DIDA UsrD1}}
                                                      end}
                                                  end}
                                              end}
                                             fun {$}
                                                {PW.existsNodes NodeRecs
                                                 fun {$ UsrV3NodeRec}
                                                    {PW.conj 
                                                     {PW.prec
                                                      UsrV1NodeRec UsrV3NodeRec}
                                                     fun {$}
                                                        {PW.prec
                                                         UsrV3NodeRec UsrV2NodeRec}
                                                     end}
                                                 end}
                                             end}
                                         end}
                                       end %local
                                    end}
                                end}
                            end}
                          end %local
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
