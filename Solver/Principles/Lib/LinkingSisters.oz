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
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      D1DIDA = {DVA2DIDA 'D1'}
      D2DIDA = {DVA2DIDA 'D2'}
      D2DIDALabelLat = G.dIDA2LabelLat
      D1LabelLat = {D2DIDALabelLat D1DIDA}
      D1LAs = D1LabelLat.constants
   in
      if {Helpers.checkModel 'LinkingSisters.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#mothers]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     %% Linking Sisters
		     %%
		     %% m -l->1 d =>
		     %%   l in Which(m) => exists m' in V: m' ->2 m and m' ->2 d
		     LI = {D1LabelLat.aI2I LA}
		     WhichM = {ArgRecProc 'Which' o('^': Node1)}
		     D2MothersM = {FS.intersect
				   Node1.D2DIDA.model.mothers
				   Node2.D2DIDA.model.mothers}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FS.reified.include LI WhichM}
		       {FD.reified.greater {FS.card D2MothersM} 0}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
