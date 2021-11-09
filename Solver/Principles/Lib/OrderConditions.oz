%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(checkModel) at 'Helpers.ozf'
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
      if {Helpers.checkModel 'OrderConditions.oz' Nodes
	  [DIDA#daughters
	   DIDA#daughtersL]} then
	 %% get label lattice LabelLat
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 LCardI = LabelLat.card
	 %%
	 Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
	 %%
	 YieldMs = {Map Models
		    fun {$ Model} Model.yield end}
	 %%
	 PosMs = {Map Nodes
		  fun {$ Node} Node.pos end}
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model
	    %% yield(v) = union{ pos(v') | v' in eqdown(v) }
	    Model.yield = {Select.union PosMs Model.eqdown}
	    %% yieldS(v) = union{ pos(v') | v' in down(v) }
	    Model.yieldS = {Select.union PosMs Model.down}
	    %% yieldS(v) = union{ yield(v') | v' in daughters(v) }
	    Model.yieldS = {Select.union YieldMs Model.daughters}	 
	    for LA in LabelLat.constants do
	       %% yield_l(v) = union{ yield(v') | v' in daughtersL_l(v) }
	       Model.yieldL.LA = {Select.union YieldMs Model.daughtersL.LA}
	       %% |daughtersL_l(v)| =< |yieldL_l(v)|
	       {FD.lesseq
		{FS.card Model.daughtersL.LA}
		{FS.card Model.yieldL.LA}}
	    end
	    %% yieldS(v) = union{ yield_l(v) | l in labels }
	    %% i.e. the union of the l-yields of v are its strict yield
	    Model.yieldS = {FS.unionN Model.yieldL}
	    %% yield(v) = pos(v) union yieldS(v)
	    Model.yield = {FS.unionN [Node.pos Model.yieldS]}
	    %% get ordered list of projections:
	    %% ProjLMs describes
	    %% proj: V -> (L -> 2^Pos) (Pos is the set of positions), where:
	    %% 1) if YieldsB==true then
	    %%   proj(v)(l) = yieldL(v)(l) union selfSet(v)(l)
	    %% 2) if YieldsB==false then
	    %%   proj(v)(l) = union{ pos(v') | v' in daughters(v)(l) } union
	    %%                selfSet(v)(l)
	    OrderLIs = {ArgRecProc 'Order' o('_': Node)}
	    OrderLCardI = {Length OrderLIs}
	    OrderLAs = {Map OrderLIs LabelLat.i2AI}
	    YieldsB = {ArgRecProc 'Yields' o('_': Node)}==2
	    OrderProjLMs =
	    {Map OrderLAs
	     fun {$ LA}
		M =
		if YieldsB then
		   Model.yieldL.LA
		else
		   DaughtersLM = Model.daughtersL.LA
		   PosDaughtersLM = {Select.union PosMs DaughtersLM}
		in
		   %% opti
		   {FD.equal
		    {FS.card PosDaughtersLM}
		    {FS.card DaughtersLM}}
		   PosDaughtersLM
		end
	     in
		{FS.union M Model.selfSet.LA}
	     end}
	 in
	    %% order the projections list
	    if YieldsB andthen OrderLCardI==LCardI then
	       {Select.seqUnion OrderProjLMs Model.yield}
	    else
	       {FS.int.seq OrderProjLMs}
	    end
	 end
      end
   end
end
