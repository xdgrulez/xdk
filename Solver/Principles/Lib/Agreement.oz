%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
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
      DIDA2LabelLat = G.dIDA2LabelLat
      LabelLat = {DIDA2LabelLat DIDA}
      LAs = LabelLat.constants
   in
      %% check features
      if {Helpers.checkModel 'Agreement.oz' Nodes
	  [DIDA#daughtersL]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in LAs do
		  if {Not {Opti.isIn Node2.index Node1.DIDA.model.daughtersL.LA}=='out'} then
		     LI = {LabelLat.aI2I LA}
		     %%
		     AgreeLM = {ArgRecProc 'Agree' o('^': Node1
						     '_': Node2)}
		     Agr1D = {ArgRecProc 'Agr1' o('^': Node1
						  '_': Node2)}
		     Agr2D = {ArgRecProc 'Agr2' o('^': Node1
						  '_': Node2)}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FS.reified.include LI AgreeLM}
		       {FD.reified.equal Agr1D Agr2D}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
