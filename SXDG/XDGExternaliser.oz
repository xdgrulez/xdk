%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:24 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

%% This functor provides an externaliser for arbitrary XDG grammars.
%% Given that a lot of functionality is shared with XDG's output
%% facilities, a more generic solution should be sought for
%% eventually.

functor
import
   XDGEdges at '../Outputs/Edges.ozf'
   XDGIndex2Pos at '../Outputs/Index2Pos.ozf'
   XDGPretty at '../Outputs/Pretty.ozf'
   
   Externaliser at 'Externaliser.ozf'
   Helpers at 'Helpers.ozf'
export
   externaliser: XDGExternaliser
define
   XDG = unit(edges:XDGEdges index2Pos:XDGIndex2Pos pretty:XDGPretty)
   LogPrefix = "XDGExternaliser"
   
   class XDGExternaliser from Externaliser.externaliser
      attr grammar

      %% initialisation
      meth init(Grammar)
	 Externaliser.externaliser,init
	 {self log(LogPrefix "method call: init")}
	 grammar <- Grammar
      end
      
      %% Describe the nodes part of the root variable of an XDG search
      %% problem on all given dimensions.  This returns a record of
      %% descriptions, sorted by dimension.
      meth DescribeNodes(Nodes $)
	 {self log(LogPrefix "method call: DescribeNodes")}

	 OLNodes = {XDG.pretty.pretty Nodes @grammar false}
	 Index2Pos = {XDG.index2Pos.get Nodes @grammar}

	 %% Given a node component (a single dimension of an XDG node,
	 %% represented in terms of XDG's output language), return
	 %% some(L), if L is the (self) label of that node component.
	 %% Otherwise, return none.
	 fun {GetLabel Component}
	    SelfInfo = {Value.condSelect Component.model 'self' unit}
	 in
	    case SelfInfo
	    of unit then none % no label
	    [] '_'(...) then none % undetermined label
	    else some(SelfInfo) end
	 end

	 %% Describe a node represented in terms of XDG's output
	 %% language.  This returns a record with features index and
	 %% word, and an optional feature label.
	 fun {DescribeOLNode OLNode D}
	    Tmp = node(index:{Index2Pos OLNode.index} word:OLNode.word)
	 in
	    case {GetLabel OLNode.D}
	    of some(L) then {Record.adjoinAt Tmp label L}
	    else Tmp end
	 end

	 %% Describe all nodes on a given dimension.  This returns a
	 %% list containing all descriptions for that dimension.
	 fun {DescribeOLNodeDimension OLNodes D}
	    {List.map OLNodes fun {$ N} {DescribeOLNode N D} end}
	 end
      in
	 {List.toRecord unit
	  {List.map @grammar.usedDIDAs
	   fun {$ D} D#{DescribeOLNodeDimension OLNodes D} end}}
      end

      %% Take two node description records and return a record of
      %% descriptions with respect to which the two inputs differ,
      %% sorted by dimension.
      meth DiffNodeDescriptions(Description1 Description2 $)
	 {self log(LogPrefix "method call: DiffNodeDescriptions")}

	 %% Given two node descriptions (where the second description
	 %% is assumed to be at the same dimension of the same node as
	 %% the first one, but in a descendant computation space),
	 %% return true if the second node component has a (self)
	 %% label, and the first node component had none.
	 fun {ReceivedLabelP X Y}
	    {Not {Value.hasFeature X 'label'}} andthen
	    {Value.hasFeature Y 'label'}
	 end

	 %% Collect node descriptions that differ.
	 Collect = {Dictionary.new}
	 Pair = fun {$ X Y} X#Y end
	 for D in @grammar.usedDIDAs do
	    Old = {Dictionary.condGet Collect D nil}
	    NodePairs =
	    {List.zip Description1.D.nodes Description2.D.nodes Pair}
	 in
	    for N1#N2 in NodePairs do
	       if {ReceivedLabelP N1 N2} then
		  {Dictionary.put Collect D N2|Old}
	       end
	    end
	 end
	 if {List.length {Dictionary.keys Collect}} == 0 then
	    {self log(LogPrefix "node diff is empty")}
	 end
      in
	 {Dictionary.toRecord unit Collect}
      end

      %% Describe the edges part of the root variable of an XDG search
      %% problem on all given dimensions.  This returns a record of
      %% descriptions, sorted by dimension.
      meth DescribeEdges(Nodes $)
	 {self log(LogPrefix "method call: DescribeEdges")}
	 
	 EdgeRecord = {XDG.edges.get Nodes @grammar}
	 Index2Pos = {XDG.index2Pos.get Nodes @grammar}
	 
	 %% Describe a determined edge component with determined edge
	 %% label (an element of the list at the feature ledges.D of
	 %% the output of EdgesF.get, for an assumed dimension D).
	 fun {DescribeLabelledEdge Edge}
	    labelledEdge({Index2Pos Edge.1}
			 {Index2Pos Edge.2}
			 Edge.3)
	 end

	 %% Describe a determined edge component whose label is not
	 %% yet determined (an element of the list at the feature
	 %% lusedges.D of the output of EdgesF.get, for an assumed
	 %% dimension D).
	 fun {DescribeUnlabelledEdge Edge}
	    unlabelledEdge({Index2Pos Edge.1}
			   {Index2Pos Edge.2})
	 end
	 
	 fun {DescribeEdgeDimension EdgeRecord D}
	    {List.append
	     {List.map EdgeRecord.ledges.D DescribeLabelledEdge}
	     {List.map EdgeRecord.lusedges.D DescribeUnlabelledEdge}}
	 end
      in
	 {List.toRecord unit
	  {List.map @grammar.usedDIDAs
	   fun {$ D} D#{DescribeEdgeDimension EdgeRecord D} end}}
      end
	 
      %% Take two edge description records and return a record of
      %% descriptions with respect to which the two inputs differ,
      %% sorted by dimension.
      meth DiffEdgeDescriptions(Description1 Description2 $)
	 {self log(LogPrefix "method call: DiffEdgeDescriptions")}
	 
	 Collect = {Dictionary.new}
      in
	 for D in @grammar.usedDIDAs do
	    Tmp = {Helpers.list.diff
		   {List.sort Description1.D.edges Helpers.record.sortP}
		   {List.sort Description2.D.edges Helpers.record.sortP}}
	 in
	    case Tmp
	    of nil then {self log(LogPrefix "edge diff is empty")} skip
	    else {Dictionary.put Collect D Tmp} end
	 end
	 {Dictionary.toRecord unit Collect}
      end
	 
      %% Full description
      meth describe(Nodes $)
	 {self log(LogPrefix "method call: describe")}

	 NodesRecord = XDGExternaliser,DescribeNodes(Nodes $)
	 EdgesRecord = XDGExternaliser,DescribeEdges(Nodes $)
      in
	 {Record.mapInd NodesRecord
	  fun {$ D NodeDescriptions}
	     unit(nodes: NodeDescriptions
		  edges: EdgesRecord.D)
	  end}
      end

      %% Differential description
      meth diff(D1 D2 $)
	 {self log(LogPrefix "method call: diff")}
	 
	 NodesDiff = XDGExternaliser,DiffNodeDescriptions(D1 D2 $)
	 EdgesDiff = XDGExternaliser,DiffEdgeDescriptions(D1 D2 $)
	 Collect = {Dictionary.new}
      in
	 for D in @grammar.usedDIDAs do
	    Nodes = {Value.condSelect NodesDiff D nil}
	    Edges = {Value.condSelect EdgesDiff D nil}
	 in
	    if Nodes == nil andthen Edges == nil then
	       skip
	    else
	       {Dictionary.put Collect D unit(nodes:Nodes edges:Edges)}
	    end
	 end
	 if {List.length {Dictionary.keys Collect}} == 0 then
	    {self log(LogPrefix "diff is empty")}
	 end
	 {Dictionary.toRecord unit Collect}
      end

      %% Externalisation
      meth externalise(Description $)
	 %% Externalise a description of a node component (node).
	 fun {ExternaliseOLNode OLNodeDescription}
	    OLNodeElement = {New Helpers.xml.element init("node")}
	 in
	    {OLNodeElement addAttribute("index" OLNodeDescription.index)}
	    {OLNodeElement addAttribute("word" OLNodeDescription.word)}
	    if {Value.hasFeature OLNodeDescription 'label'} then
	       {OLNodeElement addAttribute("label" OLNodeDescription.label)}
	    end
	    {self log(LogPrefix {OLNodeElement toString($)})}
	    {OLNodeElement toString($)}
	 end
	 
	 %% Externalise a description of a determined edge component
	 %% with determined edge label (labelledEdge).
	 fun {ExternaliseLabelledEdge EdgeDescription}
	    EdgeElement = {New Helpers.xml.element init("edge")}
	 in
	    {EdgeElement addAttribute("index1" EdgeDescription.1)}
	    {EdgeElement addAttribute("index2" EdgeDescription.2)}
	    {EdgeElement addAttribute("label" EdgeDescription.3)}
	    {self log(LogPrefix {EdgeElement toString($)})}
	    {EdgeElement toString($)}
	 end

	 %% Externalise a description of a determined edge component
	 %% whose label is not yet determined (unlabelledEdge).
	 fun {ExternaliseUnlabelledEdge EdgeDescription}
	    EdgeElement = {New Helpers.xml.element init("edge")}
	 in
	    {EdgeElement addAttribute("index1" EdgeDescription.1)}
	    {EdgeElement addAttribute("index2" EdgeDescription.2)}
	    {self log(LogPrefix {EdgeElement toString($)})}
	    {EdgeElement toString($)}
	 end

	 fun {ExternaliseEdge Edge}
	    case Edge
	    of labelledEdge(...) then {ExternaliseLabelledEdge Edge}
	    [] unlabelledEdge(...) then {ExternaliseUnlabelledEdge Edge}
	    end
	 end
      in
	 {self log(LogPrefix "method call: externalise")}
	 {Helpers.string.concat
	  {List.map @grammar.usedDIDAs
	   fun {$ D}
	      if {Value.hasFeature Description D} then
		 GraphElement = {New Helpers.xml.element init("graph")}
		 OLNodes = {List.map Description.D.nodes ExternaliseOLNode}
		 OLNodeString = {Helpers.string.concat OLNodes}
		 Edges = {List.map Description.D.edges ExternaliseEdge}
		 EdgeString = {Helpers.string.concat Edges}
	      in
		 {GraphElement addAttribute("dimension" D)}
		 {GraphElement addChildString(OLNodeString)}
		 {GraphElement addChildString(EdgeString)}
		 {GraphElement toString($)}
	      else
		 ""
	      end
	   end}}
      end
   end
end
