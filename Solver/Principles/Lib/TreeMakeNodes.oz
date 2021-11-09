%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'TreeMakeNodes.oz' Nodes
	  [DIDA#mothers
	   DIDA#equp
	   DIDA#eq
	   DIDA#up
	   DIDA#eqdown
	   DIDA#down
	   DIDA#labels
	   DIDA#daughtersL]} then
	 Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
      in
	 for Model in Models do
	    %% each node has at most one mother
	    {FD.lesseq {FS.card Model.mothers} 1}
	    %% equp(v) = eq(v) uplus up(v)
	    Model.equp = {FS.partition [Model.eq Model.up]}
	    %% eqdown(v) = eq(v) uplus down(v)
	    Model.eqdown = {FS.partition [Model.eq Model.down]}
	    %% eq(v) = equp(v) intersect eqdown(v)
	    Model.eq = {FS.intersect Model.equp Model.eqdown}
	    %% daughters(v) = uplus{ daughters_l(v) | l in labels }
	    Model.daughters = {FS.partition Model.daughtersL}
	    %% post additional constraints if the graph principle has
	    %% feature mothersL
	    if {HasFeature Model mothersL} then
	       %% mothers(v) = uplus{ mothers_l(v) | l in labels }
	       Model.mothers = {FS.partition Model.mothersL}
	    end
	    %% post additional constraints if the graph principle has
	    %% feature upL
	    if {HasFeature Model upL} then
	       %% up(v) = uplus{ up_l(v) | l in labels }
	       Model.up = {FS.partition Model.upL}
	    end
	    %% post additional constraints if the graph principle has
	    %% feature downL
	    if {HasFeature Model downL} then
	       %% down(v) = uplus{ down_l(v) | l in labels }
	       Model.down = {FS.partition Model.downL}
	    end
	    %% post additional constraints if the tree is ordered
	    if {HasFeature Model yieldL} andthen
	       {HasFeature Model yieldS} then
	       %% yieldS(v) = uplus{ yield_l(v) | l in labels }
	       Model.yieldS = {FS.partition Model.yieldL}
	    end
	    %%
	    if {HasFeature Model pos} andthen
	       {HasFeature Model yield} andthen
	       {HasFeature Model yieldS} then
	       %% yield(v) = pos(v) uplus yieldS(v)
	       Model.yield = {FS.partition [Model.pos Model.yieldS]}
	    end
	 end
      end
   end
end
