%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(checkModel reifiedADRecEqual) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      DIDA = {DVA2DIDA 'D'}
      DIDA2LabelLat = G.dIDA2LabelLat
      LabelLat = {DIDA2LabelLat DIDA}
      LAs = LabelLat.constants
   in
      %% check features
      if {Helpers.checkModel 'CoindexEdge.oz' Nodes
	  [DIDA#daughtersL]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in LAs do
		  if {Not {Opti.isIn Node2.index Node1.DIDA.model.daughtersL.LA}=='out'} then
		     
		     {FD.impl
		      {FS.reified.include Node2.index Node1.DIDA.model.daughtersL.LA}
		      {FD.conj
		       {FD.reified.equal Node1.id.attrs.subj.top.number Node2.id.attrs.root.top.number}
		       {FD.conj
			{FD.reified.equal Node1.id.attrs.subj.top.gender Node2.id.attrs.root.top.gender}
			{FD.conj
			 {FD.reified.equal Node1.id.attrs.subj.bot.number Node2.id.attrs.root.bot.number}
			 {FD.conj
			  {FD.reified.equal Node1.id.attrs.subj.bot.gender Node2.id.attrs.root.bot.gender}
			  {FD.conj
			   {FD.reified.equal Node1.id.attrs.pred.top.number Node2.id.attrs.root.top.number}
			   {FD.conj
			    {FD.reified.equal Node1.id.attrs.pred.top.gender Node2.id.attrs.root.top.gender}
			    {FD.conj
			     {FD.reified.equal Node1.id.attrs.pred.bot.number Node2.id.attrs.root.bot.number}
			     {FD.reified.equal Node1.id.attrs.pred.bot.gender Node2.id.attrs.root.bot.gender}}}}}}}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
