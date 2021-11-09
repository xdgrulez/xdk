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

%   PW at 'PW.ozf'
export
   Constraint
define
   proc {Constraint NodeRecs G Principle FD FS Select}
      D1DIDA = {Principle.dVA2DIDA 'D1'}
      D2DIDA = {Principle.dVA2DIDA 'D2'}
      D1EqupMs = {Map NodeRecs
		  fun {$ NodeRec} NodeRec.D1DIDA.model.equp end}
   in
      for NodeRec in NodeRecs  do
	 V1M = NodeRec.D2DIDA.model.mothers
	 V2M = NodeRec.D1DIDA.model.up
      in
	 {FD.impl
	  {FD.conj 
	   {FD.nega
	    {FS.reified.equal V1M FS.value.empty}}
	   {FD.nega
	    {FS.reified.equal V2M FS.value.empty}}}
	  {FS.reified.subset V2M {Select.union D1EqupMs V1M}}} = 1
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.forallNodes NodeRecs
%                fun {$ V2NodeRec}
%                   {PW.impl 
%                    {PW.conj 
%                     {PW.edge
%                      V1NodeRec VNodeRec {Principle.dVA2DIDA 'D2'}}
%                     fun {$}
%                        {PW.dom
%                         V2NodeRec VNodeRec {Principle.dVA2DIDA 'D1'}}
%                     end
%                    }
%                    fun {$}
%                       {PW.domeq
%                        V2NodeRec V1NodeRec {Principle.dVA2DIDA 'D1'}}
%                    end
%                   }
%                end}
%            end}
%        end}
%       = 1
   end
end
