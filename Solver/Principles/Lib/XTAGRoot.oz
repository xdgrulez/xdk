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
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'XTAGRoot.oz' Nodes
	  [DIDA#mothers]} then
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 LAs = LabelLat.constants
      in
	 if {Not {Member 'S_s' LAs}} then
	    fail 
	 else
	    A2I = LabelLat.aI2I
	    IDSI = {A2I 'S_s'}
	 in
	    for Node in Nodes do
	       {FD.impl
		{FD.nega {FS.reified.include IDSI Node.DIDA.entry.'in'}}
		{FD.reified.equal {FS.card Node.DIDA.model.mothers} 1} 1}
	    end
	 end
      end
   end
end
