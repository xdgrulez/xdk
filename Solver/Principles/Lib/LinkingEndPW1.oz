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
      Lat2 = {PW.t2Lat label('D2') NodeRecs G Principle}
      Lat3 = {PW.t2Lat tuple([label('D1') label('D2')]) NodeRecs G Principle}
      D2LabelsMs = {Map NodeRecs
		    fun {$ NodeRec} NodeRec.D2DIDA.model.labels end}
   in
      for NodeRec in NodeRecs do
	 for LA1 in Lat1.constants do
	    for LA2 in Lat2.constants do
	       V1M = NodeRec.D1DIDA.model.daughtersL.LA1
	    in
	       {FD.impl
		{FD.conj
		 {FD.nega
		  {FS.reified.equal V1M FS.value.empty}}
		 {FS.reified.include
		  {Lat3.aIs2I [LA1 LA2]} NodeRec.D3DIDA.entry.linkEnd}}
		{FS.reified.include
		 {Lat2.aI2I LA2}
		 {Select.union D2LabelsMs V1M}}} = 1
	    end
	 end
      end
%       Lat1 = {PW.t2Lat label('D1') NodeRecs G Principle}
%       Lat2 = {PW.t2Lat label('D2') NodeRecs G Principle}
%       Lat3 = {PW.t2Lat tuple([label('D1') label('D2')]) NodeRecs G Principle}
%    in
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.forallDom Lat1
%                fun {$ LA LI}
%                   {PW.forallDom Lat2
%                    fun {$ L1A L1I}
%                       {PW.impl 
%                        {PW.conj 
%                         {PW.ledge
%                          VNodeRec V1NodeRec LA {Principle.dVA2DIDA 'D1'}}
%                         fun {$}
%                            {PW.'in'
%                             {Lat3.aIs2I [LA L1A]} VNodeRec.{Principle.dVA2DIDA 'D3'}.entry.'linkEnd'}
%                         end
%                        }
%                        fun {$}
%                           {PW.oneOrMoreMothersL
%                            V1NodeRec L1A {Principle.dVA2DIDA 'D2'}}
%                        end
%                       }
%                    end}
%                end}
%            end}
%        end}
%       = 1
   end
end
