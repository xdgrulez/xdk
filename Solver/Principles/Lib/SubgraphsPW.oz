%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)

%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

export
   Constraint
define
   proc {Constraint NodeRecs G Principle FD FS PW Select}
      Lat1 = {PW.t2Lat label('D1') G Principle}
      Lat2 = {PW.t2Lat label('D2') G Principle}
   in
      {PW.forallNodes NodeRecs
       fun {$ VNodeRec}
          {PW.forallDom Lat1
           fun {$ LA LI}
              {PW.impl 
               {PW.neq
                VNodeRec.{Principle.dVA2DIDA 'D3'}.entry.'start' FS.value.empty}
               fun {$}
                  {PW.forallNodes NodeRecs
                   fun {$ V1NodeRec}
                      {PW.impl 
                       {PW.ldom
                        VNodeRec V1NodeRec LA {Principle.dVA2DIDA 'D1'}}
                       fun {$}
                          {PW.existsDom Lat2
                           fun {$ L1A L1I}
                              {PW.ldom
                               VNodeRec V1NodeRec L1A {Principle.dVA2DIDA 'D2'}}
                           end}
                       end
                      }
                   end}
               end
              }
           end}
       end}
      = 1
   end
end
