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
      Lat1 = {PW.t2Lat label('D') NodeRecs G Principle}
      Lat2 = {PW.t2Lat tdom(entry('D' 'in')) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([label('D') tdom(entry('D' 'in'))]) NodeRecs G Principle}
      Lat4 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'out')) 1)]) NodeRecs G Principle}
      Lat5 = {PW.t2Lat eq([tdom(entry('D' 'out')) ttuple([tproj(tdom(entry('D' 'out')) 1) label('D')]) ttuple([label('D') tproj(tdom(entry('D' 'out')) 2)]) ttuple([label('D') label('D')])]) NodeRecs G Principle}
      Lat6 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'out')) 2)]) NodeRecs G Principle}
   in
      local UsrD = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat2
            fun {$ UsrLA UsrLI}
               {PW.impl 
                {PW.'in'
                 UsrLI
                 UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                fun {$}
                   {PW.forallDom Lat1
                    fun {$ UsrL1A UsrL1I}
                       {PW.impl 
                        {PW.oneOrMoreMothersL
                         UsrVNodeRec UsrL1A {Principle.dVA2DIDA UsrD}}
                        fun {$}
                           {PW.eq
                            UsrL1I
                            UsrLI}
                        end}
                    end}
                end}
            end}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat3
            fun {$ UsrLA UsrLI}
               {PW.impl 
                {PW.notin
                 UsrLI
                 UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                fun {$}
                   {PW.zeroMothersL
                    UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                end}
            end}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           local Auto1I = {ByNeed fun {$}
               {PW.oneOrMoreMothers
                UsrVNodeRec {Principle.dVA2DIDA UsrD}}
             end}
           in
            {PW.forallDom Lat2
             fun {$ UsrLA UsrLI}
                {PW.impl 
                 {PW.conj 
                  {PW.'in'
                   UsrLI
                   UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'in'}
                  fun {$}
                     {PW.nega 
                      {PW.eq
                       UsrLI
                       {Lat2.aI2I 's'}}}
                  end}
                 fun {$}
                    Auto1I
                 end}
             end}
           end %local
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.zeroDaughtersL
            UsrVNodeRec '^' {Principle.dVA2DIDA UsrD}}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat4
            fun {$ UsrLA UsrLI}
               local Auto2I = {ByNeed fun {$}
                   {PW.impl 
                    {PW.nega 
                     {PW.eq
                      UsrLI
                      {Lat4.aI2I '^'}}}
                    fun {$}
                       {PW.oneDaughterL
                        UsrVNodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                    end}
                 end}
               in
                {PW.forallDom Lat6
                 fun {$ UsrL1A UsrL1I}
                    {PW.impl 
                     {PW.'in'
                      {Lat5.aIs2I [UsrLA UsrL1A]}
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}
                     fun {$}
                        {PW.conj 
                         Auto2I
                         fun {$}
                            {PW.impl 
                             {PW.nega 
                              {PW.eq
                               UsrL1I
                               {Lat6.aI2I '^'}}}
                             fun {$}
                                {PW.oneDaughterL
                                 UsrVNodeRec UsrL1A {Principle.dVA2DIDA UsrD}}
                             end}
                         end}
                     end}
                 end}
               end %local
            end}
        end}
       = 1
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallDom Lat4
            fun {$ UsrLA UsrLI}
               local Auto7I = {ByNeed fun {$}
                   {PW.eq
                    UsrLI
                    {Lat4.aI2I '^'}}
                 end}
               in
                {PW.forallDom Lat6
                 fun {$ UsrL1A UsrL1I}
                    local Auto6I = {ByNeed fun {$}
                        {PW.eq
                         UsrL1I
                         {Lat6.aI2I '^'}}
                      end}
                    in
                     {PW.impl 
                      {PW.'in'
                       {Lat5.aIs2I [UsrLA UsrL1A]}
                       UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'out'}
                      fun {$}
                         {PW.conj 
                          {PW.conj 
                           {PW.forallNodes NodeRecs
                            fun {$ UsrV1NodeRec}
                               {PW.impl 
                                {PW.conj 
                                 Auto7I
                                 fun {$}
                                    {PW.ledge
                                     UsrVNodeRec UsrV1NodeRec UsrL1A {Principle.dVA2DIDA UsrD}}
                                 end}
                                fun {$}
                                   {PW.prec
                                    UsrVNodeRec UsrV1NodeRec}
                                end}
                            end}
                           fun {$}
                              {PW.forallNodes NodeRecs
                               fun {$ UsrV1NodeRec}
                                  {PW.impl 
                                   {PW.conj 
                                    {PW.ledge
                                     UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                                    fun {$}
                                       Auto6I
                                    end}
                                   fun {$}
                                      {PW.prec
                                       UsrV1NodeRec UsrVNodeRec}
                                   end}
                               end}
                           end}
                          fun {$}
                             {PW.daughtersLPrecDaughtersL
                              UsrVNodeRec NodeRecs UsrLA UsrL1A {Principle.dVA2DIDA UsrD}}
                          end}
                      end}
                    end %local
                 end}
               end %local
            end}
        end}
       = 1
      end %local
   end
end
