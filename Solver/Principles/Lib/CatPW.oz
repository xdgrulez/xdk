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
           {PW.impl 
            {PW.neq
             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'cats'
             FS.value.empty}
            fun {$}
               {PW.'in'
                UsrVNodeRec.{Principle.dVA2DIDA UsrD}.attrs.'cat'
                UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'cats'}
            end}
        end}
       = 1
      end %local
   end
end
