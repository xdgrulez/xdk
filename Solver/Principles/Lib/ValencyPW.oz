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
      Lat1 = {PW.t2Lat eq([tdom(entry('D' 'in')) ttuple([label('D') tproj(tdom(entry('D' 'in')) 2)])]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'in')) 1)]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([tdom(entry('D' 'out')) ttuple([label('D') tproj(tdom(entry('D' 'out')) 2)])]) NodeRecs G Principle}
      Lat4 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'out')) 1)]) NodeRecs G Principle}
   in
      local UsrD = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat2
            fun {$ UsrLA UsrLI}
               local Auto7I = {ByNeed fun {$}
                   {PW.'in'
                    {Lat1.aIs2I [UsrLA '!']}
                    UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                 end}
               in
                local Auto4I = {ByNeed fun {$}
                    {PW.'in'
                     {Lat1.aIs2I [UsrLA '+']}
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                  end}
                in
                 local Auto1I = {ByNeed fun {$}
                     {PW.'in'
                      {Lat1.aIs2I [UsrLA '?']}
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                   end}
                 in
                  {PW.conj 
                   {PW.conj 
                    {PW.conj 
                     {PW.impl 
                      Auto7I
                      fun {$}
                         {PW.oneMotherL
                          UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                      end}
                     fun {$}
                        {PW.impl 
                         Auto4I
                         fun {$}
                            {PW.oneOrMoreMothersL
                             UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                         end}
                     end}
                    fun {$}
                       {PW.impl 
                        Auto1I
                        fun {$}
                           {PW.zeroOrOneMothersL
                            UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                        end}
                    end}
                   fun {$}
                      {PW.impl 
                       {PW.conj 
                        {PW.conj 
                         {PW.conj 
                          {PW.nega 
                           Auto7I}
                          fun {$}
                             {PW.nega 
                              Auto4I}
                          end}
                         fun {$}
                            {PW.nega 
                             Auto1I}
                         end}
                        fun {$}
                           {PW.nega 
                            {PW.'in'
                             {Lat1.aIs2I [UsrLA '*']}
                             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}}
                        end}
                       fun {$}
                          {PW.zeroMothersL
                           UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                       end}
                   end}
                 end %local
                end %local
               end %local
            end}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat4
            fun {$ UsrLA UsrLI}
               local Auto16I = {ByNeed fun {$}
                   {PW.'in'
                    {Lat3.aIs2I [UsrLA '!']}
                    UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}
                 end}
               in
                local Auto13I = {ByNeed fun {$}
                    {PW.'in'
                     {Lat3.aIs2I [UsrLA '+']}
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}
                  end}
                in
                 local Auto10I = {ByNeed fun {$}
                     {PW.'in'
                      {Lat3.aIs2I [UsrLA '?']}
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}
                   end}
                 in
                  {PW.conj 
                   {PW.conj 
                    {PW.conj 
                     {PW.impl 
                      Auto16I
                      fun {$}
                         {PW.oneDaughterL
                          UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                      end}
                     fun {$}
                        {PW.impl 
                         Auto13I
                         fun {$}
                            {PW.oneOrMoreDaughtersL
                             UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                         end}
                     end}
                    fun {$}
                       {PW.impl 
                        Auto10I
                        fun {$}
                           {PW.zeroOrOneDaughtersL
                            UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                        end}
                    end}
                   fun {$}
                      {PW.impl 
                       {PW.conj 
                        {PW.conj 
                         {PW.conj 
                          {PW.nega 
                           Auto16I}
                          fun {$}
                             {PW.nega 
                              Auto13I}
                          end}
                         fun {$}
                            {PW.nega 
                             Auto10I}
                         end}
                        fun {$}
                           {PW.nega 
                            {PW.'in'
                             {Lat3.aIs2I [UsrLA '*']}
                             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}}
                        end}
                       fun {$}
                          {PW.zeroDaughtersL
                           UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                       end}
                   end}
                 end %local
                end %local
               end %local
            end}
        end}
       = 1
      end %local
   end
end
