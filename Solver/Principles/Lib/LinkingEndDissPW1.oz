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
      D2LabelLat = {G.dIDA2LabelLat D2DIDA}
      D2LabelsMs = {Map NodeRecs
		    fun {$ NodeRec} NodeRec.D2DIDA.model.labels end}
   in      
      for NodeRec in NodeRecs do
	 local
	    V1M = NodeRec.D1DIDA.model.daughtersL.mf1
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.subset
	      {FS.value.make {D2LabelLat.aI2I iobj}}
	      {Select.union D2LabelsMs V1M}}} = 1
	 end
	 local
	    V1M = NodeRec.D1DIDA.model.daughtersL.mf2
	 in
	    {FD.impl
	     {FD.nega
	      {FS.reified.equal V1M FS.value.empty}}
	     {FS.reified.subset
	      {FS.value.make {D2LabelLat.aI2I obj}}
	      {Select.union D2LabelsMs V1M}}} = 1
	 end
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
% 	  {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.conj 
%                {PW.impl 
%                 {PW.ledge
%                  VNodeRec V1NodeRec 'mf1' {Principle.dVA2DIDA 'D1'}}
%                 fun {$}
%                    {PW.oneOrMoreMothersL
%                     V1NodeRec 'iobj' {Principle.dVA2DIDA 'D2'}}
%                 end
%                }
%                fun {$}
%                   {PW.impl 
%                    {PW.ledge
%                     VNodeRec V1NodeRec 'mf2' {Principle.dVA2DIDA 'D1'}}
%                    fun {$}
%                       {PW.oneOrMoreMothersL
%                        V1NodeRec 'obj' {Principle.dVA2DIDA 'D2'}}
%                    end
%                   }
%                end
%               }
%            end}
%        end}
%       = 1
   end
end
