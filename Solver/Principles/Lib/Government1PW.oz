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
      Lat1 = {PW.t2Lat eq([tdom(entry('D' 'govern1')) ttuple([tproj(tdom(entry('D' 'govern1')) 1) attrs('D' 'agr')]) ttuple([label('D') tproj(tdom(entry('D' 'govern1')) 2)]) ttuple([label('D') attrs('D' 'agr')])]) NodeRecs G Principle}
      Lat2 = {PW.t2Lat eq([attrs('D' 'agr') tproj(tdom(entry('D' 'govern1')) 2)]) NodeRecs G Principle}
      Lat3 = {PW.t2Lat eq([label('D') tproj(tdom(entry('D' 'govern1')) 1)]) NodeRecs G Principle}
   in
      local UsrD = 'D' in
       {PW.forallNodes NodeRecs
        fun {$ UsrVNodeRec}
           {PW.forallNodes NodeRecs
            fun {$ UsrV1NodeRec}
               {PW.forallDom Lat3
                fun {$ UsrLA UsrLI}
                   {PW.impl 
                    {PW.conj 
                     {PW.ledge
                      UsrVNodeRec UsrV1NodeRec UsrLA {Principle.dVA2DIDA UsrD}}
                     fun {$}
                        {PW.existsDom Lat2
                         fun {$ UsrAA UsrAI}
                            {PW.'in'
                             {Lat1.aIs2I [UsrLA UsrAA]}
                             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'govern1'}
                         end}
                     end}
                    fun {$}
                       {PW.existsDom Lat2
                        fun {$ UsrAA UsrAI}
                           {PW.conj 
                            {PW.'in'
                             {Lat1.aIs2I [UsrLA UsrAA]}
                             UsrVNodeRec.{Principle.dVA2DIDA UsrD}.entry.'govern1'}
                            fun {$}
                               {PW.eq
                                UsrAI
                                UsrV1NodeRec.{Principle.dVA2DIDA UsrD}.attrs.'agr'}
                            end}
                        end}
                    end}
                end}
            end}
        end}
       = 1
      end %local
   end
end
