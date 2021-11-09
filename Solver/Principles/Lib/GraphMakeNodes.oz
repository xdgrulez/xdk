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
prepare
   RecordForAll = Record.forAll
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
   in      
      if {Helpers.checkModel 'GraphMakeNodes.oz' Nodes nil} then
	 DIDA = {DVA2DIDA 'D'}
	 %%
	 NodeSetM = Nodes.1.nodeSet
      in
	 for Node in Nodes do
	    IndexI = Node.index
	    Model = Node.DIDA.model
	 in
	    {FS.subset Model.mothers NodeSetM}
	    {FS.subset Model.daughters NodeSetM}
	    {FS.equal Model.eq {FS.value.singl IndexI}}
	    {FS.subset Model.up NodeSetM}
	    {FS.subset Model.equp NodeSetM}
	    {FS.subset Model.down NodeSetM}
	    {FS.subset Model.eqdown NodeSetM}
	    {RecordForAll Model.mothersL proc {$ M} {FS.subset M NodeSetM} end}
	    {RecordForAll Model.daughtersL proc {$ M} {FS.subset M NodeSetM} end}
	    {RecordForAll Model.upL proc {$ M} {FS.subset M NodeSetM} end}
	    {RecordForAll Model.downL proc {$ M} {FS.subset M NodeSetM} end}
	    %% mothers(v) = union{ mothers_l(v) | l in labels }
	    {FS.unionN Model.mothersL Model.mothers}
	    %% daughters(v) = union{ daughters_l(v) | l in labels }
	    {FS.unionN Model.daughtersL Model.daughters}
	    %% up(v) = union{ up_l(v) | l in labels }
	    {FS.unionN Model.upL Model.up}
	    %% down(v) = union{ down_l(v) | l in labels }
	    {FS.unionN Model.downL Model.down}
	    %% equp(v) = eq(v) union up(v)
	    Model.equp = {FS.union Model.eq Model.up}
	    %% eqdown(v) = eq(v) union down(v)
	    Model.eqdown = {FS.union Model.eq Model.down}
	 end
      end      
   end
end
