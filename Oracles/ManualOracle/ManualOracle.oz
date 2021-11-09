%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(exit)
   Inspector(inspect)
   System(showError)
   
   Helpers(serverK parse getAttr allEqual e2V x2A fillRec isSubset) at 'Helpers.ozf'

   Windows(choose) at 'Windows.ozf'
export
   Init
   Exit
prepare
   ListToRecord = List.toRecord
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% default options
   DefaultOptRec =
   o(port: 4711
     %%
     rootLabels: [root conj]
     dummyLabels: [dummy del]
     rootWords: ['.']
     %%
     onlyDiffDims: false)
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% global variables
   %%
   %% STDict: SIDA -> SIDAs
   %% Maps search tree IDs (SIDA) to lists of search tree IDs (SIDAs)
   %% which are their daughters in the search tree.
   STDict = {NewDictionary}
   %% SNodeDict: SIDA -> DIDADagRec
   %% Maps search tree IDs (SIDA) to records DIDADagRec mapping
   %% dimensions to dags, making up the XDG analysis corresponding to
   %% search tree node SIDA.
   SNodeDict = {NewDictionary}
   %% Dictionary holding the global variables
   GlobalDict = {NewDictionary}
   %% server object
   GlobalDict.serverO := unit
   %% options
   GlobalDict.optRec := unit
   %% used dimensions
   GlobalDict.usedDIDAs := nil
   %%
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% exported procedures
   %%
   %% Init: OptRec -> U
   %% Initializes the oracle.
   proc {Init OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      GlobalDict.optRec := OptRec
      {Reset}
      ServerO = {New Helpers.serverK init}
   in
      GlobalDict.serverO := ServerO
      {ServerO bind(takePort:OptRec.port)}
      {ServerO listen}
      thread {ServerO accept} end
      thread {MainLoop} end
   end
   %% Exit: U -> U
   %% Exits the oracle.
   proc {Exit}
      ServerO = GlobalDict.serverO
   in
      {ServerO shutDown(how: [receive send])}
      {ServerO close}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% the server main loop
   %%
   %% MainLoop: U -> U
   proc {MainLoop}
      ServerO = GlobalDict.serverO
      V = {ServerO getS($)}
   in
      if V==false then
	 {Application.exit 0}
      else
	 Elements = {Helpers.parse V}
      in
	 for Element in Elements do
	    try
	       {Inspector.inspect server#read#Element}
	       %%
	       NameA = Element.name
	    in
	       case NameA
	       of init then
		  {Confirm}
	       [] reset then
		  {Reset}
		  {Confirm}
	       [] new then
		  {NewSNode Element}
		  {Confirm}
	       [] chooseLocal then
		  A = {ChooseSNode Element}
	       in
		  {NextSNode A}
	       else
		  raise error1('functor':'Oracles/ManualOracle/ManualOracle.ozf' 'proc':'MainLoop' info:o(Element) msg:'Expected either "init", "reset", "new" or "chooseLocal" elements, got: '#NameA  coord:noCoord file:noFile)
		  end
	       end
	    catch E then
	       V = {Helpers.e2V E true}
	    in
	       {System.showError '\n'#V}
	    end
	 end
	 %%
	 {MainLoop}
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% the oracle reacts to the client messages
   %%
   %% Confirm: U -> U
   %% Confirms client message.
   proc {Confirm}
      ServerO = GlobalDict.serverO
   in
      {ServerO putS('<confirm/>')}
   end
   %% NextSNode: A -> U
   %% Suggests next search node.
   proc {NextSNode A}
      ServerO = GlobalDict.serverO
   in
      {ServerO putS('<next id="'#A#'"/>')}
   end
   %% Reset: U -> U
   %% Clears the search tree.
   proc {Reset}
      {Dictionary.removeAll STDict}
      {Dictionary.removeAll SNodeDict}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% NewSNode: Element -> IDA
   %% Adds a new search node to the search tree.
   A2S = Atom.toString
   S2I = String.toInt
   fun {A2I A} {S2I {A2S A}} end
   %%
   proc {NewSNode Element}
      Attrs = Element.attributes
      Children = Element.children
      SIDA = {Helpers.getAttr Attrs 'id' noAttr}
      MotherSIDA = {Helpers.getAttr Attrs 'parentid' noAttr}
      Descriptions =
      for Child in Children collect:Collect do
	 NameA = Child.name
	 if NameA\='description' then
	    raise error1('functor':'Oracles/ManualOracle/ManualOracle.ozf' 'proc':'NewSNode' info:o(Child) msg:'description element expected, got: '#NameA coord:noCoord file:noFile)
	    end
	 end
      in
	 {Collect Child}
      end
      Description = Descriptions.1
      %% parse graph elements corresponding to the search node
      DIDADagTups =
      {Map Description.children
       fun {$ Child}
	  Dag = {Element2Dag Child}
	  DIDA#_#_ = Dag
       in
	  DIDA#Dag
       end}
      DIDADagRec = {ListToRecord o DIDADagTups}
      %% get list of used dimensions, and save it
      UsedDIDAs = {Map DIDADagTups
		   fun {$ DIDA#_} DIDA end}
      UsedDIDAs1 = {Sort UsedDIDAs Value.'=<'}
      GlobalDict.usedDIDAs := UsedDIDAs1
      %% add the search node and its dags to SNodeDict
      SNodeDict.SIDA := DIDADagRec
      %% get already existing daughters in STDict
      OldDSIDAs = {CondSelect STDict MotherSIDA nil}
      %% if SIDA is not root and is not already contained in
      %% OldDSIDAs, then add [SIDA], else add nil.
      AddDSIDAs =
      if {Not SIDA==MotherSIDA} andthen
	 {Not {Member SIDA OldDSIDAs}} then
	 [SIDA]
      else
	 nil
      end
      NewDSIDAs = {Append OldDSIDAs AddDSIDAs}
   in
      STDict.MotherSIDA := NewDSIDAs
   end
   %%
   fun {GetLabels IndexI Edges}
      LabelAs =
      for Edge in Edges collect:Collect do
	 Index2I = Edge.index2
      in
	 if Index2I==IndexI then
	    LabelA = Edge.label.text
	 in
	    {Collect LabelA}
	 end
      end
   in
      LabelAs
   end
   %% Element2Dag: Element -> Dag
   %% Parses a graph element and return the dag described by it.
   fun {Element2Dag Element}
      NameA = Element.name
      if NameA\='graph' then
	 raise error1('functor':'Oracles/ManualOracle/ManualOracle.ozf' 'proc':'Element2Dag' info:o(Element) msg:'graph element expected, got: '#NameA coord:noCoord file:noFile)
	 end
      end
      %%
      Attrs = Element.attributes
      DIDA = {Helpers.getAttr Attrs 'dimension' noAttr}
      %%
      Children = Element.children
      %%
      Nodes =
      for Child in Children collect:Collect do
	 NameA = Child.name
      in
	 if NameA=='node' then
	    Attrs = Child.attributes
	    %%
	    IndexA = {Helpers.getAttr Attrs 'index' noAttr}
	    IndexI = {A2I IndexA}
	    %%
	    StringA = {Helpers.getAttr Attrs 'word' noAttr}
	    %%
	    LabelA = {Helpers.getAttr Attrs 'label' ''}
	    %%
	    Node = o(index: IndexI
		     string: o(text: StringA)
		     label: o(text: LabelA))
	 in
	    {Collect Node}
	 end
      end
      %%
      Edges =
      for Child in Children collect:Collect do
	 NameA = Child.name
      in
	 if NameA=='edge' then
	    Attrs = Child.attributes
	    %%
	    Index1A = {Helpers.getAttr Attrs 'index1' noAttr}
	    Index1I = {A2I Index1A}
	    %%
	    Index2A = {Helpers.getAttr Attrs 'index2' noAttr}
	    Index2I = {A2I Index2A}
	    %%
	    LabelA = {Helpers.getAttr Attrs 'label' ''}
	    %%
	    Edge = o(index1: Index1I
		     index2: Index2I
		     label: o(text: LabelA))
	 in
	    {Collect Edge}
	 end
      end
      %%
      OptRec = GlobalDict.optRec
      RootLabelAs = OptRec.rootLabels
      DummyLabelAs = OptRec.dummyLabels
      RootWordAs = OptRec.rootWords
      %%
      Nodes1 =
      {Map Nodes
       fun {$ Node}
	  IndexI = Node.index
	  StringA = Node.string.text
	  LabelA = Node.label.text
	  StringFillA
	  LineFillA
	  LabelFillA
	  LabelLAs = {GetLabels IndexI Edges}
	  if {Member StringA RootWordAs} orelse
	     ({IsList LabelLAs} andthen
	      {Not LabelLAs==nil} andthen
	      {Helpers.isSubset LabelLAs DummyLabelAs}) then
	     StringFillA = 'Gray'
	     LineFillA = 'Ivory'
	     LabelFillA= 'Ivory'
	  else
	     StringFillA = 'Black'
	     LineFillA = 'Orange'
	     LabelFillA = 'Black'
	  end
	  Node1 = o(index: IndexI
		    string: o(text: StringA
			      fill: StringFillA)
		    label: o(text: LabelA
			     fill: LabelFillA)
		    line: o(fill: LineFillA))
       in
	  Node1
       end}
      %%
      Edges1 =
      for Edge in Edges collect:Collect do
	 Index1I = Edge.index1
	 Index2I = Edge.index2
	 LabelA = Edge.label.text
      in
	 if {Not {Member LabelA RootLabelAs}} andthen
	    {Not {Member LabelA DummyLabelAs}} then
	    Edge1 = o(index1: Index1I
		      index2: Index2I
		      label: o(text: LabelA))
	 in
	    {Collect Edge1}
	 end
      end
      Dag = DIDA#Nodes1#Edges1
   in
      Dag
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ChooseSNode: Element -> SIDA
   %% Chooses a daughter of the search node described in Element, and
   %% returns its search tree ID.
   fun {ChooseSNode Element}
      Attrs = Element.attributes
      MSIDA = {Helpers.getAttr Attrs 'refid' noAttr}
      %% check whether the search tree ID is already defined?
      if {Not {HasFeature STDict MSIDA}} then
	 DefinedSIDAs = {Dictionary.keys STDict}
	 DefinedSIDAsA = {Helpers.x2A DefinedSIDAs}
      in
	 raise error1('functor':'Oracles/ManualOracle/ManualOracle.ozf' 'proc':'ChooseSNode' info:o(Element SNodeDict STDict) msg:'chooseLocal refid undefined: '#MSIDA#' (defined refids: '#DefinedSIDAsA#')' coord:noCoord file:noFile)
	 end
      end
      %% check whether the search tree node corresponding to MSIDA has
      %% daughters to choose from
      if STDict.MSIDA==nil then
	 raise error1('functor':'Oracles/ManualOracle/ManualOracle.ozf' 'proc':'ChooseSNode' info:o(Element SNodeDict STDict) msg:'chooseLocal refid has no daughters in the search tree (i.e. no choice is possible): '#MSIDA coord:noCoord file:noFile)
	 end
      end	 
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% get DIDADagRec corresponding to the search tree mother
      MDIDADagRec = SNodeDict.MSIDA
      %% get DIDADagRecs corresponding to the search tree daughters
      DSIDAs = STDict.MSIDA
      DDIDADagRecs = {Map DSIDAs
		      fun {$ SIDA} SNodeDict.SIDA end}
      %% get list of dimension IDs
      UsedDIDAs = GlobalDict.usedDIDAs
      DIDAs = {Filter UsedDIDAs
	       fun {$ DIDA}
		  {Not {Member DIDA [lex multi]}}
	       end}
      MDags
      DDagss
      OptRec = GlobalDict.optRec
      if OptRec.onlyDiffDims then
	 %% get list of IDs of the dimensions on which the dags of the
	 %% search tree mother and its daughters differ
	 DiffDIDAs =
	 for DIDA in DIDAs collect:Collect do
	    MDag = MDIDADagRec.DIDA
	    DDags = {Map DDIDADagRecs
		     fun {$ DDIDADagRec} DDIDADagRec.DIDA end}
	 in
	    if {Not {Helpers.allEqual MDag|DDags}} then
	       {Collect DIDA}
	    end
	 end
      in
	 %% get only the different dags corresponding to the search
	 %% tree mother
	 MDags =
	 {Map DiffDIDAs
	  fun {$ DIDA} MDIDADagRec.DIDA end}
	 %% get only the different dags corresponding to the search
	 %% tree mother
	 DDagss =
	 {Map DDIDADagRecs
	  fun {$ DDIDADagRec}
	     DDags =
	     {Map DiffDIDAs
	      fun {$ DIDA} DDIDADagRec.DIDA end}
	  in
	     DDags
	  end}
      else
	 MDags = {Map DIDAs
		  fun {$ DIDA} MDIDADagRec.DIDA end}
	 DDagss = {Map DDIDADagRecs
		   fun {$ DDIDADagRec}
		      {Map DIDAs
		       fun {$ DIDA} DDIDADagRec.DIDA end}
		   end}
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% this variable will contain the chosen search tree ID and is
      %% returned
      ChosenSIDA = {Windows.choose MSIDA DSIDAs MDags DDagss}
   in
      ChosenSIDA
   end
end
