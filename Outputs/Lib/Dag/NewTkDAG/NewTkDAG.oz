%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   Inspector(inspect)
   Tk(addXScrollbar addYScrollbar batch button canvas frame scrollbar send toplevel)
   
   Helpers(fillRec sum sumI maxIs maxSize)  at 'Helpers.ozf'
   Fonts(getFont measureText) at 'Fonts.ozf'
export
   MakeToplevel
   MakeToplevelLr
   MakeToplevelTd
   MakeFrame
   MakeFrameLr
   MakeFrameTd
prepare
   ListForAllInd = List.forAllInd
   ListMake = List.make
   ListSome = List.some
define   
   %% default options
   DefaultOptRec =
   o(
      node:
	 o(index: 1
	   depth: 0
	   string:
	      o(family: 'helvetica'
		weight: 'bold'
		size: 10
		text: ''
		fill: 'Black')
	   label:
	      o(family: 'helvetica'
		weight: 'bold'
		size: 10
		text: ''
		fill: 'Black')
	   line:
	      o(fill: 'Orange'
		width: 2
		arrow: none)
	   info1: unit
	   info2: unit
	   info3: unit
	   printProc: Inspector.inspect
	  )
      edge:
	 o(
	    index1: 1
	    index2: 1
	    label:
	       o(family: 'helvetica'
		 weight: 'bold'
		 size: 10
		 text: ''
		 fill: 'Black')
	    line:
	       o(fill: 'Blue'
		 width: 2
		 arrow: last))
      scrollbars: true
      gridrow: 0
      gridcolumn: 0
      hstep: 20
      vstep: 10
      minnodewidth: 40
      minnodeheight: 20
      background: 'Ivory'
      %% MakeFrameLr/Td and MakeToplevelLr/Td only
      dim:
	 o(family: 'helvetica'
	   weight: 'bold'
	   size: 10
	   text: ''
	   fill: 'Black')
      %% MakeFrameLr and MakeToplevelLr only
      hdist: 10
      %% MakeFrameTd and MakeToplevelTd only
      vdist: 10
      )
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeFrame: Nodes Edges ParentW OptRec -> FrameW
   %% Creates a frame displaying the dag with nodes Nodes and edges
   %% Edges.  TitleV is the window title, OptRec is an options record.
   %%
   %% Node is a record as follows:
   %% o(index: I
   %%   depth: I
   %%   string: TextRec
   %%   label: TextRec
   %%   line: LineRec
   %%   info1: X
   %%   info2: X
   %%   info3: X
   %%   printProc: PrintProc)
   %% where "index" is the node index, "depth" the depth of the node
   %% in the dag (if set to 0, this is automatically calculated from
   %% nodes Nodes and edges Edges), "string" describes the node
   %% string, "label" describes the node label displayed on the
   %% projection edge, and "line" describes the projection
   %% edge. "info1" is the information printed out when the button
   %% corresponding to a node is clicked with the left, "info2" with
   %% the middle, and "info3" with the right mouse button.
   %% "printProc" is the procedure X -> U used for printing out the
   %% information.
   %%
   %% Edge is a record as follows:
   %% o(index1: I
   %%   index2: I
   %%   label: TextRec
   %%   line: LineRec)
   %% where "index1" is the index of the source node, and "index2" the
   %% index of the destination node. "label" describes the edge label,
   %% and "line" the edge.
   %%
   %% TextRec is a record as follows:
   %% o(family: V
   %%   weight: V
   %%   size: I
   %%   fill: V
   %%   text: V)
   %% where "family" is the font family (e.g. 'helvetica'), "weight"
   %% is the font weight (e.g. 'bold'), "size" the font size
   %% (e.g. 10), "fill" the text color (e.g. 'Black'), and "text" any
   %% virtual string.
   %% 
   %% LineRec is a record as follows:
   %% o(fill: V
   %%   width: I
   %%   arrow: last)
   %% where "fill" is the line color (e.g. 'Blue'), "width" the line
   %% width (e.g. 2), and "arrow" indicates where to draw arrowheads:
   %% none (for no arrowheads), first (for an arrowhead at the first
   %% point of the line), or last (for an arrowhead at the last point
   %% of the line).
   %%
   %% Finally, OptRec is a record as follows:
   %% o(node: Node
   %%   edge: Edge
   %%   scrollbars: B
   %%   gridrow: I
   %%   gridcolumn: I
   %%   hstep: I
   %%   vstep: I
   %%   minnodewidth: I
   %%   minnodeheight: I
   %%   background: V)
   %% where "node" is the default description of a node, "edge" the
   %% default description of an edge, "scrollbars" specifies whether
   %% to add scrollbars or not, "gridrow" is the row of the grid in
   %% which the dag is to be placed, and "gridcolumn" the
   %% column. "hstep" is the horizontal distance between nodes (in
   %% pixels), and "vstep" the vertical distance. "minnodewidth" is
   %% the minimum width of a node box, and "minnodeheight" the minimum
   %% height. "background" is the background color.
   %%
   fun {MakeFrame Nodes1 Edges1 ParentW OptRec1}
      %% fill options record
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      %% fill nodes
      Nodes =
      {Map Nodes1 
       fun {$ Node1} {Helpers.fillRec Node1 OptRec.node} end}
      %% fill edges
      Edges =
      {Map Edges1 
       fun {$ Edge1} {Helpers.fillRec Edge1 OptRec.edge} end}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% get node width
      NodeWidthIs = {GetNodeWidths Nodes OptRec}
      %% get node height
      NodeHeightI = {GetNodeHeight OptRec}
      %% get canvas width
      WidthI = {GetWidth Nodes OptRec}
      %% get canvas height
      HeightI = {GetHeight Nodes Edges OptRec}
      %% get projection edge height
      HeightI1 = HeightI-(4*OptRec.node.string.size)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% create frame
      FrameW = {New Tk.frame tkInit(parent: ParentW)}
      %% create canvas in frame
      CanvasW = {New Tk.canvas tkInit(parent: FrameW
				      background: OptRec.background
				      width: WidthI
				      height: HeightI
				      scrollregion: q(0 0 WidthI HeightI))}
      {Tk.send grid(CanvasW row:OptRec.gridrow column:OptRec.gridcolumn sticky:nswe)}
      if OptRec.scrollbars then
	 %% create horizontal scrollbar in frame
	 LrScrollbarW = {New Tk.scrollbar tkInit(parent: FrameW
						 orient: horizontal)}
	 %% create vertical scrollbar in frame
	 TdScrollbarW = {New Tk.scrollbar tkInit(parent: FrameW
						 orient: vertical)}
      in
	 %% add horizontal scrollbar to canvas
	 {Tk.addXScrollbar CanvasW LrScrollbarW}
	 %% add vertical scrollbar to canvas
	 {Tk.addYScrollbar CanvasW TdScrollbarW}
	 %%
	 {Tk.batch [grid(rowconfigure FrameW OptRec.gridrow weight:1)
		    grid(columnconfigure FrameW OptRec.gridcolumn weight:1)
		    grid(LrScrollbarW row:OptRec.gridrow+1 column:OptRec.gridcolumn sticky:we)
		    grid(TdScrollbarW row:OptRec.gridrow column:OptRec.gridcolumn+1 sticky:ns)]}
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% collect Tk commands to draw nodes
      NodeTkCmds =
      for Node in Nodes collect:Collect do
	 %% create node button
	 ButtonW =
	 {New Tk.button tkInit(parent: CanvasW
			       action: proc {$}
					  {Node.printProc Node.info1}
				       end
			       bitmap: info
			       width: 5
			       height: 5
			       foreground: 'Gray'
			       background: 'Gray'
			       activeforeground: 'Lightgray'
			       activebackground: 'Lightgray')}
	 {ButtonW tkBind(event: '<Button-2>'
			 action: proc {$}
				    {Node.printProc Node.info2}
				 end)}
	 {ButtonW tkBind(event: '<Button-3>'
			 action: proc {$}
				    {Node.printProc Node.info3}
				 end)}
	 
	 XI = {Helpers.sumI NodeWidthIs (Node.index-1)}+
	 ({Nth NodeWidthIs Node.index} div 2)
	 YI = ({GetDepth Node.index Nodes Edges}-1)*NodeHeightI+OptRec.vstep
      in
	 %% create string and index
	 {Collect o(CanvasW o(create text
			      XI
			      HeightI1+(2*Node.string.size)
			      text: Node.index#'\n'#Node.string.text
			      justify: center
			      fill: Node.string.fill
			      font: {Fonts.getFont Node.string}))}
	 %% draw projection edge
	 {Collect o(CanvasW o(create line
			      XI
			      YI
			      XI
			      HeightI1
			      fill: Node.line.fill
			      width: Node.line.width
			      arrow: Node.line.arrow))}
	 %% draw node label
	 {Collect o(CanvasW o(create text
			      XI
			      HeightI1-((HeightI1-(YI+Node.label.size)) div 2)
			      text: Node.label.text
			      fill: Node.label.fill
			      font: {Fonts.getFont Node.label}))}
	 %% draw node button
	 {Collect o(CanvasW o(create window
			      XI
			      YI
			      window: ButtonW))}
