%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Tuple1(make) at '../../../Compiler/Lattices/Tuple.ozf'

   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
prepare
   ListForAllInd = List.forAllInd
define
   ProjIs = [1 2 3] % 1:person, 2:gender, 3:number (cf. Diplom.ul)
   %%
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      ID = {DVA2DIDA 'D1'}
      LP = {DVA2DIDA 'D2'}
   in
      %% check features
      if {Helpers.checkModel 'Relative.oz' Nodes
	  [ID#labels
	   ID#mothers
	   LP#eqdown
	   LP#daughtersL]} then
	 %%
	 DIDA2AttrsLat = G.dIDA2AttrsLat
	 DIDA2LabelLat = G.dIDA2LabelLat
	 %%
	 AttrsLat = {DIDA2AttrsLat ID}
	 AttrsALatRec = AttrsLat.record
	 AgrLat = AttrsALatRec.agr
	 AgrCardI = AgrLat.card
	 AgrDomains = AgrLat.domains
	 %%
	 Lats = {Map ProjIs
		 fun {$ ProjI} {Nth AgrDomains ProjI} end}
	 PartialAgrLat = {Tuple1.make Lats}
	 %% create record AgrIPartialAgrIRec mapping integers
	 %% denoting full agreement tuples to integers denoting the
	 %% corresponding partial agreement tuples
	 AgrIPartialAgrIDict = {NewDictionary}
	 for AgrI in 1..AgrCardI do
	    %% decode AgrI
	    AgrAs = {AgrLat.i2AIs AgrI}
	    %% get projections ProjIs
	    PartialAgrAs = {Map ProjIs
			    fun {$ ProjI} {Nth AgrAs ProjI} end}
	    %% encode PartialAgrI
	    PartialAgrI = {PartialAgrLat.aIs2I PartialAgrAs}
	 in
	    AgrIPartialAgrIDict.AgrI := PartialAgrI
	 end
	 AgrIPartialAgrIRec = {Dictionary.toRecord o AgrIPartialAgrIDict}
	 %% create list PartialAgrMs listing the partial agreement values
	 %% of the individual nodes
	 AgrDs = {Map Nodes fun {$ Node} Node.ID.attrs.agr end}
	 PartialAgrMs = {Map AgrDs
			 fun {$ AgrD}
			    PartialAgrD = {Select.fd AgrIPartialAgrIRec AgrD}
			    PartialAgrM = {Select.the $ PartialAgrD}
			 in
			    PartialAgrM
			 end}
	 %%
	 NodesI = {Length Nodes}
	 %%
	 LPEqdownMs = {Map Nodes fun {$ Node} Node.LP.model.eqdown end}
	 %% sets of relative pronouns of the individual nodes (finite
	 %% verbs heading a relative clause have precisely one
	 %% relative pronoun)
	 RProMs = {Map Nodes fun {$ Node} {FS.var.upperBound 1#NodesI} end}
	 %% set of all relative pronouns in the input string
	 RProsM = {FS.var.upperBound 1#NodesI}
	 %% the sets of relative pronouns of the individual nodes
	 %% partition the set of all relative pronouns
	 {FS.partition RProMs RProsM}
	 %%
	 CatLat = AttrsALatRec.cat
	 PrelsI = {CatLat.aI2I prels}
	 %%
	 IDLabelLat = {DIDA2LabelLat ID}
	 RelI = {IDLabelLat.aI2I rel}
      in
	 {ListForAllInd Nodes
	  proc {$ I Node}
	     RProM = {Nth RProMs I}
	     RProCardD = {FS.card RProM}
	     %% a node has cat prels iff it is a relative pronoun (in
	     %% RProsM)
	     {FD.equi
	      {FD.reified.equal Node.ID.attrs.cat PrelsI}
	      {FS.reified.include Node.index RProsM} 1}
	     %% a node has incoming edge label rel iff it has a
	     %% relative pronoun below itself
	     {FD.equi
	      {FS.reified.include RelI Node.ID.model.labels}
	      {FD.reified.equal RProCardD 1} 1}
	     %% the set of nodes equal or below the relative pronoun
	     %% is equal to the set of nodes equal or below the
	     %% rvf-daughter
	     RProLPEqdownM = {Select.union LPEqdownMs RProM}
	     RvfLPEqdownM = {Select.union LPEqdownMs Node.LP.model.daughtersL.rvf}
	     {FS.subset RProLPEqdownM RvfLPEqdownM}
	     %% the relative pronoun of the node agrees partially
	     %% (person, gender, number only, not def, case) with its ID
	     %% mother
	     RProPartialAgrM = {Select.union PartialAgrMs RProM}
	     IDMotherPartialAgrM =
	     {Select.union PartialAgrMs Node.ID.model.mothers}
	  in
	     {FD.impl
	      {FD.reified.equal RProCardD 1}
	      {FS.reified.equal RProPartialAgrM IDMotherPartialAgrM} 1}
	  end}
      end
   end
end
