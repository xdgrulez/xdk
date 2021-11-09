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
      local D = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ VNodeRec}
           {PW.impl 
            {PW.neq
             VNodeRec.{Principle.dVA2DIDA D}.entry.'agrs'
             FS.value.empty}
            fun {$}
               {PW.'in'
                VNodeRec.{Principle.dVA2DIDA D}.attrs.'agr'
                VNodeRec.{Principle.dVA2DIDA D}.entry.'agrs'}
            end}
        end}
       = 1
      end %local
   end
end