% 	 {Collect o(CanvasW o(create oval
% 			      XI YI
% 			      XI+10 YI+10
% 			      fill: Node.line.fill
% 			      width: Node.line.width))
      end     
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% collect Tk commands to draw edges
      KeyALabelTupDict = {NewDictionary}
      fun {MakeLabelTup Edge LabelXI LabelYI}
	 LabelWidthI = {Fonts.measureText Edge.label}
	 LabelXI1 = LabelXI-(LabelWidthI div 2)
	 LabelXI2 = LabelXI+(LabelWidthI div 2)
	 %%
	 LabelHeightI = Edge.label.size
	 LabelYI1 = LabelYI-(LabelHeightI div 2)-2
	 LabelYI2 = LabelYI+(LabelHeightI div 2)+2
	 %%
	 LabelTup = LabelXI#LabelYI#LabelXI1#LabelXI2#LabelYI1#LabelYI2
      in
	 LabelTup
      end
      %%
      fun {Overlap _#_#LabelXI1#LabelXI2#LabelYI1#LabelYI2}
	 LabelTups = {Dictionary.items KeyALabelTupDict}
      in
	 {ListSome LabelTups
	  fun {$ _#_#XI1#XI2#YI1#YI2}
	     (LabelXI1>=XI1 andthen LabelXI1=<XI2 andthen
	      LabelYI1>=YI1 andthen LabelYI1=<YI2) orelse
	     (LabelXI2>=XI1 andthen LabelXI2=<XI2 andthen
	      LabelYI1>=YI1 andthen LabelYI1=<YI2) orelse
	     (LabelXI1>=XI1 andthen LabelXI1=<XI2 andthen
	      LabelYI2>=YI1 andthen LabelYI2=<YI2) orelse
	     (LabelXI2>=XI1 andthen LabelXI2=<XI2 andthen
	      LabelYI2>=YI1 andthen LabelYI2=<YI2)
	  end}
      end
      %%
      EdgeTkCmds =
      for Edge in Edges collect:Collect do
	 XI1 = {Helpers.sumI NodeWidthIs (Edge.index1-1)}+
	 ({Nth NodeWidthIs Edge.index1} div 2)
	 YI1 = ({GetDepth Edge.index1 Nodes Edges}-1)*NodeHeightI+OptRec.vstep
	 XI2 = {Helpers.sumI NodeWidthIs (Edge.index2-1)}+
	 ({Nth NodeWidthIs Edge.index2} div 2)
	 YI2 = ({GetDepth Edge.index2 Nodes Edges}-1)*NodeHeightI+OptRec.vstep
	 %% draw edge
	 {Collect o(CanvasW o(create line
			      XI1 YI1 XI2 YI2
			      fill: Edge.line.fill
			      width: Edge.line.width
			      arrow: Edge.line.arrow
			     ))}
	 %% draw edge label
	 LabelXI1 = (XI1+XI2) div 2
	 LabelYI1 = (YI1+YI2) div 2
	 %%
	 LabelXI2 = (((LabelXI1+XI2) div 2)+XI1) div 2
	 LabelYI2 = (((LabelYI1+YI2) div 2)+YI1) div 2
	 %%
	 %%
	 LabelXI3 = (((LabelXI1+XI1) div 2)+XI2) div 2
	 LabelYI3 = (((LabelYI1+YI1) div 2)+YI2) div 2
	 %%
	 LabelTup1 = {MakeLabelTup Edge LabelXI1 LabelYI1}
	 LabelTup2 = {MakeLabelTup Edge LabelXI2 LabelYI2}
	 LabelTup3 = {MakeLabelTup Edge LabelXI3 LabelYI3}
	 LabelTup4 = {MakeLabelTup Edge LabelXI1+10 LabelYI1}
	 LabelTup5 = {MakeLabelTup Edge LabelXI1-10 LabelYI1}
	 LabelTup6 = {MakeLabelTup Edge LabelXI2+10 LabelYI2}
	 LabelTup7 = {MakeLabelTup Edge LabelXI2-10 LabelYI2}
	 LabelTup8 = {MakeLabelTup Edge LabelXI3+10 LabelYI3}
	 LabelTup9 = {MakeLabelTup Edge LabelXI3-10 LabelYI3}
	 %%
% 	 {Collect o(CanvasW o(create rectangle
% 			      LabelTup1.3 LabelTup1.5 LabelTup1.4 LabelTup1.6
% 			      fill: 'Red'))}
% 	 {Collect o(CanvasW o(create rectangle
% 			      LabelTup2.3 LabelTup2.5 LabelTup2.4 LabelTup2.6
% 			      fill: 'Green'))}
% 	 {Collect o(CanvasW o(create rectangle
% 			      LabelTup3.3 LabelTup3.5 LabelTup3.4 LabelTup3.6
% 			      fill: 'Blue'))}
	 %%
	 LabelTup =
	 if {Not {Overlap LabelTup1}} then LabelTup1
	 elseif {Not {Overlap LabelTup2}} then LabelTup2
	 elseif {Not {Overlap LabelTup3}} then LabelTup3
	 elseif {Not {Overlap LabelTup4}} then LabelTup4
	 elseif {Not {Overlap LabelTup5}} then LabelTup5
	 elseif {Not {Overlap LabelTup6}} then LabelTup6
	 elseif {Not {Overlap LabelTup7}} then LabelTup7
	 elseif {Not {Overlap LabelTup8}} then LabelTup8
	 elseif {Not {Overlap LabelTup9}} then LabelTup9
	 else LabelTup1
	 end
	 KeyA = {VirtualString.toAtom Edge.index1#Edge.index2}
	 KeyALabelTupDict.KeyA := LabelTup
	 LabelXI = LabelTup.1
	 LabelYI = LabelTup.2
      in
	 {Collect o(CanvasW o(create text
			      LabelXI
			      LabelYI
			      text: Edge.label.text
			      fill: Edge.label.fill
			      font: {Fonts.getFont Edge.label}))}
      end
      %%
      EdgeTkCmds1 = {Sort EdgeTkCmds
		     fun {$ TkCmd1 TkCmd2} TkCmd1.2.2=='line' end}
      %%
      TkCmds = {Append NodeTkCmds EdgeTkCmds1}
   in
      {Tk.batch TkCmds}
      %%
      FrameW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeFrameLr: DIDANodesEdgesTups ParentW OptRec -> FrameW
   %% Creates a frame displaying the dags in DIDANodesEdgesTups
   %% left-to-right.
   %% TitleV is the window title, OptRec is an
   %% options record.
   %%
   %% OptRec is extended with the following features:
   %% o(...
   %%   dim: FontRec
   %%   hdist: I
   %%   ...)
   %% where "dim" describes the dimension text above the dags,
   %% and "hdist" is the horizontal distance between the dags.
   %%
   %% Furthermore, the "scrollbars" feature has a different
   %% interpretation, since it talks about the scrollbars around the
   %% compound frame for the dags. The individual dags (drawn using
   %% "MakeFrame") never get scrollbars.
   fun {MakeFrameLr DIDANodesEdgesTups1 ParentW OptRec1}
      %% fill options record
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      %% fill nodes and edges of the dags in DIDANodesEdgesTups1
      DIDANodesEdgesTups =
      {Map DIDANodesEdgesTups1
       fun {$ DIDA#Nodes1#Edges1}
	  Nodes =
	  {Map Nodes1
	   fun {$ Node1} {Helpers.fillRec Node1 OptRec.node} end}
	  Edges =
	  {Map Edges1
	   fun {$ Edge1} {Helpers.fillRec Edge1 OptRec.edge} end}
       in
	  DIDA#Nodes#Edges
       end}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% get widths of the dags
      WidthIs = {Map DIDANodesEdgesTups
		 fun {$ _#Nodes#_} {GetWidth Nodes OptRec} end}
      %% sum the widths up
      WidthI = {Helpers.sum WidthIs}
      %% add horizontal distance between the dags
      WidthI1 = WidthI+({Length DIDANodesEdgesTups}+1)*OptRec.hdist
      %% get heights of the dags
      HeightIs = {Map DIDANodesEdgesTups
		  fun {$ _#Nodes#Edges} {GetHeight Nodes Edges OptRec} end}
      %% get maximum height
      HeightI = {Helpers.maxIs HeightIs}
      %% add space for the dimension texts above the dags
      HeightI1 = HeightI+(2*OptRec.dim.size)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% create frame
      FrameW = {New Tk.frame tkInit(parent:ParentW)}
      %% create canvas in frame
      CanvasW = {New Tk.canvas tkInit(parent:FrameW
				      width:WidthI1
				      height:HeightI1
				      scrollregion:q(0 0 WidthI1 HeightI1))}
      %% no scrollbars for the embedded dag frames
      OptRec2 = {AdjoinAt OptRec scrollbars false}
      %% create embedded dag frames
      DIDAFrameWTups = {Map DIDANodesEdgesTups
			fun {$ DIDA#Nodes#Edges}
			   DIDA#{MakeFrame Nodes Edges CanvasW OptRec2}
			end}
      %% paint the embedded dag frames on the canvas
      {ListForAllInd DIDAFrameWTups
       proc {$ I DIDA#FrameW}
	  %% calculate XI1 = horizontal offset for dag frame
	  XI =
	  if I>1 then
	     WidthIs1 = {ListMake I-1}
	     {ListForAllInd WidthIs1
	      proc {$ I WidthI} WidthI={Nth WidthIs I} end}
	  in
	     {Helpers.sum WidthIs1}
	  else
	     0
	  end
	  XI1 = XI+(I*OptRec.hdist)
	  %% calculate XI2 = horizontal offset for dimension text
	  DIDI = {Fonts.measureText {AdjoinAt OptRec.dim text DIDA}}
	  WidthI = {Nth WidthIs I}
	  XI2 = XI1+(WidthI div 2)-(DIDI div 2)
       in
	  {CanvasW tk(create window XI1 (2*OptRec.dim.size) window:FrameW anchor:nw)}
	  {CanvasW tk(create text XI2 0 text:DIDA fill:OptRec.dim.fill anchor:nw)}
       end}
      %%
      {Tk.send grid(CanvasW row:OptRec.gridrow column:OptRec.gridcolumn sticky:nswe)}
      if OptRec.scrollbars then
	 LrScrollbarW = {New Tk.scrollbar tkInit(parent:FrameW
						 orient:horizontal)}
	 TdScrollbarW = {New Tk.scrollbar tkInit(parent:FrameW
						 orient:vertical)}
      in
	 {Tk.addXScrollbar CanvasW LrScrollbarW}
	 {Tk.addYScrollbar CanvasW TdScrollbarW}
	 {Tk.batch [grid(rowconfigure FrameW OptRec.gridrow weight:1)
		    grid(columnconfigure FrameW OptRec.gridcolumn weight:1)
		    grid(LrScrollbarW row:OptRec.gridrow+1 column:OptRec.gridcolumn sticky:we)
		    grid(TdScrollbarW row:OptRec.gridrow column:OptRec.gridcolumn+1 sticky:ns)]}
      end
   in
      FrameW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeFrameTd: DIDANodesEdgesTups ParentW OptRec -> FrameW
   %% Creates a frame displaying the dags in DIDANodesEdgesTups
   %% top-down.  TitleV is the window title, OptRec is an options
   %% record.
   %%
   %% OptRec is extended with the following features:
   %% o(...
   %%   dim: FontRec
   %%   vdist: I
   %%   ...)
   %% where "dim" describes the dimension text to the left of the
   %% dags, and "vdist" is the vertical distance between the dags.
   %%
   %% Furthermore, the "scrollbars" feature has a different
   %% interpretation, since it talks about the scrollbars around the
   %% compound frame for the dags. The individual dags (drawn using
   %% "MakeFrame") never get scrollbars.
   fun {MakeFrameTd DIDANodesEdgesTups1 ParentW OptRec1}
      %% fill options record
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      %% fill nodes and edges of the dags in DIDANodesEdgesTups1
      DIDANodesEdgesTups =
      {Map DIDANodesEdgesTups1
       fun {$ DIDA#Nodes1#Edges1}
	  Nodes =
	  {Map Nodes1
	   fun {$ Node1} {Helpers.fillRec Node1 OptRec.node} end}
	  Edges =
	  {Map Edges1
	   fun {$ Edge1} {Helpers.fillRec Edge1 OptRec.edge} end}
       in
	  DIDA#Nodes#Edges
       end}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% get widths of the dags
      WidthIs = {Map DIDANodesEdgesTups
		 fun {$ _#Nodes#_} {GetWidth Nodes OptRec} end}
      %% get maximum width of the dags
      WidthI = {Helpers.maxIs WidthIs}
      %% get widths of the dimension texts
      TextWidthIs =
      {Map DIDANodesEdgesTups
       fun {$ DIDA#_#_}
	  2*{Fonts.measureText {AdjoinAt OptRec.dim text DIDA}}
       end}
      %% get maximum width of the dimension texts
      TextWidthI = {Helpers.maxIs TextWidthIs}
      %%
      WidthI1 = WidthI+TextWidthI
      %% get heights of the dags
      HeightIs = {Map DIDANodesEdgesTups
		  fun {$ _#Nodes#Edges} {GetHeight Nodes Edges OptRec} end}
      %% sum up the heights
      HeightI = {Helpers.sum HeightIs}
      %% add vertical distance between the dags
      HeightI1 = HeightI+({Length DIDANodesEdgesTups}+1)*OptRec.vdist
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% create frame
      FrameW = {New Tk.frame tkInit(parent:ParentW)}
      %% create canvas in frame
      CanvasW = {New Tk.canvas tkInit(parent:FrameW
				      width:WidthI1
				      height:HeightI1
				      scrollregion:q(0 0 WidthI1 HeightI1))}
      %% no scrollbars for the embedded dag frames
      OptRec2 = {AdjoinAt OptRec scrollbars false}
      %% create embedded dag frames
      DIDAFrameWTups = {Map DIDANodesEdgesTups
			fun {$ DIDA#Nodes#Edges}
			   DIDA#{MakeFrame Nodes Edges CanvasW OptRec2}
			end}
      %% paint the embedded dag frames on the canvas
      {ListForAllInd DIDAFrameWTups
       proc {$ I DIDA#FrameW}
	  %% calculate XI1 = horizontal offset for the dag frame
	  XI1 = TextWidthI+((WidthI-{Nth WidthIs I}) div 2)
	  %% calculate YI1 = vertical offset for dag frame
	  YI =
	  if I>1 then
	     HeightIs1 = {ListMake I-1}
	     {ListForAllInd HeightIs1
	      proc {$ I HeightI} HeightI={Nth HeightIs I} end}
	  in
	     {Helpers.sum HeightIs1}
	  else
	     0
	  end
	  YI1 = YI+(I*OptRec.vdist)
	  %% calculate YI2 = vertical offset for dimension text
	  HeightI = {Nth HeightIs I}
	  YI2 = YI1+(HeightI div 2)
       in
	  {CanvasW tk(create window XI1 YI1 window:FrameW anchor:nw)}
	  {CanvasW tk(create text (TextWidthI div 2) YI2 text:DIDA fill:OptRec.dim.fill)}
       end}
      %%
      {Tk.send grid(CanvasW row:OptRec.gridrow column:OptRec.gridcolumn sticky:nswe)}
      if OptRec.scrollbars then
	 LrScrollbarW = {New Tk.scrollbar tkInit(parent:FrameW
						 orient:horizontal)}
	 TdScrollbarW = {New Tk.scrollbar tkInit(parent:FrameW
						 orient:vertical)}
      in
	 {Tk.addXScrollbar CanvasW LrScrollbarW}
	 {Tk.addYScrollbar CanvasW TdScrollbarW}
	 {Tk.batch [grid(rowconfigure FrameW OptRec.gridrow weight:1)
		    grid(columnconfigure FrameW OptRec.gridcolumn weight:1)
		    grid(LrScrollbarW row:OptRec.gridrow+1 column:OptRec.gridcolumn sticky:we)
		    grid(TdScrollbarW row:OptRec.gridrow column:OptRec.gridcolumn+1 sticky:ns)]}
      end
   in
      FrameW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeToplevel: Nodes Edges TitleV OptRec -> ToplevelW
   %% Creates a window displaying the dag with nodes Nodes and edges
   %% Edges. TitleV is the window title, OptRec is an options record.
   fun {MakeToplevel Nodes Edges TitleV OptRec}
      ToplevelW = {New Tk.toplevel tkInit(title: TitleV)}
      FrameW = {MakeFrame Nodes Edges ToplevelW OptRec}
   in
      {Tk.batch [grid(rowconfigure ToplevelW 0 weight:1)
		 grid(columnconfigure ToplevelW 0 weight:1)
		 grid(FrameW row:0 column:0 sticky:nswe)
		]}
      {Helpers.maxSize ToplevelW}
      ToplevelW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeToplevelLr: DIDANodesEdgesTups TitleV OptRec -> ToplevelW
   %% Creates a window displaying the dags in DIDANodesEdgesTups
   %% left-to-right.  TitleV is the window title, OptRec is an options
   %% record.
   %%
   %% OptRec is extended as described for MakeFrameLr.
   fun {MakeToplevelLr NodesEdgesTups TitleV OptRec}
      ToplevelW = {New Tk.toplevel tkInit(title: TitleV)}
      FrameW = {MakeFrameLr NodesEdgesTups ToplevelW OptRec}
   in
      {Tk.batch [
		 grid(rowconfigure ToplevelW 0 weight:1)
		 grid(columnconfigure ToplevelW 0 weight:1)
		 grid(FrameW row:0 column:0 sticky:nswe)
		]}
      {Helpers.maxSize ToplevelW}
      ToplevelW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeToplevelTd: DIDANodesEdgesTups TitleV OptRec -> ToplevelW
   %% Creates a window displaying the dags in DIDANodesEdgesTups
   %% top-down.  TitleV is the window title, OptRec is an options
   %% record.
   %%
   %% OptRec is extended as described for MakeFrameTd.
   fun {MakeToplevelTd NodesEdgesTups TitleV OptRec}
      ToplevelW = {New Tk.toplevel tkInit(title: TitleV)}
      FrameW = {MakeFrameTd NodesEdgesTups ToplevelW OptRec}
   in
      {Tk.batch [
		 grid(rowconfigure ToplevelW 0 weight:1)
		 grid(columnconfigure ToplevelW 0 weight:1)
		 grid(FrameW row:0 column:0 sticky:nswe)
		]}
      {Helpers.maxSize ToplevelW}
      ToplevelW
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetNodeWidths: Nodes OptRec -> Is
   %% Gets the width of the node boxes in the dag with nodes Nodes.
   fun {GetNodeWidths Nodes OptRec}
      %% get node widths
      NodeWidthIs =
      {Map Nodes
       fun {$ Node}
	  StringTextOptRec = {Helpers.fillRec Node.string OptRec.node.string}
	  NodeTextOptRec = {Helpers.fillRec Node.label OptRec.node.label}
	  StringWidthI = {Fonts.measureText StringTextOptRec}
	  NodeLabelWidthI = {Fonts.measureText NodeTextOptRec}
       in
	  {Helpers.maxIs [StringWidthI NodeLabelWidthI
			  OptRec.minnodewidth]}+OptRec.hstep
       end}
   in
      NodeWidthIs
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetWidth: Nodes OptRec -> I
   %% Gets the width of the dag with nodes Nodes.
   fun {GetWidth Nodes OptRec}
      %% get node widths
      NodeWidthIs = {GetNodeWidths Nodes OptRec}
      %% get canvas width
      WidthI = {Helpers.sum NodeWidthIs}
   in
      WidthI
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetDepth: I Nodes Edges -> I
   %% Gets the depth of the node with index I in the dag described by
   %% nodes Nodes and edges Edges. Roots have depth 1.
   fun {GetDepth I Nodes Edges}
      fun {GetDepth1 I Nodes Edges Is}
	 Node = {Nth Nodes I}
      in
	 if Node.depth==0 then
	    %% get list of mothers of I
	    MotherIs = {FoldL Edges
			fun {$ AccIs Edge}
			   I1 = Edge.index1
			   I2 = Edge.index2
			in
			   if I2==I andthen {Not {Member I1 Is}} then
			      I1|AccIs
			   else
			      AccIs
			   end
			end nil}
	 in
	    if MotherIs==nil then
	       1
	    else
	       %% get depths of the mothers
	       DepthIs =
	       {Map MotherIs
		fun {$ MotherI}
		   {GetDepth1 MotherI Nodes Edges MotherI|Is}
		end}
	       %% get maximum depth of the mothers
	       DepthI = {Helpers.maxIs DepthIs}
	    in
	       DepthI+1
	    end
	 else
	    Node.depth
	 end
      end
   in
      {GetDepth1 I Nodes Edges nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetNodeHeight: OptRec -> I
   %% Gets the height of a node box.
   fun {GetNodeHeight OptRec}
      {Max
       (2*{Max OptRec.node.label.size OptRec.edge.label.size})+OptRec.vstep
       OptRec.minnodeheight}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetHeight: Nodes Edges OptRec -> I
   %% Gets the height of the dag with nodes Nodes and edges Edges.
   fun {GetHeight Nodes Edges OptRec}
      %% get maximum node depth (number of nodes above the node + 1)
      MaxDepthI = {FoldL Nodes
		   fun {$ AccI Node}
		      I = Node.index
		   in
		      {Max {GetDepth I Nodes Edges} AccI}
		   end 1}
      %% get node height
      NodeHeightI = {GetNodeHeight OptRec}
      %% get canvas height (without the string)
      HeightI = MaxDepthI*NodeHeightI
      %% get canvas height (with the string)
      HeightI1 = HeightI+(4*OptRec.node.string.size)
   in
      HeightI1
   end
end
