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
      Lat1 = {PW.t2Lat attrs('D3' 'truth') NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.impl 
              {PW.zeroMothers
               UsrVNodeRec {Principle.dVA2DIDA UsrD1}}
              fun {$}
                 {PW.eq
                  UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                  {Lat1.aI2I 'true'}}
              end}
          end}
         = 1
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             local Auto4I = {ByNeed fun {$}
                 {PW.eq
                  UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                  {Lat1.aI2I 'true'}}
               end}
             in
              local Auto3I = {ByNeed fun {$}
                  {PW.edge
                   UsrVNodeRec {Nth NodeRecs 1} {Principle.dVA2DIDA UsrD2}}
                end}
              in
               {PW.forallNodes NodeRecs
                fun {$ UsrV1NodeRec}
                   local Auto2I = {ByNeed fun {$}
                       {PW.ledge
                        UsrVNodeRec UsrV1NodeRec 'arg1' {Principle.dVA2DIDA UsrD1}}
                     end}
                   in
                    local Auto1I = {ByNeed fun {$}
                        {PW.eq
                         UsrV1NodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                         {Lat1.aI2I 'true'}}
                      end}
                    in
                     {PW.forallNodes NodeRecs
                      fun {$ UsrV2NodeRec}
                         {PW.impl 
                          {PW.conj 
                           Auto2I
                           fun {$}
                              {PW.ledge
                               UsrVNodeRec UsrV2NodeRec 'arg2' {Principle.dVA2DIDA UsrD1}}
                           end}
                          fun {$}
                             {PW.conj 
                              {PW.equi 
                               Auto4I
                               fun {$}
                                  {PW.impl 
                                   Auto1I
                                   fun {$}
                                      {PW.eq
                                       UsrV2NodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                                       {Lat1.aI2I 'true'}}
                                   end}
                               end}
                              fun {$}
                                 Auto3I
                              end}
                          end}
                      end}
                    end %local
                   end %local
                end}
              end %local
             end %local
          end}
         = 1
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.impl 
              {PW.word
               UsrVNodeRec                '0'}
              fun {$}
                 {PW.conj 
                  {PW.eq
                   UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                   {Lat1.aI2I 'false'}}
                  fun {$}
                     {PW.edge
                      UsrVNodeRec {Nth NodeRecs 1} {Principle.dVA2DIDA UsrD2}}
                  end}
              end}
          end}
         = 1
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.impl 
              {PW.word
               UsrVNodeRec                'var'}
              fun {$}
                 {PW.subseteq
                  UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.'bar'
                  {PW.setForallNodes NodeRecs
                   fun {$ UsrV2NodeRec}
                      local Auto5I = {ByNeed fun {$}
                          {PW.edge
                           UsrVNodeRec UsrV2NodeRec {Principle.dVA2DIDA UsrD2}}
                        end}
                      in
                       {PW.setForallNodes NodeRecs
                        fun {$ UsrV3NodeRec}
                           {PW.ifThenElseSet
                            {PW.impl 
                             Auto5I
                             fun {$}
                                {PW.eq
                                 UsrV2NodeRec.index
                                 UsrV3NodeRec.index}
                             end}
                            NodeRecs.1.nodeSet
                            {FS.diff
                             NodeRecs.1.nodeSet
                             UsrV3NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothers}}
                        end}
                      end %local
                   end}}
              end}
          end}
         = 1
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.impl 
              {PW.word
               UsrVNodeRec                'I'}
              fun {$}
                 {PW.conj 
                  {PW.conj 
                   {PW.eq
                    UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                    {Lat1.aI2I 'false'}}
                   fun {$}
                      {PW.impl 
                       {PW.zeroDaughters
                        UsrVNodeRec {Principle.dVA2DIDA UsrD1}}
                       fun {$}
                          {PW.edge
                           UsrVNodeRec {Nth NodeRecs 1} {Principle.dVA2DIDA UsrD2}}
                       end}
                   end}
                  fun {$}
                     {PW.subseteq
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.'bar'
                      {PW.setForallNodes NodeRecs
                       fun {$ UsrV2NodeRec}
                          local Auto6I = {ByNeed fun {$}
                              {PW.edge
                               UsrVNodeRec UsrV2NodeRec {Principle.dVA2DIDA UsrD2}}
                            end}
                          in
                           {PW.setForallNodes NodeRecs
                            fun {$ UsrV3NodeRec}
                               {PW.ifThenElseSet
                                {PW.impl 
                                 Auto6I
                                 fun {$}
                                    {PW.conj 
                                     {PW.prec
                                      UsrV3NodeRec UsrV2NodeRec}
                                     fun {$}
                                        {PW.nega 
                                         {PW.existsNodes NodeRecs
                                          fun {$ UsrV4NodeRec}
                                             {PW.conj 
                                              {PW.prec
                                               UsrV3NodeRec UsrV4NodeRec}
                                              fun {$}
                                                 {PW.prec
                                                  UsrV4NodeRec UsrV2NodeRec}
                                              end}
                                          end}}
                                     end}
                                 end}
                                NodeRecs.1.nodeSet
                                {FS.diff
                                 NodeRecs.1.nodeSet
                                 UsrV3NodeRec.{Principle.dVA2DIDA UsrD2}.model.mothers}}
                            end}
                          end %local
                       end}}
                  end}
              end}
          end}
         = 1
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             local Auto7I = {ByNeed fun {$}
                 {PW.word
                  UsrVNodeRec                   'var'}
               end}
             in
              {PW.forallNodes NodeRecs
               fun {$ UsrV1NodeRec}
                  {PW.impl 
                   {PW.conj 
                    Auto7I
                    fun {$}
                       {PW.word
                        UsrV1NodeRec                         'var'}
                    end}
                   fun {$}
                      {PW.impl 
                       {PW.oneOrMore
                        {FS.intersect
                         UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.daughters
                         UsrV1NodeRec.{Principle.dVA2DIDA UsrD2}.model.daughters}}
                       fun {$}
                          {PW.eq
                           UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'
                           UsrV1NodeRec.{Principle.dVA2DIDA UsrD3}.attrs.'truth'}
                       end}
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
