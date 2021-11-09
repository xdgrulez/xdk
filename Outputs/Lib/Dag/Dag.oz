%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   
   Helpers(fillRec isSubset appendList) at 'Helpers.ozf'
   
   NewTkDAG(makeToplevel makeToplevelTd) at 'NewTkDAG/NewTkDAG.ozf'
export
   ShowDag
   ShowDags
   CloseDags
prepare
   ListAllInd = List.allInd
   ListZip = List.zip
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ShowDag: DIDA I OutputRec OptRec -> U
   %% Shows a NewTkDAG window for dimension DIDA, solution I,
   %% output record OutputRec and options record OptRec.
   %%
   %% OptRec is an options record as follows:
   %% o(rootLabels: As
   %%   dummyLabels: As
   %%   ghostWords: As
   %%
   %%   showNew: false
   %%   showDom: false
   %%
   %%   edgeFill: V
   %%   newEdgeFill: V
   %%   domFill: V
   %%   newDomFill: V
   %%   edgeLabelFill: V
   %%   domLabelFill: V
   %%   wordFill: V
   %%   projFill: V
   %%   nodeLabelFill: V
   %%   newNodeLabelFill: V
   %%
   %%   ghostEdgeFill: V
   %%   ghostDomFill: V
   %%   ghostEdgeLabelFill: V
   %%   ghostDomLabelFill: V
   %%   ghostWordFill: V
   %%   ghostProjFill: V
   %%   ghostNodeLabelFill: V)
   %%
   %% where "rootLabels", "dummyLabels" and "ghostWords" conspire to
   %% 1) ghost certain nodes, 2) ghost certain edges: *Nodes* are
   %% ghosted if either their word is in ghostWords, or one of their
   %% incoming edge labels is in dummyLabels. *Edges* are ghosted if
   %% their edge labels is either in rootLabels or dummyLabels.
   %%
   %% "showNew" determines whether edges new with respect to the
   %% previously shown analysis should receive a different color or
   %% not, and "showDom" determines whether dominance edges should be
   %% shown or not.
   %%
   %% "edgeFill" determines the color of an edge, "newEdgeFill" of a
   %% new edge, "domFill" of a dominance edge, and "newDomFill" of a
   %% new dominance edge. "edgeLabelFill" determines the color of an
   %% edge label and "domLabelFill" of a dominance edge
   %% label. "wordFill" is the color of the word strings corresponding
   %% to the nodes, "projFill" the color of the projection edges
   %% connecting words and nodes, "nodeLabelFill" the color of a node
   %% label, and "newNodeLabelFill" the color of a new node label.
   %%
   %% "ghostEdgeFill" is the color of a ghosted edge, "ghostDomFill"
   %% of a ghosted dominance edge, "ghostEdgeLabelFill" of a ghosted
   %% edge label, and "ghostDomLabelFill" of a ghosted dominance edge
   %% label.  "ghostWordFill" is the color of a ghosted word,
   %% "ghostProjFill" of a ghosted projection edge, and
   %% "ghostNodeLabelFill" of a ghosted node label.
   %%
   %% the default options record is:
   DefaultOptRec =
   o(rootLabels: nil
     dummyLabels: nil
     ghostWords: nil
     %%
     showNew: false
     showDom: false
     %%
     edgeFill: 'Blue'
     newEdgeFill: 'Red'
     domFill: 'LightBlue'
     newDomFill: 'Pink'
     edgeLabelFill: 'Black'
     domLabelFill: 'Black'
     wordFill: 'Black'
     projFill: 'Orange'
     nodeLabelFill: 'Black'
     newNodeLabelFill: 'Red'
     %%
     ghostEdgeFill: 'Lightgray'
     ghostDomFill: 'Lightgray'
     ghostEdgeLabelFill: 'Lightgray'
     ghostDomLabelFill: 'Lightgray'
     ghostWordFill: 'Lightgray'
     ghostProjFill: 'Lightgray'
     ghostNodeLabelFill: 'Lightgray')
   %%
   proc {ShowDag DIDA I OutputRec OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      _#Nodes#Edges = {GetDag DIDA OutputRec OptRec}
      Win = {NewTkDAG.makeToplevel Nodes Edges
	     'XDK: '#I#' ('#DIDA#')'
	     o(printProc: OutputRec.printProc)}
   in
      {AddWin Win}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ShowDags: DIDAs I OutputRec OptRec -> U
   %% Shows a NewTkDAG window for dimensions DIDAs, solution I, output
   %% record OutputRec, and options record OptRec.
   proc {ShowDags DIDAs I OutputRec OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      Dags = {Map DIDAs
	      fun {$ DIDA} {GetDag DIDA OutputRec OptRec} end}
      Win = {NewTkDAG.makeToplevelTd Dags
	     'XDK: '#I
	     o(printProc: OutputRec.printProc)}
   in
      {AddWin Win}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CloseDags: U -> U
   %% Closes all NewTkDAG windows, and resets NodesDict and EdgesDict.
   proc {CloseDags}
      {CloseWins}
      {Dictionary.removeAll NodesDict}
      {Dictionary.removeAll EdgesDict}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% WinsCe keeps track of opened NewTkDAG windows
   WinsCe = {NewCell nil}
   %% AddWin: Win -> U
   %% Adds a NewTkDAG window.
   proc {AddWin Win}
      Wins = {Access WinsCe}
      Wins1 = {Append Wins [Win]}
   in
      {Assign WinsCe Wins1}
   end
   %% CloseWins: U -> U
   %% Closes all NewTkDAG windows Wins, and resets WinsCe.
   proc {CloseWins}
      Wins = {Access WinsCe}
   in
      for Win in Wins do {Win tkClose} end
      {Assign WinsCe nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% NodesDict saves the nodes of the previously displayed dag (and
   %% is sorted by DIDA)
   NodesDict = {NewDictionary}
   %% NodesDict saves the edges of the previously displayed dag (and
   %% is sorted by DIDA)
   EdgesDict = {NewDictionary}
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetDag: DIDA OutputRec OptRec -> Dag
   %% Gets a dag (i.e. a tuple DIDA#Nodes#Edges) for dimension DIDA,
   %% and output record OutputRec. OptRec is an option record.
   fun {GetDag DIDA OutputRec OptRec}
      NewNodes = {MakeNodes DIDA OutputRec OptRec}
      NewEdges = {MakeEdges DIDA OutputRec OptRec}
      %%
      OldNodes = {CondSelect NodesDict DIDA nil}
      NewNodes1 = if OptRec.showNew andthen
		     {WordsEqual NewNodes OldNodes} then
		     {MarkNewNodes NewNodes OldNodes OptRec}
		  else
		     NewNodes
		  end
      OldEdges = {CondSelect EdgesDict DIDA nil}
      NewEdges1 = if OptRec.showNew andthen
		     {WordsEqual NewNodes OldNodes} then
		     {MarkNewEdges NewEdges OldEdges OptRec}
		  else
		     NewEdges
		  end
      NodesDict.DIDA := NewNodes
      EdgesDict.DIDA := NewEdges
      %%
      Dag = DIDA#NewNodes1#NewEdges1
   in
      Dag
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeNodes: DIDA OutputRec OptRec -> Nodes
   %% Makes a list of NewTkDAG nodes for dimension DIDA, output record
   %% OutputRec, and options record OptRec.
   fun {MakeNodes DIDA OutputRec OptRec}
      NodeOLs = OutputRec.nodeOLs
      Index2Pos = OutputRec.index2Pos
      NodeOLAbbrs = OutputRec.nodeOLAbbrs
      Nodes =
      {Map NodeOLs
       fun {$ NodeOL}
	  %% get node index (= its position)
	  IndexI = NodeOL.index
	  PosI = {Index2Pos IndexI}
	  %% get string
	  StringA1 = NodeOL.word
	  StringA2 = if {Not DIDA==lex} andthen
			{HasFeature NodeOL DIDA} andthen
			{HasFeature NodeOL.DIDA entry} andthen
			{HasFeature NodeOL.DIDA.entry word} then
			NodeOL.DIDA.entry.word
		     else
			''
		     end
	  StringV = StringA1#
	  if StringA2=='' then
	     ''
	  else
	     '\n'#StringA2
	  end
	  %% add d.entry.word if the feature exists
	  %% get node label
	  SelfA = {CondSelect NodeOL.DIDA.model 'self' ''}
	  LabelA = case SelfA
		   of '_'(...) then ''
		   else SelfA
		   end
	  %% get info1,2,3
	  NodeOLAbbr = {Nth NodeOLAbbrs IndexI}
	  Info1X = o(entryIndex: NodeOLAbbr.entryIndex
		     index: NodeOLAbbr.index
		     pos: NodeOLAbbr.pos
		     word: NodeOLAbbr.word
		     DIDA: NodeOLAbbr.DIDA)
	  Info2X = NodeOLAbbr
	  Info3X = NodeOLAbbrs
	  %% get color of word (StringFillA) and projection edge
	  %% (LineFillA) corresponding to the node
	  StringFillA
	  LineFillA
	  LabelFillA
	  LabelLAs = {CondSelect NodeOL.DIDA.model labels nil}
	  if {Member StringA1 OptRec.ghostWords} orelse
	     ({IsList LabelLAs} andthen
	      {Not LabelLAs==nil} andthen
	      {Helpers.isSubset LabelLAs OptRec.dummyLabels}) then
	     StringFillA = OptRec.ghostWordFill
	     LineFillA = OptRec.ghostProjFill
	     LabelFillA = OptRec.ghostNodeLabelFill
	  else
	     StringFillA = OptRec.wordFill
	     LineFillA = OptRec.projFill
	     LabelFillA = OptRec.nodeLabelFill
	  end
	  %% get node
	  Node = o(index: PosI
		   string: o(text: StringV
			     fill: StringFillA)
		   line: o(fill: LineFillA)
		   label: o(text: LabelA
			    fill: LabelFillA)
		   info1: Info1X
		   info2: Info2X
		   info3: Info3X)
       in
	  Node
       end}
   in
      Nodes
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeEdges: DIDA OutputRec OptRec -> Edges
   %% Makes a list of NewTkDAG edges for dimension DIDA, output record
   %% OutputRec, and options record OptRec.
   fun {MakeEdges DIDA OutputRec OptRec}
      EdgesRec = {CondSelect OutputRec edges nil}
      DIDALEdgesRec = {CondSelect EdgesRec ledges nil}
      DIDALUSEdgesRec = {CondSelect EdgesRec lusedges nil}
      DIDALDEdgesRec = {CondSelect EdgesRec ldedges nil}
      DIDALUSDEdgesRec = {CondSelect EdgesRec lusdedges nil}
      LEdges = DIDALEdgesRec.DIDA
      LUSEdges = DIDALUSEdgesRec.DIDA
      LDEdges = DIDALDEdgesRec.DIDA
      LUSDEdges = DIDALUSDEdgesRec.DIDA
      Index2Pos = OutputRec.index2Pos
      %% collect labeled edges
      Edges1 =
      {Map LEdges
       fun {$ edge(IndexI1 IndexI2 LA)}
	  PosI1 = {Index2Pos IndexI1}
	  PosI2 = {Index2Pos IndexI2}
	  EdgeFillA#EdgeLabelFillA =
	  if {Member LA OptRec.rootLabels} orelse
	     {Member LA OptRec.dummyLabels} then
	     OptRec.ghostEdgeFill#OptRec.ghostEdgeLabelFill
	  else
	     OptRec.edgeFill#OptRec.edgeLabelFill
	  end
       in
	  o(index1: PosI1
	    index2: PosI2
	    line: o(fill: EdgeFillA)
	    label: o(text: LA
		     fill: EdgeLabelFillA))
       end}
      %% collect edges whose label is not yet determined
      Edges2 =
      {Map LUSEdges
       fun {$ edge(IndexI1 IndexI2)}
	  PosI1 = {Index2Pos IndexI1}
	  PosI2 = {Index2Pos IndexI2}
       in
	  o(index1: PosI1
	    index2: PosI2
	    label: o(text: '')
	    line: o(fill: OptRec.edgeFill))
       end}
      %% collect dominance edges
      Edges3 =
      if OptRec.showDom then
	 {Map LDEdges
	  fun {$ dom(IndexI1 IndexI2 LA)}
	     PosI1 = {Index2Pos IndexI1}
	     PosI2 = {Index2Pos IndexI2}
	     DomFillA#DomLabelFillA =
	     if {Member LA OptRec.rootLabels} orelse
		{Member LA OptRec.dummyLabels} then
		OptRec.ghostDomFill#OptRec.ghostDomLabelFill
	     else
		OptRec.domFill#OptRec.domLabelFill
	     end
	  in
	     o(index1: PosI1
	       index2: PosI2
	       line: o(fill: DomFillA)
	       label: o(text: LA
			fill: DomLabelFillA))
	  end}
      else
	 nil
      end
      %% collect dominance edges whose label is not yet determined
      Edges4 =
      if OptRec.showDom then
	 {Map LUSDEdges
	  fun {$ dom(IndexI1 IndexI2)}
	     PosI1 = {Index2Pos IndexI1}
	     PosI2 = {Index2Pos IndexI2}
	  in
	     o(index1: PosI1
	       index2: PosI2
	       label: o(text: '')
	       line: o(fill: OptRec.domFill))
	  end}
      else
	 nil
      end
      %%
      Edges5 = {Helpers.appendList [Edges1 Edges2 Edges3 Edges4]}
      Edges = {Sort Edges5
	       fun {$ Edge1 _}
		  Edge1.line.fill==OptRec.ghostEdgeFill orelse
		  Edge1.line.fill==OptRec.ghostDomFill
	       end}
   in
      Edges
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% WordsEqual: Nodes1 Nodes2 -> B
   %% Returns true if Nodes1 and Nodes2 are equal with respect to
   %% their strings (i.e. whether they mirror the same input
   %% sequence), and false otherwise.
   fun {WordsEqual Nodes1 Nodes2}
      {Length Nodes1}=={Length Nodes2} andthen
      {ListAllInd Nodes1
       fun {$ I Node1}
	  A1 = Node1.string.text
	  Node2 = {Nth Nodes2 I}
	  A2 = Node2.string.text
       in
	  A1==A2
       end}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MarkNewNodes: NewNodes OldNodes OptRec -> NewNodes1
   %% Marks new nodes in NewNodes (with respect to OldNodes). OptRec
   %% is an options record. New node labels are colored with
   %% OptRec.newNodeFill.
   fun {MarkNewNodes NewNodes OldNodes OptRec}
      {ListZip NewNodes OldNodes
       fun {$ NewNode OldNode}
	  FillA =
	  if NewNode.label==OldNode.label orelse
	     NewNode.label.fill==OptRec.ghostNodeLabelFill then
	     NewNode.label.fill
	  else
	     OptRec.newNodeLabelFill
	  end
       in
	  o(index: NewNode.index
	    string: NewNode.string
	    line: NewNode.line
	    label: o(text: NewNode.label.text
		     fill: FillA)
	    info1: NewNode.info1
	    info2: NewNode.info2
	    info3: NewNode.info3)
       end}
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MarkNewEdges: NewEdges OldEdges OptRec -> NewEdges1
   %% Marks new edges and dominance edges in NewEdges (with respect to
   %% OldEdges). OptRec is an options record. New edges are colored
   %% with OptRec.newEdgeFill, and new dominance edges with
   %% OptRec.newDomFill.
   fun {MarkNewEdges NewEdges OldEdges OptRec}
      {Map NewEdges
       fun {$ NewEdge}
	  if {Member NewEdge OldEdges} then
	     NewEdge
	  else
	     FillA =
	     if NewEdge.line.fill==OptRec.edgeFill then
		OptRec.newEdgeFill
	     else
		OptRec.newDomFill
	     end
	  in
	     o(index1: NewEdge.index1
	       index2: NewEdge.index2
	       label: NewEdge.label
	       line: o(fill: FillA))
	  end
       end}
   end
end
