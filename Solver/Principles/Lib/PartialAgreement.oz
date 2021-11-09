%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)

   FS(reflect)
   
   Tuple1(make) at '../../../Compiler/Lattices/Tuple.ozf'

   Helpers(checkModel) at 'Helpers.ozf'
   Opti(isIn) at 'Opti.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS1 Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      ArgsLat = Principle.argsLat
      %%
      D1DIDA = {DVA2DIDA 'D1'}
      DIDA2LabelLat = G.dIDA2LabelLat
      D1LabelLat = {DIDA2LabelLat D1DIDA}
      D1LAs = D1LabelLat.constants
      %%
      AgrLat = (ArgsLat.record).'Agr1'
      AgrCardI = AgrLat.card
      AgrDomLats = AgrLat.domains
      ProjM = {ArgRecProc 'Projs' o}
      ProjIs = {FS.reflect.lowerBoundList ProjM}
      PartialAgrDomLats = {Map ProjIs
			   fun {$ I} {Nth AgrDomLats I} end}
      PartialAgrLat = {Tuple1.make PartialAgrDomLats}
      %% create record AgrIPartialAgrIRec mapping integers denoting
      %% full agreement tuples to integers denoting the corresponding
      %% partial agreement tuples
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
   in
      if {Helpers.checkModel 'PartialAgreement.oz' Nodes
	  [D1DIDA#daughtersL]} then
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       for LA in D1LAs do
		  if {Not {Opti.isIn Node2.index Node1.D1DIDA.model.daughtersL.LA}=='out'} then
		     LI = {D1LabelLat.aI2I LA}
		     %%
		     AgreeLM = {ArgRecProc 'Agree' o('^': Node1
						     '_': Node2)}
		     Agr1D = {ArgRecProc 'Agr1' o('^': Node1
						  '_': Node2)}
		     Agr2D = {ArgRecProc 'Agr2' o('^': Node1
						  '_': Node2)}
		  in
		     {FD.impl
		      {FS1.reified.include Node2.index Node1.D1DIDA.model.daughtersL.LA}
		      {FD.impl
		       {FS1.reified.include LI AgreeLM}
		       {FD.reified.equal
			{Select.fd AgrIPartialAgrIRec Agr1D}
			{Select.fd AgrIPartialAgrIRec Agr2D}}} 1}
		  end
	       end
	    end
	 end
      end
   end
end
