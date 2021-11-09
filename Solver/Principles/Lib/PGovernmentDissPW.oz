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
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallNodes NodeRecs
            fun {$ UsrV1NodeRec}
               {PW.conj 
                {PW.impl 
                 {PW.ledge
                  UsrVNodeRec UsrV1NodeRec 'pobj1' {Principle.dVA2DIDA UsrD}}
                 fun {$}
                    {PW.'in'
                     UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.attrs.'pagr'
                     UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'pobj1'}
                 end}
                fun {$}
                   {PW.impl 
                    {PW.ledge
                     UsrVNodeRec UsrV1NodeRec 'pobj2' {Principle.dVA2DIDA UsrD}}
                    fun {$}
                       {PW.'in'
                        UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.attrs.'pagr'
                        UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'pobj2'}
                    end}
                end}
            end}
        end}
       = 1
      end %local
   end
end
