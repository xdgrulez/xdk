%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)

   Helpers(checkModel pair2I) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
prepare
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      D1DIDA = {DVA2DIDA 'D1'}
      D2DIDA = {DVA2DIDA 'D2'}
      DIDA2LabelLat = G.dIDA2LabelLat
      D1LabelLat = {DIDA2LabelLat D1DIDA}
      D2LabelLat = {DIDA2LabelLat D2DIDA}
      D1LAs = D1LabelLat.constants
      D2LAs = D2LabelLat.constants
   in
      if {Helpers.checkModel 'LinkingAboveBelow1or2Start.oz' Nodes
	  [D1DIDA#daughtersL
	   D2DIDA#daughters
	   D2DIDA#daughtersL
	   D2DIDA#equp]} then
	 D2DaughtersMs = {Map Nodes
			  fun {$ Node} Node.D2DIDA.model.daughters end}
	 D2LABelow1or2MRecs =
	 {Map Nodes
	  fun {$ Node}
	     LABelow1or2MTups =
	     {Map D2LAs
	      fun {$ LA}
		 D2DaughtersM = Node.D2DIDA.model.daughtersL.LA
		 D2Below2M = {Select.union D2DaughtersMs D2DaughtersM}
		 D2Below1or2M = {FS.union D2DaughtersM D2Below2M}
	      in
		 LA#D2Below1or2M
	      end}
	  in
	     {ListToRecord o LABelow1or2MTups}
	  end}
      in
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     StartLALMRec =
		     {ArgRecProc 'Start' o('^': Node1)}
		     StartLM = StartLALMRec.LA
		     %%
		     D2Below1or2Ms =
		     {ListMapInd Nodes
		      fun {$ I Node}
			 D2Below1or2Ms =
			 {Map D2LAs
			  fun {$ LA}
			     {Nth D2LABelow1or2MRecs I}.LA
			  end}
		      in
			 {Select.union D2Below1or2Ms StartLM}
		      end}
		     %%
		     D2Below1or2M =
		     {Select.union D2Below1or2Ms Node1.D2DIDA.model.equp}
		  in
		     {FD.impl
		      {FS.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FD.nega {FS.reified.equal StartLM FS.value.empty}}
		       {FS.reified.include Node2.index D2Below1or2M}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
