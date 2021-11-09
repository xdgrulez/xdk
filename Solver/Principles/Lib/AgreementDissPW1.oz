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
      DIDA = {Principle.dVA2DIDA 'D'}
      AgrMs = {Map NodeRecs
	       fun {$ NodeRec}
		  M = {FS.var.decl}
		  {FS.cardRange 1 1 M}
		  {FS.include NodeRec.DIDA.attrs.agr M}
	       in
		  M
	       end}
   in
      for NodeRec in NodeRecs do
	 local
	    V1M = NodeRec.DIDA.model.daughtersL.det
	    M = {FS.var.decl}
	    {FS.cardRange 1 1 M}
	    {FS.include NodeRec.DIDA.attrs.agr M}
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.equal M {Select.union AgrMs V1M}}} = 1
	 end
	 local
	    V1M = NodeRec.DIDA.model.daughtersL.subj
	    M = {FS.var.decl}
	    {FS.cardRange 1 1 M}
	    {FS.include NodeRec.DIDA.attrs.agr M}
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.equal M {Select.union AgrMs V1M}}} = 1
	 end
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.conj 
%                {PW.impl 
%                 {PW.ledge
%                  VNodeRec V1NodeRec 'det' {Principle.dVA2DIDA 'D'}}
%                 fun {$}
%                    {PW.eq
%                     VNodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr' V1NodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr'}
%                 end
%                }
%                fun {$}
%                   {PW.impl 
%                    {PW.ledge
%                     VNodeRec V1NodeRec 'subj' {Principle.dVA2DIDA 'D'}}
%                    fun {$}
%                       {PW.eq
%                        VNodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr' V1NodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr'}
%                    end
%                   }
%                end
%               }
%            end}
%        end}
%       = 1
   end
end
