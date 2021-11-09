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
      local UsrD = 'D' in
       local UsrORD = 'ORD' in
        {PW.forallNodes NodeRecs
         fun {$ UsrVNodeRec}
            {PW.forallNodes NodeRecs
             fun {$ UsrV1NodeRec}
                local Auto1I = {ByNeed fun {$}
                    {PW.edge
                     UsrV1NodeRec UsrVNodeRec {Principle.dVA2DIDA UsrORD}}
                  end}
                in
                 {PW.conj 
                  {PW.impl 
                   {PW.nega 
                    {PW.domeq
                     UsrV1NodeRec UsrVNodeRec {Principle.dVA2DIDA UsrD}}}
                   fun {$}
                      {PW.conj 
                       {PW.impl 
                        Auto1I
                        fun {$}
                           {PW.subseteq
                            UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.model.down
                            UsrVNodeRec.{Principle.dVA2DIDA UsrORD}.model.mothers}
                        end}
                       fun {$}
                          {PW.impl 
                           {PW.oneOrMore
                            {FS.intersect
                             UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.model.down
                             UsrVNodeRec.{Principle.dVA2DIDA UsrORD}.model.mothers}}
                           fun {$}
                              Auto1I
                           end}
                       end}
                   end}
                  fun {$}
                     {PW.impl 
                      {PW.dom
                       UsrVNodeRec UsrV1NodeRec {Principle.dVA2DIDA UsrD}}
                      fun {$}
                         {PW.conj 
                          {PW.impl 
                           Auto1I
                           fun {$}
                              {PW.subseteq
                               {FS.intersect
                                UsrV1NodeRec.{Principle.dVA2DIDA UsrORD}.model.daughters
                                UsrVNodeRec.{Principle.dVA2DIDA UsrORD}.model.mothers}
                               UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.down}
                           end}
                          fun {$}
                             {PW.impl 
                              {PW.edge
                               UsrVNodeRec UsrV1NodeRec {Principle.dVA2DIDA UsrORD}}
                              fun {$}
                                 {PW.subseteq
                                  {FS.intersect
                                   UsrVNodeRec.{Principle.dVA2DIDA UsrORD}.model.daughters
                                   UsrV1NodeRec.{Principle.dVA2DIDA UsrORD}.model.mothers}
                                  UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.down}
                              end}
                          end}
                      end}
                  end}
                end %local
             end}
         end}
        = 1
       end %local
      end %local
   end
end
