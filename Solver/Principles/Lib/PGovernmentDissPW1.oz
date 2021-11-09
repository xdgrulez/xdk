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
%      Lat1 = {PW.t2Lat set(tuple([dom(['first' 'second' 'third']) dom(['sg' 'pl']) dom(['masc' 'fem' 'neut']) dom(['nom' 'acc'])])) NodeRecs G Principle}
      PAgrMs = {Map NodeRecs
		fun {$ NodeRec}
		   M = {FS.var.decl}
		   {FS.cardRange 1 1 M}
		   {FS.include NodeRec.DIDA.attrs.pagr M}
		in
		   M
		end}
   in
      for NodeRec in NodeRecs do
	 local
	    V1M = NodeRec.DIDA.model.daughtersL.pobj1
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.subset
	      {Select.union PAgrMs V1M}
	      NodeRec.DIDA.entry.pobj1}} = 1
	 end
	 local
	    V1M = NodeRec.DIDA.model.daughtersL.pobj2
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.subset
	      {Select.union PAgrMs V1M}
	      NodeRec.DIDA.entry.pobj2}} = 1
	 end
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.conj 
%                {PW.conj 
%                 {PW.impl 
%                  {PW.ledge
%                   VNodeRec V1NodeRec 'subj' {Principle.dVA2DIDA 'D'}}
%                  fun {$}
%                     {PW.'in'
%                      V1NodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr' {Lat1.encodeProc1 elem(tag:constant data:nom)}}
%                  end
%                 }
%                 fun {$}
%                    {PW.impl 
%                     {PW.ledge
%                      VNodeRec V1NodeRec 'obj' {Principle.dVA2DIDA 'D'}}
%                     fun {$}
%                        {PW.'in'
%                         V1NodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr' {Lat1.encodeProc1 elem(tag:constant data:acc)}}
%                     end
%                    }
%                 end
%                }
%                fun {$}
%                   {PW.impl 
%                    {PW.ledge
%                     VNodeRec V1NodeRec 'prepc' {Principle.dVA2DIDA 'D'}}
%                    fun {$}
%                       {PW.'in'
%                        V1NodeRec.{Principle.dVA2DIDA 'D'}.attrs.'agr' {Lat1.encodeProc1 elem(tag:constant data:acc)}}
%                    end
%                   }
%                end
%               }
%            end}
%        end}
%       = 1
   end
end
