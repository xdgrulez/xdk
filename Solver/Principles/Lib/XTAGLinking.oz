%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)

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
      DIDA2LabelLat = G.dIDA2LabelLat
      D2LabelLat = {DIDA2LabelLat D2DIDA}
      D2LAs = D2LabelLat.constants
   in
      if {Helpers.checkModel 'XTAGLinking.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#labels]} then
	 for Node in Nodes do
	    {FS.equal Node.D1DIDA.model.daughters Node.D2DIDA.model.daughters}
	 end
	 %%
	 for Node1 in Nodes I in 1..{Length Nodes} do
	    for Node2 in Nodes do
	       for D2LA in D2LAs do
		  if {Not {Opti.isIn Node2.index Node1.D2DIDA.model.daughtersL.D2LA}=='out'} then
		     %% XTAGLinking
		     %%
		     %% m -l->2 d => -Link(l)->1 d
		     %%     
		     LinkD2LAD1LMRec =
		     {ArgRecProc 'Link' o('^': Node1)}
		     LinkD1LM = LinkD2LAD1LMRec.D2LA
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D2DIDA.model.daughtersL.D2LA}
		      {FD.reified.greater 
		       {FS.card {FS.intersect Node2.D1DIDA.model.labels LinkD1LM}} 0} 1}
		  end
	       end
	    end
	 end
      end
   end
end
