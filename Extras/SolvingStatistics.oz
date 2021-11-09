%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Inspector(inspect)
   
   System(showError show)
   
   Space(ask clone commit merge new)

   Property(get)

   Helpers(min1 max1 average vs2S) at 'Helpers.ozf'
export
   Solve
   Perform
prepare
   ListFoldLInd = List.foldLInd
   RecordMap = Record.map
define
   %% Solve: SolverScriptProc SolutionsI FailuresI TimeoutI MaxRecoDistI OpenOutputsProc DebugB -> Rec
   %% Solve using solver script SolverScriptProc to get the solving
   %% statistics record.
   %% SolutionsI is the maximum number of solutions.
   %% FailuresI is the maximum number of failures.
   %% MaxRecoDistI is the maximum recomputation distance.
   %% OpenOutputsProc is the open output procedure called for each
   %% solution.
   %% Prints out debugging information if DebugB==true, and is quiet
   %% otherwise.
   fun {Solve SolverScriptProc SolutionsI FailuresI TimeoutI MaxRecoDistI OpenOutputsProc DebugB}
      fun {Recompute RecoSpc RecoIs}
	 case RecoIs
	 of nil then
	    {Space.clone RecoSpc}
	 [] RecoI|RecoIs1 then
	    RecoSpc1 = {Recompute RecoSpc RecoIs1}
	 in
	    {Space.commit RecoSpc1 RecoI}
	    RecoSpc1
	 end
      end
      %%
      fun {Loop}
	 Rec = o(choices: 0
		 depth: 1
		 failed: 0
		 succeeded: 0)
	 Spc = {Space.new SolverScriptProc}
	 TimeI1 = {Property.get 'time.total'}
	 Rec1 =
	 try
	    {Loop1 Spc Spc nil MaxRecoDistI Rec TimeI1}
	 catch exit(Rec2) then
	    Rec2
	 end
	 TimeI2 = {Property.get 'time.total'}
	 Rec2 = {Adjoin Rec1 o(time: TimeI2-TimeI1)}
      in
	 Rec2
      end
      %%
      fun {Loop1 Spc RecoSpc RecoIs RecoDistI StatRec TimeI1}
	 TimeI2 = {Property.get 'time.total'}
	 if ((TimeI2-TimeI1) div 1000)>=TimeoutI then
	    raise exit(StatRec) end
	 end
	 %%
	 o(choices: ChoicesI
	   depth: DepthI
	   failed: FailedI
	   succeeded: SucceededI) = StatRec
      in
	 case {Space.ask Spc}
	 of failed then
	    FailedI1 = FailedI+1
	    if DebugB then
	       {System.showError 'failure '#FailedI1}
	    end
	    StatRec1 =
	    o(choices: ChoicesI
	      depth: DepthI
	      failed: FailedI1
	      succeeded: SucceededI)
	    if FailedI1>=FailuresI then
	       raise exit(StatRec1) end
	    end
	 in
	    StatRec1
	 [] succeeded then
	    Spc1 = {Space.clone Spc}
	    Solution = {Space.merge Spc1 $}
	    SucceededI1 = SucceededI+1
	    if DebugB then
	       {System.showError 'succeeded '#SucceededI1}
	    end
	    {OpenOutputsProc SucceededI Solution}
	    StatRec1 =
	    o(choices: ChoicesI
	      depth: DepthI
	      failed: FailedI
	      succeeded: SucceededI1)
	    if SucceededI1>=SolutionsI then
	       raise exit(StatRec1) end
	    end
	 in
	    StatRec1
	 [] alternatives(2) then
	    StatRec1 = o(choices: StatRec.choices+1
			 depth: StatRec.depth+1
			 failed: StatRec.failed
			 succeeded: StatRec.succeeded)
	 in
	    if RecoDistI==MaxRecoDistI then
	       Spc1 = {Space.clone Spc}
	       {Space.commit Spc 1}
	       StatRec11 = {Loop1 Spc Spc1 [1] 1 StatRec1 TimeI1}
	       StatRec2 = o(choices: StatRec11.choices
			    depth: StatRec.depth+1
			    failed: StatRec11.failed
			    succeeded: StatRec11.succeeded)
	       {Space.commit Spc1 2}
	       StatRec21 = {Loop1 Spc1 Spc1 nil MaxRecoDistI StatRec2 TimeI1}
	    in
	       o(choices: StatRec21.choices
		 depth: {Max StatRec11.depth StatRec21.depth}
		 failed: StatRec21.failed
		 succeeded: StatRec21.succeeded)
	    else
	       {Space.commit Spc 1}
	       StatRec11 = {Loop1 Spc RecoSpc 1|RecoIs RecoDistI+1 StatRec1 TimeI1}
	       StatRec2 = o(choices: StatRec11.choices
			    depth: StatRec.depth+1
			    failed: StatRec11.failed
			    succeeded: StatRec11.succeeded)
	       Spc1 = {Recompute RecoSpc RecoIs}
	       {Space.commit Spc1 2}
	       StatRec21 = {Loop1 Spc1 RecoSpc 2|RecoIs RecoDistI+1 StatRec2 TimeI1}
	    in
	       o(choices: StatRec21.choices
		 depth: {Max StatRec11.depth StatRec21.depth}
		 failed: StatRec21.failed
		 succeeded: StatRec21.succeeded)
	    end
	 end
      end
   in
      if SolutionsI>0 then
	 if MaxRecoDistI<1 then
	    raise error1('functor':'SolvingStatistics.ozf' 'proc':'Get' msg:'Maximum recomputation distance is less than 1: '#MaxRecoDistI info:o coord:noCoord file:noFile) end
	 end
	 %%
	 StatRec = {Loop}
      in
	 StatRec
      else
	 o(choices: 0
	   depth: 0
	   failed: 0
	   succeeded: 0
	   time: 0)
      end
   end
   %%
   A2S = Atom.toString
   %%
   V2A = VirtualString.toAtom
   %%
   proc {Perform Rec}
      fun {CMin A}
	 CountRecs1 = {Filter CountRecs
		       fun {$ Rec} {HasFeature Rec A} end}
	 Is = {Map CountRecs1
	       fun {$ Rec} Rec.A end}
      in
	 {Helpers.min1 Is}
      end
      fun {CMax A}
	 CountRecs1 = {Filter CountRecs
		       fun {$ Rec} {HasFeature Rec A} end}
	 Is = {Map CountRecs1
	       fun {$ Rec} Rec.A end}
      in
	 {Helpers.max1 Is}
      end
      fun {CAverage A}
	 CountRecs1 = {Filter CountRecs
		       fun {$ Rec} {HasFeature Rec A} end}
	 Is = {Map CountRecs1
	       fun {$ Rec} Rec.A end}
      in
	 {Helpers.average Is}
      end
      %%
      o(examples: ExampleAs
	segment: SegmentProc
	makeSolverScript: MakeSolverScriptProc
	partitionAs: PartitionAs
	print: PrintProc
	getOpenOutputs: GetOpenOutputsProc
	solvingStart: SolvingStartProc
	solvingEnd: SolvingEndProc
	profile: ProfileB
	getProfile: GetProfileProc
	getAs2AEntriesRec: GetAs2AEntriesRecProc
	grammarPath: GrammarPathV
	examplesPath: ExamplesPathV
	date: DateV
	mode: ModeA
	solutions: SolutionsI
	failures: FailuresI
	timeout: TimeoutI
	reco: MaxRecoDistI
	getUsedDIDAs: GetUsedDIDAs
	getUsedPrinciples: GetUsedPrinciples
	searchA: SearchA
	debug: DebugB) = Rec
      %%
      WordAsFileAsTups =
      for ExampleA in ExampleAs collect:Collect do
	 ExampleS = {A2S ExampleA}
      in
	 if ExampleS==nil then skip
	 elseif ExampleS.1==&/ then skip
	 elseif ExampleS.1==&* then skip
	 elseif ExampleS.1==&% then skip
	 else
	    As = {SegmentProc ExampleS}
	    WordAs#FileAs = {PartitionAs As}
	 in
	    {Collect WordAs#FileAs}
	 end
      end
      if WordAsFileAsTups==nil then
	 raise error1('functor':'SolvingStatistics.ozf' 'proc':'Perform' msg:'No examples to parse.' info:o coord:noCoord file:noFile) end
      end
%      {Inspector.inspect WordAsFileAsTups}
      %%
      WordAs#_ = WordAsFileAsTups.1
      %%
      WordAsFileAsTupsI = {Length WordAsFileAsTups}
      %%
      UsedDIDAs = {GetUsedDIDAs WordAs}
      %%
      UsedPrinciples = {GetUsedPrinciples WordAs}
      %%
      {PrintProc
       '<?xml version="1.0" encoding="ISO-8859-1"?>'#'\n'#
       '<!DOCTYPE statistics SYSTEM "Extras/statistics.dtd">'#'\n'#
       '<statistics>'#'\n'#
       '  <grammar data="'#GrammarPathV#'"/>'#'\n'#
       '  <examples data="'#ExamplesPathV#'" count="'#WordAsFileAsTupsI#'"/>'#'\n'#
       '  <mode data="'#ModeA#'"/>'#'\n'#
       '  <date data="'#DateV#'"/>'#'\n'#
       '  <solutions data="'#SolutionsI#'"/>'#'\n'#
       '  <failures data="'#FailuresI#'"/>'#'\n'#
       '  <timeout data="'#TimeoutI#'"/>'#'\n'#
       '  <reco data="'#MaxRecoDistI#'"/>'#'\n'#
       '  <dimensions>'#'\n'#
       {FoldL UsedDIDAs
	fun {$ AccV V}
	   AccV#
	   '    <dimension data="'#V#'"/>'#'\n'
	end ''}#
       '  </dimensions>'#'\n'#
       '  <principles>'#'\n'#
       {FoldL UsedPrinciples
	fun {$ AccV Principle}
	   PIDA = Principle.pIDA
	   DIDA = Principle.dIDA
	   DIDAs = Principle.dIDAs
	   DIDAsS = {Helpers.vs2S DIDAs}
	in
	   AccV#
	   '    <principle data="'#DIDA#' '#PIDA#' ('#DIDAsS#')'#'"/>'#'\n'
	end ''}#
       '  </principles>'#'\n'}
      %%
      CountRecs =
      {ListFoldLInd WordAsFileAsTups
       fun {$ I AccRecs WordAs#FileAs}
	  {PrintProc
	   '  <string id="string'#I#'">'#'\n'#
	   '    <words>'#'\n'#
	   '   '#
	   {FoldL WordAs
	    fun {$ AccV V}
	       AccV#' '#V
	    end ''}#'\n'#
	   '    </words>'#'\n'#
	   if {Not FileAs==nil} then
	      '    <files>'#'\n'#
	      '   '#
	      {FoldL FileAs
	       fun {$ AccV V}
		  AccV#' '#V
	       end ''}#'\n'#
	      '    </files>'#'\n'
	   else
	      ''
	   end#
	   '    <outputs>'#'\n'}
	  %%
	  WordA1|WordAs1 = WordAs
	  WordV = {FoldL WordAs1
		   fun {$ AccV A}
		      AccV#' '#A
		   end WordA1}
	  WordA = {V2A WordV}
	  SolverScriptProc = {MakeSolverScriptProc WordAs FileAs I}
	  %%
	  {SolvingStartProc 'solving '#I#'/'#WordAsFileAsTupsI#' "'#WordA#'"'}
	  StatRec =
	  if SearchA==print orelse SearchA==flatzinc then
	     {SolverScriptProc _}
	     o
	  else
	     OpenOutputsProc = {GetOpenOutputsProc WordAs}
	  in
	     {Solve SolverScriptProc SolutionsI FailuresI TimeoutI MaxRecoDistI OpenOutputsProc DebugB}
	  end
	  {SolvingEndProc done}
	  %%
	  if SearchA==print orelse SearchA==flatzinc then
	     skip
	  else
	     {PrintProc
	      '    </outputs>'#'\n'#
	      '    <choices data="'#StatRec.choices#'"/>'#'\n'#
	      '    <depth data="'#StatRec.depth#'"/>'#'\n'#
	      '    <failed data="'#StatRec.failed#'"/>'#'\n'#
	      '    <succeeded data="'#StatRec.succeeded#'"/>'#'\n'#
	      '    <time data="'#StatRec.time#'"/>'#'\n'
	     }
	  end
	  %%
	  ProfRec =
	  if SearchA==print orelse SearchA==flatzinc orelse
	     StatRec.succeeded==0 then
	     o
	  elseif ProfileB then
	     WordAsI = {Length WordAs}
	     %%
	     As2AEntriesRecProc = {GetAs2AEntriesRecProc WordAs}
	     AEntriesRec = {As2AEntriesRecProc WordAs}
	     AEntriesIRec = {RecordMap AEntriesRec Length}
	     EntriesIs = {Map WordAs
			  fun {$ WordA} AEntriesIRec.WordA end}
	     EntriesF = {Helpers.average EntriesIs}
	     %%
	     Profile = {GetProfileProc}
	     VarfdboolI = Profile.variables.fd.bool
	     VarfdintI = Profile.variables.fd.int
	     VarfdtotalI = Profile.variables.fd.total
	     VarfsI = Profile.variables.fs
	     VartotalI = Profile.variables.total
	     PropcostI = Profile.propagators.cost
	     PropcountI = Profile.propagators.count
	     {PrintProc
	      '    <sprofile varfdbool="'#VarfdboolI#'" varfdint="'#VarfdintI#'" varfdtotal="'#VarfdtotalI#'" varfs="'#VarfsI#'" vartotal="'#VartotalI#'" propcost="'#PropcostI#'" propcount="'#PropcountI#'" words="'#WordAsI#'" entries="'#EntriesF#'">'#'\n'}
	     for WordA in WordAs I in 1..{Length WordAs} do
		{PrintProc
		 '      <spnode index="'#I#'" word="'#WordA#'" entries="'#AEntriesIRec.WordA#'"/>'#'\n'}
	     end
	     {PrintProc
	      '    </sprofile>'#'\n'}
	  in
	     o(varfdbool: VarfdboolI
	       varfdint: VarfdintI
	       varfdtotal: VarfdtotalI
	       varfs: VarfsI
	       vartotal: VartotalI
	       propcost: PropcostI
	       propcount: PropcountI
	       words: WordAsI
	       entries: {Map WordAs
			 fun {$ WordA} AEntriesIRec.WordA end})
	  else
	     o
	  end
	  %%
	  {PrintProc '  </string>'#'\n'}
       in
	  {Adjoin StatRec ProfRec}|AccRecs
       end nil}
   in
      if SearchA==print orelse SearchA==flatzinc then
	 skip
      else
	 {PrintProc '  <counts>'#'\n'}
	 {PrintProc '    <cchoices min="'#{CMin choices}#'" max="'#{CMax choices}#'" average="'#{CAverage choices}#'"/>'#'\n'}
	 {PrintProc '    <cdepth min="'#{CMin depth}#'" max="'#{CMax depth}#'" average="'#{CAverage depth}#'"/>'#'\n'}
	 {PrintProc '    <cfailed min="'#{CMin failed}#'" max="'#{CMax failed}#'" average="'#{CAverage failed}#'"/>'#'\n'}
	 {PrintProc '    <csucceeded min="'#{CMin succeeded}#'" max="'#{CMax succeeded}#'" average="'#{CAverage succeeded}#'"/>'#'\n'}
	 {PrintProc '    <ctime min="'#{CMin time}#'" max="'#{CMax time}#'" average="'#{CAverage time}#'"/>'#'\n'}
	 {PrintProc '  </counts>'#'\n'}
      end
      %%
      if SearchA==print orelse SearchA==flatzinc then
	 skip
      elseif ProfileB then
	 {PrintProc '  <profilecounts>'#'\n'}
	 {PrintProc '    <cvarfdbool min="'#{CMin varfdbool}#'" max="'#{CMax varfdbool}#'" average="'#{CAverage varfdbool}#'"/>'#'\n'}
	 {PrintProc '    <cvarfdint min="'#{CMin varfdint}#'" max="'#{CMax varfdint}#'" average="'#{CAverage varfdint}#'"/>'#'\n'}
	 {PrintProc '    <cvarfdtotal min="'#{CMin varfdtotal}#'" max="'#{CMax varfdtotal}#'" average="'#{CAverage varfdtotal}#'"/>'#'\n'}
	 {PrintProc '    <cvarfs min="'#{CMin varfs}#'" max="'#{CMax varfs}#'" average="'#{CAverage varfs}#'"/>'#'\n'}
	 {PrintProc '    <cvartotal min="'#{CMin vartotal}#'" max="'#{CMax vartotal}#'" average="'#{CAverage vartotal}#'"/>'#'\n'}
	 {PrintProc '    <cpropcost min="'#{CMin propcost}#'" max="'#{CMax propcost}#'" average="'#{CAverage propcost}#'"/>'#'\n'}
	 {PrintProc '    <cpropcount min="'#{CMin propcount}#'" max="'#{CMax propcount}#'" average="'#{CAverage propcount}#'"/>'#'\n'}
	 {PrintProc '    <cwords min="'#{CMin words}#'" max="'#{CMax words}#'" average="'#{CAverage words}#'"/>'#'\n'}
	 local
	    CountRecs1 = {Filter CountRecs
			  fun {$ Rec} {HasFeature Rec entries} end}
	    EntriesIs = {FoldL CountRecs1
			 fun {$ AccIs Rec} {Append AccIs Rec.entries} end nil}
	 in
	    {PrintProc '    <centries min="'#{Helpers.min1 EntriesIs}#'" max="'#{Helpers.max1 EntriesIs}#'" average="'#{Helpers.average EntriesIs}#'"/>'#'\n'}
	 end
	 {PrintProc '  </profilecounts>'#'\n'}
      else
	 skip
      end
      %%
      {PrintProc '</statistics>'#'\n'}
   end
end
