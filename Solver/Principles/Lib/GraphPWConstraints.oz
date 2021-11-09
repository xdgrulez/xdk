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
   ListToRecord = List.toRecord
   RecordForAll = Record.forAll
   RecordForAllInd = Record.forAllInd
define
   proc {Constraint NodeRecs G Principle FD FS Select}
      if {Helpers.checkModel 'GraphPWConstraints.oz' NodeRecs nil} then
	 DIDA = {Principle.dVA2DIDA 'D'}
	 %%
	 NodeSetM = NodeRecs.1.nodeSet
	 %%
	 LabelLat = {G.dIDA2LabelLat DIDA}
	 %%
	 EqupMs = {Map NodeRecs
		   fun {$ NodeRec} NodeRec.DIDA.model.equp end}
	 EqdownMs = {Map NodeRecs
		     fun {$ NodeRec} NodeRec.DIDA.model.eqdown end}
	 LADaughtersLMTups =
	 {Map LabelLat.constants
	  fun {$ LA}
	     DaughtersLMs = {Map NodeRecs
			     fun {$ NodeRec} NodeRec.DIDA.model.daughtersL.LA end}
	     DaughtersLM = {FS.unionN DaughtersLMs}
	  in
	     LA#DaughtersLM
	  end}
	 LADaughtersLMRec = {ListToRecord o LADaughtersLMTups}
	 %%
	 RootsM = {FS.subset $ NodeSetM}
	 for NodeRec in NodeRecs do
	    {FD.equi
	     {FS.reified.include NodeRec.index RootsM}
	     {FS.reified.equal NodeRec.DIDA.model.mothers FS.value.empty} 1}
	 end
      in
	 for NodeRec in NodeRecs do
	    %% initialize sets
	    {FS.subset NodeRec.DIDA.model.mothers NodeSetM}
	    {RecordForAll NodeRec.DIDA.model.mothersL proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.subset NodeRec.DIDA.model.up NodeSetM}
	    {RecordForAll NodeRec.DIDA.model.upL proc {$ M} {FS.subset M NodeSetM} end}
	    %% for PW QuadTransform
	    {RecordForAll NodeRec.DIDA.model.upEndL proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.union NodeRec.DIDA.model.eq NodeRec.DIDA.model.up NodeRec.DIDA.model.equp}
	    %%
	    {FS.equal NodeRec.DIDA.model.eq {FS.value.singl NodeRec.index}}
	    %%
	    {FS.subset NodeRec.DIDA.model.daughters NodeSetM}
	    {RecordForAll NodeRec.DIDA.model.daughtersL proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.subset NodeRec.DIDA.model.down NodeSetM}
	    {RecordForAll NodeRec.DIDA.model.downL proc {$ M} {FS.subset M NodeSetM} end}
	    {FS.union NodeRec.DIDA.model.eq NodeRec.DIDA.model.down NodeRec.DIDA.model.eqdown}
	    %%
	    {FS.unionN NodeRec.DIDA.model.mothersL NodeRec.DIDA.model.mothers}
	    {FS.unionN NodeRec.DIDA.model.upL NodeRec.DIDA.model.up}
	    %% for PW QuadTransform
	    {FS.unionN NodeRec.DIDA.model.upEndL NodeRec.DIDA.model.up}
	    {FS.unionN NodeRec.DIDA.model.daughtersL NodeRec.DIDA.model.daughters}
	    {FS.unionN NodeRec.DIDA.model.downL NodeRec.DIDA.model.down}
	    %% fix for cyclic graphs
	    {FS.union
	     {Select.union
	      EqupMs {FS.diff
		      NodeRec.DIDA.model.mothers
		      NodeRec.DIDA.model.eq}}
	     NodeRec.DIDA.model.mothers
	     NodeRec.DIDA.model.up}
	    {FS.subset NodeRec.DIDA.model.mothers NodeRec.DIDA.model.up}
	    {RecordForAllInd NodeRec.DIDA.model.upL
	     proc {$ LA M}
		{Select.union EqupMs NodeRec.DIDA.model.mothersL.LA M}
		{FS.subset NodeRec.DIDA.model.mothersL.LA M}
	     end}
	    %% fix for cyclic graphs
	    {FS.union
	     {Select.union
	      EqdownMs {FS.diff
			NodeRec.DIDA.model.daughters
			NodeRec.DIDA.model.eq}}
	     NodeRec.DIDA.model.daughters
	     NodeRec.DIDA.model.down}
	    {FS.subset NodeRec.DIDA.model.daughters NodeRec.DIDA.model.down}
	    {RecordForAllInd NodeRec.DIDA.model.downL
	     proc {$ LA M}
		{Select.union EqdownMs NodeRec.DIDA.model.daughtersL.LA M}
		{FS.subset NodeRec.DIDA.model.daughtersL.LA M}
	     end}
	    {RecordForAllInd NodeRec.DIDA.model.downL
	     proc {$ LA M}
		{Select.union EqdownMs NodeRec.DIDA.model.daughtersL.LA M}
		{FS.subset NodeRec.DIDA.model.daughtersL.LA M}
	     end}
	 end
	 %%
	 for NodeRec in NodeRecs do
	    {FD.impl
	     {FD.reified.equal {FS.card NodeRec.DIDA.model.mothers} 1}
	     {FD.reified.equal {FS.card NodeRec.DIDA.model.labels} 1} 1}
	    %%
	    {FD.impl
	     {FD.conj
	      {FD.reified.equal {FS.card RootsM} 1}
	      {FS.reified.include NodeRec.index RootsM}}
	     {FS.reified.equal NodeRec.DIDA.model.eqdown NodeSetM} 1}
	    %%
	    for LA in LabelLat.constants do
	       {FD.equi
		{FS.reified.include {LabelLat.aI2I LA} NodeRec.DIDA.model.labels}
		{FS.reified.include NodeRec.index LADaughtersLMRec.LA} 1}
	    end
	 end
	 %%
	 for NodeRec in NodeRecs do
	    for NodeRec1 in NodeRecs do
	       {FD.equi
		{FS.reified.include NodeRec1.index NodeRec.DIDA.model.down}
		{FS.reified.include NodeRec.index NodeRec1.DIDA.model.up}} = 1
		  
	       {FD.equi
		{FS.reified.include NodeRec1.index NodeRec.DIDA.model.daughters}
		{FS.reified.include NodeRec.index NodeRec1.DIDA.model.mothers}} = 1
	       
	       for LA in LabelLat.constants do
		  {FD.equi
		   {FS.reified.include NodeRec1.index NodeRec.DIDA.model.daughtersL.LA}
		   {FS.reified.include NodeRec.index NodeRec1.DIDA.model.mothersL.LA} 1}
		  %% for PW QuadTransform
		  {FD.equi
		   {FS.reified.include NodeRec1.index NodeRec.DIDA.model.upEndL.LA}
		   {FS.reified.include NodeRec.index NodeRec1.DIDA.model.downL.LA} 1}
	       end
	    end
	 end
      end
   end
end
