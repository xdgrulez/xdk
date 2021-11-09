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
      Lat1 = {PW.t2Lat eq([label('D1') tdom(entry('D3' 'linkMother'))]) NodeRecs G Principle}
   in
      local UsrD1 = 'D1' in
       local UsrD2 = 'D2' in
        local UsrD3 = 'D3' in
         {PW.forallNodes NodeRecs
          fun {$ UsrVNodeRec}
             {PW.forallDom Lat1
              fun {$ UsrLA UsrLI}
                 {PW.impl 
                  {PW.'in'
                   UsrLI
                   UsrVNodeRec.{Principle.dVA2DIDA UsrD3}.entry.'linkMother'}
                  fun {$}
                     {PW.subseteq
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD1}.model.daughtersL.UsrLA
                      UsrVNodeRec.{Principle.dVA2DIDA UsrD2}.model.mothers}
                  end}
              end}
          end}
         = 1
        end %local
       end %local
      end %local
   end
end
