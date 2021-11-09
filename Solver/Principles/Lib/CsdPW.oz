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
               {PW.impl 
                {PW.ledge
                 UsrVNodeRec UsrV1NodeRec 'n' {Principle.dVA2DIDA UsrD}}
                fun {$}
                   {PW.forallNodes NodeRecs
                    fun {$ UsrV3NodeRec}
                       {PW.impl 
                        {PW.oneOrMore
                         {FS.intersect
                          UsrVNodeRec.{Principle.dVA2DIDA UsrD}.model.up
                          UsrV3NodeRec.{Principle.dVA2DIDA UsrD}.model.mothersL.'n'}}
                        fun {$}
                           {PW.prec
                            UsrV3NodeRec UsrV1NodeRec}
                        end}
                    end}
                end}
            end}
        end}
       = 1
      end %local
   end
end
