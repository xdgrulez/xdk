%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   
   Domain(make) at '../../../Compiler/Lattices/Domain.ozf'
   Tuple1(make) at '../../../Compiler/Lattices/Tuple.ozf'

   Helpers(checkModel) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'Order2Conditions.oz' Nodes
	  [DIDA#daughters
	   DIDA#daughtersL]} then
	 %% get label lattice LabelLat
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 LAs = LabelLat.constants
	 %%
	 LabelPairLat = {Tuple1.make [LabelLat LabelLat]}
	 %%
	 NodeSetM = Nodes.1.nodeSet
	 %%
	 Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
	 %%
	 YieldMs = {Map Models
		    fun {$ Model} Model.yield end}
	 %%
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
	 %%
	 fun {GetYield Model LA YieldsB}
	    if YieldsB then
	       Model.yieldL.LA
	    else
	       DaughtersLM = Model.daughtersL.LA
	       PosDaughtersLM = {Select.union PosMs DaughtersLM}
	       {FD.equal
		{FS.card PosDaughtersLM}
		{FS.card DaughtersLM}}
	    in
	       PosDaughtersLM
	    end
	 end
      in
	 for Node in Nodes do
	    OrderM = {ArgRecProc 'Order' o('_': Node)}
	    YieldsB = {ArgRecProc 'Yields' o('_': Node)}==2
	    %%
	    Model = Node.DIDA.model
	    %% yieldS(v) = union{ yield(v') | v' in daughters(v) }
	    Model.yieldS = {Select.union YieldMs Model.daughters}	 
	    %% yield(v) = pos(v) union yieldS(v)
	    Model.yield = {FS.unionN [Node.pos Model.yieldS]}
	 in
	    for LA in LAs do
	       %% yield_l(v) = union{ yield(v') | v' in daughtersL_l(v) }
	       Model.yieldL.LA = {Select.union YieldMs Model.daughtersL.LA}
	       %% |daughtersL_l(v)| =< |yieldL_l(v)|
	       {FD.lesseq
		{FS.card Model.daughtersL.LA}
		{FS.card Model.yieldL.LA}}
	    end
	    %% yieldS(v) = union{ yield_l(v) | l in labels }
	    %% i.e. the union of the l-yields of v are its strict yield
	    {FS.unionN Model.yieldL Model.yieldS}
	    %%
	    {FS.equal Model.daughtersL.'^' FS.value.empty}
	    %%
	    for LA1 in LAs do
	       for LA2 in LAs do
		  I = {LabelPairLat.aIs2I [LA1 LA2]}
	       in
		  if {Not {Opti.isIn I OrderM}=='out'} then
		     Ms =
		     if LA1=='^' andthen LA2=='^' then
			nil
		     elseif LA1=='^' then
			[Node.pos {GetYield Model LA2 YieldsB}]
		     elseif LA2=='^' then 
			[{GetYield Model LA1 YieldsB} Node.pos]
		     else
			[{GetYield Model LA1 YieldsB} {GetYield Model LA2 YieldsB}]
		     end
		     %%
		     Ms1 = {Map Ms
			    fun {$ M}
			       M1 = {FS.subset $ NodeSetM}
			    in
			       {FD.impl
				{FS.reified.include I OrderM}
				{FS.reified.equal M M1} 1}
			       %%
			       {FD.impl
				{FD.nega
				 {FS.reified.include I OrderM}}
				{FS.reified.equal M1 FS.value.empty} 1}
			       M1
			    end}
		  in
		     if {Not Ms==nil} then {FS.int.seq Ms1} end
		  end
	       end
	    end
	 end
      end
   end
end
