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

   PW at 'PW.ozf'
export
   Constraint
define
   proc {Constraint NodeRecs G Principle FD FS Select}
      D1DIDA = {Principle.dVA2DIDA 'D1'}
      D2DIDA = {Principle.dVA2DIDA 'D2'}
      D3DIDA = {Principle.dVA2DIDA 'D3'}
      Lat1 = {PW.t2Lat label('D1') NodeRecs G Principle}
   in
      for NodeRec in NodeRecs do
	 for LA in Lat1.constants do
	    V1M = NodeRec.D1DIDA.model.daughtersL.LA
	 in
	    {FD.impl
	     {FD.conj
	      {FD.nega
	       {FS.reified.equal V1M FS.value.empty}}
	      {FS.reified.include {Lat1.aI2I LA} NodeRec.D3DIDA.entry.linkMother}}
	     {FS.reified.subset V1M NodeRec.D2DIDA.model.mothers}} = 1
	 end
      end
%    in
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.forallDom Lat1
%                fun {$ LA LI}
%                   {PW.impl 
%                    {PW.conj 
%                     {PW.ledge
%                      VNodeRec V1NodeRec LA {Principle.dVA2DIDA 'D1'}}
%                     fun {$}
%                        {PW.'in'
%                         LI VNodeRec.{Principle.dVA2DIDA 'D3'}.entry.'linkMother'}
%                     end
%                    }
%                    fun {$}
%                       {PW.edge
%                        V1NodeRec VNodeRec {Principle.dVA2DIDA 'D2'}}
%                    end
%                   }
%                end}
%            end}
%        end}
%       = 1
   end
end
