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
       {PW.conj 
        {PW.forallNodes NodeRecs
         fun {$ UsrVNodeRec}
            {PW.eq
             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.daughtersL.'sameAs'
             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.mothersL.'sameAs'}
         end}
        fun {$}
           {PW.forallNodes NodeRecs
            fun {$ UsrVNodeRec}
               {PW.forallNodes NodeRecs
                fun {$ UsrV1NodeRec}
                   {PW.impl 
                    {PW.edge
                     UsrVNodeRec UsrV1NodeRec {Principle.dVA2DIDA UsrD}}
                    fun {$}
                       {PW.subseteq
                        UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.model.daughters
                        UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.daughters}
                    end}
                end}
            end}
        end}
       = 1
      end %local
   end
end
