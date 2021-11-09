%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(onToplevel showError)
   Property(get)
   
   CPKitHub(option2Kit:MemoOption2CPKit) at 'Principles/Lib/CPKit.hub.ozf'
   PWPrechecked(precheckOn:PWPrecheckOn
		precheckOff:PWPrecheckOff) at 'Principles/Lib/PW.prechecked.ozf'
   Select at 'Principles/Lib/Select.ozf'
   Share(init getAll getProfile profileDone printComment printCommentRec printX) at 'Principles/Lib/Share.ozf'
   
   Space(waitStable)

   Helpers(putLines zip1) at 'Helpers.ozf'
   
%   Principles(post) at 'Principles/Principles.ozf'
export
   Make
   GetProfile
prepare
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
   ListToTuple = List.toTuple
   RecordForAllInd = Record.forAllInd
define
   GetProfile = Share.getProfile
   fun {DummyByNeed F} {F} end
   V2S = VirtualString.toString
   %%
   V2A = VirtualString.toAtom
   %%
   %% Make: As Nodes1 G Options -> Proc
   %% Makes a search script Proc from a list As of words, a partial
   %% solution Nodes1 and a grammar G. Options:
   %%   * debug: a boolean DebugB
   %%   * lazyvars: a boolean LazyvarsB
   %%   * memoize: a boolean MemoizeB
   %%   * mode: an atom ModeA, either parse or generate
   %%   * profile: a boolean ProfileB
   %%   * search: a pair SearchAUrlV of an atom and a virtual
   %%   string. SearchA is either first or all (search for first
   %%   solution or all solutions), print (CSP printing), or flatzinc
   %%   (FlatZinc CSP printing). UrlV is the URL of the file into
   %%   which the CSP printing goes (if SearchA==print or ==flatzinc).
   fun {Make G Options PrinciplesFunctor}
      SearchA#UrlV = Options.search
      ModeA = Options.mode
      fun {BoolOpt Opt} {HasFeature Options Opt} andthen Options.Opt end
      DebugB = {BoolOpt debug}
      %% (dimensions)
      UsedDIDAs = G.usedDIDAs
      DIDA2AttrsLat = G.dIDA2AttrsLat
      DIDA2EntryLat = G.dIDA2EntryLat
      %% (principles)
      UsedPns = G.usedPns
      Pn2ModelLat = G.pn2ModelLat
      Pn2DIDA = G.pn2DIDA
      %% (entries)
      As2AEntriesRec = G.as2AEntriesRec
      %% the rest
      NodeLat = G.nodeLat
      %%
      {Share.init SearchA {BoolOpt profile}}
      CPKit = {MemoOption2CPKit {CondSelect Options memoize none}}
      CPKitSupport = {CPKit.'prepare' G}
   in
      fun {$ As Nodes1Proc}
	 AEntriesRec = {As2AEntriesRec As}
	 NodesI = {Length As}
	 %%
	 V = {FoldL As
	      fun {$ AccV A} AccV#' '#A end ''}
	 S = {V2S V}
	 S1
	 S = & |S1
	 A = {V2A '"'#S1#'"'}
      in
	 proc {$ Nodes}
	    TimeI1 = {Property.get 'time.total'}
	    'export'(fd:FD fs:FS pw:PW) = {CPKit.new CPKitSupport NodesI}
	    PWByNeed
	    if {System.onToplevel} then
	       {System.showError 'printing CSP for input '#A#' into file "'#UrlV#'"'}
	       {Share.printComment 'CSP for input '#A var}
	       {Share.printComment 'begin solver' var}
	       {Share.printComment 'begin solver' constraint}
	       {Share.printComment 'begin solver' branch}
	       {PWPrecheckOff} % : turns off several determinacy checks
	       PWByNeed = DummyByNeed
	    else
	       {PWPrecheckOn}
	       PWByNeed = if Options.lazyvars then ByNeed else DummyByNeed end
	    end
	    NodeSetM = {FS.value.make 1#NodesI}
	    %%
	    !Nodes =
	    {ListMapInd As
	     fun {$ I A}
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% (construct SL node record)
		%% use Node1Lat to create NodeRec (fields: entryIndex,
		%% index, pos, nodeSet, and word)
		NodeRec = {NodeLat.makeVar}
		%% for each used dimension DIDA in UsedDIDAs, create NodeRec1
		%% (fields: attrs, entry, and model)
		NodeTups1 =
		{Map UsedDIDAs
		 fun {$ DIDA}
		    %% use AttrsLat to create AttrsRec
		    AttrsLat = {DIDA2AttrsLat DIDA}
		    AttrsRec = {AttrsLat.makeVar}
		    %% use EntryLat to create EntryRec
		    EntryLat = {DIDA2EntryLat DIDA}
		    EntryRec = {EntryLat.makeVar}
		    %% use ModelLat to create ModelRecs (one for each principle)
		    ModelDict = {NewDictionary}
		    for UsedPn in UsedPns do
		       DIDA1 = {Pn2DIDA UsedPn}
		    in
		       if DIDA1==DIDA then
			  ModelLat = {Pn2ModelLat UsedPn}
			  ModelRec = {ModelLat.makeVar}
		       in
			  {RecordForAllInd ModelRec
			   proc {$ A SL} ModelDict.A := SL end}
		       end
		    end
		    ModelRec = {Dictionary.toRecord o ModelDict}
		    %%
		    Rec = o(attrs: AttrsRec
			    entry: EntryRec
			    model: ModelRec)
		 in
		    DIDA#Rec
		 end}
		NodeRec1 = {ListToRecord o NodeTups1}
		%% adjoin NodeRec and NodeRec1
		NodeRec2 = {Adjoin NodeRec NodeRec1}
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% (instantiate word, nodeSet, index, pos and entryIndex)
		%% instantiate word
		NodeRec2.word = A
		%% instantiate nodeSet
		{FS.equal NodeRec2.nodeSet NodeSetM}
		%% instantiate index
		{FD.equal NodeRec2.index I}
		%% I had to do the following or else memoization
		%% wouldn't be possible (the index feature must be known)
		NodeRec3 = {AdjoinAt NodeRec2 index I}
		%% instantiate pos
		case ModeA
		of parse then
		   NodeRec3.pos = {FS.value.singl NodeRec3.index}
		[] generate then
		   NodeRec3.pos = {FS.subset $ NodeSetM}
		   {FS.cardRange 1 1 NodeRec3.pos}
		end
		%% instantiate entryIndex
		Entries = AEntriesRec.A
		EntriesI = {Length Entries}
		NodeRec3.entryIndex = {FD.int 1#EntriesI}
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% (select lexical entry)
		{RecordForAllInd NodeRec3
		 proc {$ DIDA SL}
		    if {Member DIDA UsedDIDAs} then
		       EntryLat = {DIDA2EntryLat DIDA}
		       DIDAEntries = {Map Entries
				      fun {$ Entry} Entry.DIDA end}
		    in
%		    {Space.waitStable}
		       SL.entry = {EntryLat.select DIDAEntries NodeRec3.entryIndex}
		    end
		 end}
	     in
		NodeRec3
	     end}
	    %%
	    Nodes1 = {Nodes1Proc}
	    if {Not {System.onToplevel}} then
	       for Node1 in Nodes1 do
		  I = Node1.index
		  Node = {Nth Nodes I}
	       in
		  _ =
		  {Helpers.zip1 Node Node1
		   fun {$ SL SL1}
		      SL=SL1 
		      _
		   end}
	       end
	    end
	    %%
	    PosMs = {Map Nodes fun {$ Node} Node.pos end}
	 in
	    {FS.partition PosMs NodeSetM}
	    %%
	    if {System.onToplevel} then
	       {Share.printComment 'end solver' var}
	       {Share.printComment 'end solver' constraint}
	       {Share.printComment 'end solver' branch}
	    end
	    %%
	    {PrinciplesFunctor.post G Nodes FD FS Select PW PWByNeed DebugB}
	    %%
	    if {Not {System.onToplevel}} then {Space.waitStable} end
	    {Share.profileDone}
	    %%
	    if {System.onToplevel} then
	       {Share.printX 'output [""];' output}
	    end
	    %%
	    {FS.distribute naive PosMs}
	    %%
	    if {System.onToplevel} then
	       NodeRec = {ListToTuple o Nodes}
	       {Share.printCommentRec NodeRec}
	       %%
	       Vs = {Share.getAll}
	       {Helpers.putLines Vs UrlV}
	       %%
	       TimeI2 = {Property.get 'time.total'}
	    in
	       {System.showError 'done. ('#TimeI2-TimeI1#'ms)'}
	    end
	 end
      end
   end
end
