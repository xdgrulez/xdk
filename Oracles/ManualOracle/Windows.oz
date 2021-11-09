%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Tk(toplevel frame font canvas label button send batch)
   
   NewTkDAG at '../../Outputs/Lib/Dag/NewTkDAG/NewTkDAG.ozf'

   Helpers(appendList maxIs maxSize) at 'Helpers.ozf'
export
   Choose
prepare
   ListForAllInd = List.forAllInd
   ListMapInd = List.mapInd
define
   %% Choose: MSIDA DSIDAs MDags DDagss -> ChosenSIDA
   %% Choose search tree ID ChosenSIDA from the list of search tree
   %% daughter IDs DSIDAs. MSIDA is the search tree mother ID. MDags
   %% is the analyses corresponding to the search tree mother, and
   %% DDagss is the list of analyses corresponding to the search
   %% tree daughters.
   fun {Choose MSIDA DSIDAs MDags DDagss}
      ChosenSIDA
      %% toplevel window
      ToplevelW =
      {New Tk.toplevel
       tkInit(title: 'XDK: Manual Oracle Window'
	      delete:
		 proc {$}
		    ChosenSIDA = DSIDAs.1
		 end)}
      %% search tree frame
      STFrameW = {New Tk.frame tkInit(parent: ToplevelW)}
      STFontW = {New Tk.font tkInit(family: 'helvetica'
				    weight: 'bold'
				    size: 10)}
      STFontWidthI = {STFontW tkReturnInt(measure 'choicepoint' $)}
      STBoxWidthI = STFontWidthI+20
      STCanvasWidthI = {Length DSIDAs}*STBoxWidthI*2
      STCanvasW = {New Tk.canvas tkInit(parent: STFrameW
					width: STCanvasWidthI
					height: 100)}
      MLabelW = {New Tk.label tkInit(parent: STFrameW
				     text: 'choicepoint'
				     background: 'lightskyblue3'
				    )}
      {STCanvasW tk(create window
		    (STCanvasWidthI div 2) 20 window:MLabelW)}
      DButtonWs =
      {ListMapInd DSIDAs
       fun {$ I SIDA}
	  ButtonW =
	  {New Tk.button tkInit(parent: STFrameW
				text: 'choice '#I
				background: 'white'
				action: proc {$}
					   ChosenSIDA = SIDA
					end)}
       in
	  {STCanvasW tk(create window
			(STCanvasWidthI div ({Length DSIDAs}+1))*I 80 window:ButtonW)}
	  {STCanvasW tk(create line
			(STCanvasWidthI div 2) 20 (STCanvasWidthI div ({Length DSIDAs}+1))*I 80)}
	  ButtonW
       end}
      STFrameTkCmds =
      [
       grid(STFrameW row:0 column:0 sticky:nswe)
       grid(STCanvasW row:0 column:0 sticky:nswe)
      ]
      %% dags frame
      MDags1|DDagss1 =
      {Map MDags|DDagss
       fun {$ Dags}
	  {ListMapInd Dags
	   fun {$ DIDI Dag}
	      DIDA#Nodes#Edges = Dag
	      Nodes1 =
	      {Map Nodes
	       fun {$ Node}
		  IndexI = Node.index
		  DepthI = {GetDepth2 MDags|DDagss DIDI IndexI}
		  Node1 = {Adjoin Node o(depth: DepthI)}
	       in
		  Node1
	       end}
	      Dag1 = DIDA#Nodes1#Edges
	   in
	      Dag1
	   end}
       end}
      DDagss2 =
      {ListMapInd DDagss1
       fun {$ I DDags1}
	  DDags2 =
	  {ListMapInd DDags1
	   fun {$ I DIDA#Nodes#Edges}
	      _#_#MEdges = {Nth MDags1 I}
	      Edges1 = {MarkNewEdges Edges MEdges}
	   in
	      DIDA#Nodes#Edges1
	   end}
       in
	  DDags2
       end}
      DagsFrameW = {New Tk.frame tkInit(parent: ToplevelW)}
      {MLabelW
       tkBind(event: '<Button-3>'
	      action:
		 proc {$}
		    MFrameW =
		    {NewTkDAG.makeFrameTd MDags1 DagsFrameW
		     o(gridrow: 1
		       gridcolumn: 0)}
		 in
		    {Tk.send
		     grid(MFrameW row:1 column:0 sticky:nswe)}
		 end)}
      {ListForAllInd DDagss2
       proc {$ I Dags}
	  DButtonW = {Nth DButtonWs I}
       in
	  {DButtonW
	   tkBind(event: '<Button-3>'
		  action:
		     proc {$}
			DFrameW =
			{NewTkDAG.makeFrameTd Dags DagsFrameW
			 o(gridrow: 1
			   gridcolumn: 0)}
		     in
			{Tk.send
			 grid(DFrameW row:1 column:0 sticky:nswe)}
		     end)}
       end}
      MFrameW =
      {NewTkDAG.makeFrameTd MDags1 DagsFrameW
       o(gridrow:1
	 gridcolumn:0)}
      MFrameTkCmds =
      [
       grid(MFrameW row:1 column:0 sticky:nswe)
      ]
      
      DagsFrameTkCmds =
      [
       grid(rowconfigure ToplevelW 1 weight:1)
       grid(columnconfigure ToplevelW 0 weight:1)
       grid(rowconfigure DagsFrameW 1 weight:1)
       grid(columnconfigure DagsFrameW 0 weight:1)
       grid(DagsFrameW row:1 column:0 sticky:nswe)
      ]
      %% append all Tk commands
      TkCmds = {Helpers.appendList
		[
		 STFrameTkCmds
		 MFrameTkCmds
		 DagsFrameTkCmds
		]}
      %% and send them to Tk
      {Tk.batch TkCmds}
      %%
      {Helpers.maxSize ToplevelW}
   in
      {Wait ChosenSIDA}
      {ToplevelW tkClose}
      ChosenSIDA
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MarkNewEdges: Edges1 Edges2 -> Edges
   %% Create edge list Edges based on edge lists Edges1 and Edges2.
   %% Edges is like Edges1 except that edges which are not in Edges2
   %% are emphasized.
   fun {MarkNewEdges Edges1 Edges2}
      {Map Edges1
       fun {$ Edge1}
	  if {Member Edge1 Edges2} then
	     Edge1
	  else
	     o(index1: Edge1.index1
	       index2: Edge1.index2
	       label: o(text: Edge1.label.text)
	       line: o(fill: 'Red'))
	  end
       end}
   end
   %% GetDepth: IndexI Edges -> DepthI
   %% Gets the depth of the node with index IndexI in the dag with
   %% edges Edges. Roots have depth 1.
   fun {GetDepth IndexI Edges}
      %% get list of mothers of IndexI
      MIs = {FoldL Edges
	     fun {$ AccIs Edge}
		Index1I = Edge.index1
		Index2I = Edge.index2
	     in
		if Index2I==IndexI then
		   Index1I|AccIs
		else
		   AccIs
		end
	     end nil}
   in
      if MIs==nil then
	 %% roots have depth 1
	 1
      else
	 %% get the depths of the mothers of IndexI
	 DepthIs = {Map MIs
		    fun {$ MI} {GetDepth MI Edges} end}
	 %% get their maximum depth
	 DepthI = {Helpers.maxIs DepthIs}
      in
	 DepthI+1
      end
   end
   %% GetDepth1: Dagss SIDI DIDI IndexI -> DepthI
   %% Gets the depth of the node in solution SIDI (solution ID
   %% integer), on dimension DIDI (dimension ID integer) and index
   %% IndexI, in the list of analyses Dagss.
   fun {GetDepth1 Dagss SIDI DIDI IndexI}
      Dags = {Nth Dagss SIDI}
      Dag = {Nth Dags DIDI}
      _#_#Edges = Dag
      DepthI = {GetDepth IndexI Edges}
   in
      DepthI
   end
   %% GetDepth2: Dagss DIDI IndexI -> DepthI
   %% Gets the depth of the node on dimension DIDI (dimension ID
   %% integer) and index IndexI, in the list of analyses Dagss. The
   %% depth is the maximum depth of the node across the list of
   %% analyses on dimension DIDI.
   fun {GetDepth2 Dagss DIDI IndexI}
      NSIDI = {Length Dagss}
      DepthIs =
      for SIDI in 1..NSIDI collect:Collect do
	 DepthI = {GetDepth1 Dagss SIDI DIDI IndexI}
      in
	 {Collect DepthI}
      end
      DepthI = {Helpers.maxIs DepthIs}
   in
      DepthI
   end
end
