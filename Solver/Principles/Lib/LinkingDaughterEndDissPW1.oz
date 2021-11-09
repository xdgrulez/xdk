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
   in
      for NodeRec in NodeRecs do
	 {FS.subset
	  NodeRec.D1DIDA.model.daughtersL.vf
	  NodeRec.D2DIDA.model.daughtersL.subj}
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.impl 
%                {PW.ledge
%                 VNodeRec V1NodeRec 'vf' {Principle.dVA2DIDA 'D1'}}
%                fun {$}
%                   {PW.ledge
%                    VNodeRec V1NodeRec 'subj' {Principle.dVA2DIDA 'D2'}}
%                end
%               }
%            end}
%        end}
%       = 1
   end
end
