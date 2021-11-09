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
%      Lat1 = {PW.t2Lat label('D2') NodeRecs G Principle}
      D1DIDA = {Principle.dVA2DIDA 'D1'}
      D2DIDA = {Principle.dVA2DIDA 'D2'}
      D3DIDA = {Principle.dVA2DIDA 'D3'}
      D2DownMs = {Map NodeRecs
		  fun {$ NodeRec} NodeRec.D2DIDA.model.down end}
      BlocksMs = {Map NodeRecs
		  fun {$ NodeRec} NodeRec.D3DIDA.entry.blocks end}
   in
      for NodeRec in NodeRecs do
	 V1M = NodeRec.D1DIDA.model.mothers
	 V2M = {FS.intersect
		{Select.union D2DownMs V1M}
		NodeRec.D2DIDA.model.up}
      in
	 {FD.impl
	  {FD.nega
	   {FS.reified.equal V1M FS.value.empty}}
	  {FS.reified.disjoint
	   NodeRec.D2DIDA.model.labels {Select.union BlocksMs V2M}}} = 1
      end
%       {PW.forallNodes NodeRecs
%        fun {$ VNodeRec}
%           {PW.forallNodes NodeRecs
%            fun {$ V1NodeRec}
%               {PW.forallNodes NodeRecs
%                fun {$ V2NodeRec}
%                   {PW.impl 
%                    {PW.conj 
%                     {PW.conj 
%                      {PW.edge
%                       V1NodeRec VNodeRec {Principle.dVA2DIDA 'D1'}}
%                      fun {$}
%                         {PW.dom
%                          V1NodeRec V2NodeRec {Principle.dVA2DIDA 'D2'}}
%                      end
%                     }
%                     fun {$}
%                        {PW.dom
%                         V2NodeRec VNodeRec {Principle.dVA2DIDA 'D2'}}
%                     end
%                    }
%                    fun {$}
%                       {PW.forallNodes NodeRecs
%                        fun {$ V3NodeRec}
%                           {PW.forallDom Lat1
%                            fun {$ LA LI}
%                               {PW.impl 
%                                {PW.ledge
%                                 V3NodeRec VNodeRec LA {Principle.dVA2DIDA 'D2'}}
%                                fun {$}
%                                   {PW.notin
%                                    LI V2NodeRec.{Principle.dVA2DIDA 'D3'}.entry.'blocks'}
%                                end
%                               }
%                            end}
%                        end}
%                    end
%                   }
%                end}
%            end}
%        end}
%       = 1
   end
end
