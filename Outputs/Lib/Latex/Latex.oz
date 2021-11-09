%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
   System(show)
   
   Helpers(checkCycles fillRec isSubset appendList mSpec2Is escape) at 'Helpers.ozf'
export
   PrintDag
   PrintDags
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% PrintDag: DIDA I OutputRec OptRec -> U
   %% Prints the LaTeX code (using xdag.sty) for dimension DIDA,
   %% solution I, output record OutputRec and options record OptRec.
   %%
   %% OptRec is an options record as follows:
   %% o(rootLabels: As
   %%   dummyLabels: As
   %%   ghostWords: As
   %%
   %%   showDom: false)
   %%
   %% where "rootLabels", "dummyLabels" and "ghostWords" conspire to
   %% 1) ghost certain nodes, 2) ghost certain edges: *Nodes* are
   %% ghosted if either their word is in ghostWords, or one of their
   %% incoming edge labels is in dummyLabels. *Edges* are ghosted if
   %% their edge labels is either in rootLabels or dummyLabels.
   %%
   %% "showDom" determines whether dominance edges should be shown or
   %% not.
   %%
   %% the default options record is:
   DefaultOptRec =
   o(rootLabels: nil
     dummyLabels: nil
     ghostWords: nil
     %%
     showDom: false)
   %%
   proc {PrintDag DIDA I OutputRec OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      %%
      DagV = {GetDag DIDA OutputRec OptRec}
      %%
      PrintProc = OutputRec.printProc
   in
      {PrintProc DagV}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% PrintDags: DIDAs I OutputRec OptRec -> U
   %% Prints the LaTeX code (using xdag.sty) for dimensions DIDAs,
   %% solution I, output record OutputRec and options record OptRec.
   proc {PrintDags DIDAs I OutputRec OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      %%
      DagVs = {Map DIDAs
	       fun {$ DIDA} DIDA#'\&\n'#{GetDag DIDA OutputRec OptRec} end}
      DagV =
      '\\begin{center}\n\\begin{tabular}{cc}\n'#
      {FoldL DagVs
       fun {$ AccV DagV} AccV#'\\\\'#DagV end ''}#
      '\\end{tabular}\n\\end{center}\n'
      %%
      PrintProc = OutputRec.printProc
   in
      {PrintProc DagV}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetDag: DIDA OutputRec OptRec -> DagV
   %% Gets the LaTeX code (using xdag.sty) for dimension DIDA,
   %% output record OutputRec and options record OptRec.
   fun {GetDag DIDA OutputRec OptRec}
      NodeOLs = OutputRec.nodeOLs
      %%
      {Helpers.checkCycles DIDA NodeOLs}
      %%
      BeginV = '\\begin{xdag}\n'
      NodesV = {GetNodes DIDA OutputRec OptRec}
      EdgesV = {GetEdges DIDA OutputRec OptRec}
      EndV = '\\end{xdag}\n'
      %%
      DagV = BeginV#NodesV#EdgesV#EndV
   in
      DagV
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetNodes: DIDA OutputRec OptRec -> NodesV
   %% Gets the LaTeX code (using xdag.sty) for the nodes in dimension DIDA,
   %% output record OutputRec, and options record OptRec.
   fun {GetNodes DIDA OutputRec OptRec}
      NodeOLs = OutputRec.nodeOLs
      %% GetDepth: I -> I1
      %% Get depth I1 of the node with index I.
      fun {GetDepth I}
	 NodeOL = {Nth NodeOLs I}
	 Is = {CondSelect NodeOL.DIDA.model up nil}
	 Is1 = case Is
	       of '_'(LBMSpec ...) then
		  Is1 = {Helpers.mSpec2Is LBMSpec}
	       in
		  Is1
	       else
		  Is
	       end
      in
	 {FoldL Is1
	  fun {$ AccI I}
	     {Max 1+{GetDepth I} AccI}
	  end
	  1}
      end
      %%
      Index2Pos = OutputRec.index2Pos
      %%
      NodeVs =
      {Map NodeOLs
       fun {$ NodeOL}
	  %% get node index
	  IndexI = NodeOL.index
	  %% get the position corresponding to the index
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
	  StringA11 = {Helpers.escape StringA1}
	  StringA21 = {Helpers.escape StringA2}
	  StringV = '$\\begin{array}{c}'#PosI#
	  '\\\\\\\\\\textrm{'#StringA11#'}'#
	  if StringA21=='' then
	     ''
	  else
	     '\\\\\\textrm{'#StringA21#'}'
	  end#
	  '\\end{array}$'
	  %% get node label
	  SelfA = {CondSelect NodeOL.DIDA.model 'self' ''}
	  LabelA = case SelfA
		   of '_'(...) then ''
		   else SelfA
		   end
	  LabelA1 = {Helpers.escape LabelA}
	  %% get depth
	  DepthV = {GetDepth IndexI}
	  %% get node
	  LabelLAs = {CondSelect NodeOL.DIDA.model labels nil}
	  CommandA =
	  if {Member StringA1 OptRec.ghostWords} orelse
	     ({IsList LabelLAs} andthen
	      {Not LabelLAs==nil} andthen
	      {Helpers.isSubset LabelLAs OptRec.dummyLabels}) then
	     'ghostnode'
	  else
	     'node'
	  end
       in
	  '\\'#CommandA#'{'#PosI#'}{'#DepthV#'}{'#StringV#'}'#'{'#LabelA1#'}\n'
       end}
      NodesV = {FoldL NodeVs
		fun {$ AccV NodeV} AccV#NodeV end ''}
   in
      NodesV
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetEdges: DIDA OutputRec OptRec -> EdgesV
   %% Gets the LaTeX code (using xdag.sty) for the edges in dimension DIDA,
   %% output record OutputRec, and options record OptRec.
   fun {GetEdges DIDA OutputRec OptRec}
      EdgesRec = OutputRec.edges
      DIDALEdgesRec = EdgesRec.ledges
      DIDALUSEdgesRec = EdgesRec.lusedges
      DIDALDEdgesRec = EdgesRec.ldedges
      DIDALUSDEdgesRec = EdgesRec.lusdedges
      LEdges = DIDALEdgesRec.DIDA
      LUSEdges = DIDALUSEdgesRec.DIDA
      LDEdges = DIDALDEdgesRec.DIDA
      LUSDEdges = DIDALUSDEdgesRec.DIDA
      Index2Pos = OutputRec.index2Pos
      %% collect labeled edges
      EdgeVs1 =
      {Map LEdges
       fun {$ edge(IndexI1 IndexI2 LA)}
	  PosI1 = {Index2Pos IndexI1}
	  PosI2 = {Index2Pos IndexI2}
	  LA1 = {Helpers.escape LA}
	  CommandA =
	  if {Member LA OptRec.rootLabels} orelse
	     {Member LA OptRec.dummyLabels} then
	     'ghostedge'
	  else
	     'edge'
	  end
       in
	  '\\'#CommandA#'{'#PosI1#'}{'#PosI2#'}{'#LA1#'}\n'
       end}
      %% collect edges whose label is not yet determined
      EdgeVs2 =
      {Map LUSEdges
       fun {$ edge(IndexI1 IndexI2)}
	  PosI1 = {Index2Pos IndexI1}
	  PosI2 = {Index2Pos IndexI2}
       in
	  '\\'#'edge'#'{'#PosI1#'}{'#PosI2#'}{}\n'
       end}
      %% collect dominance edges
      EdgeVs3 =
      if OptRec.showDom then
	 {Map LDEdges
	  fun {$ dom(IndexI1 IndexI2 LA)}
	     PosI1 = {Index2Pos IndexI1}
	     PosI2 = {Index2Pos IndexI2}
	     LA1 = {Helpers.escape LA}
	     CommandA =
	     if {Member LA OptRec.rootLabels} orelse
		{Member LA OptRec.dummyLabels} then
		'ghostdom'
	     else
		'dom'
	     end
	  in
	     '\\'#CommandA#'{'#PosI1#'}{'#PosI2#'}{'#LA1#'}\n'
	  end}
      else
	 nil
      end
      %% collect dominance edges whose label is not yet determined
      EdgeVs4 =
      if OptRec.showDom then
	 {Map LUSDEdges
	  fun {$ dom(IndexI1 IndexI2)}
	     PosI1 = {Index2Pos IndexI1}
	     PosI2 = {Index2Pos IndexI2}
	  in
	     '\\'#'dom'#'{'#PosI1#'}{'#PosI2#'}{}\n'
	  end}
      else
	 nil
      end
      %%
      EdgeVs5 = {Helpers.appendList [EdgeVs1 EdgeVs2 EdgeVs3 EdgeVs4]}
      EdgeVs6 = {Sort EdgeVs5
		 fun {$ EdgeV1 _}
		    EdgeV1.2=='ghostedge' orelse
		    EdgeV1.2=='ghostdom'
		 end}
      EdgesV = {FoldL EdgeVs6
		fun {$ AccV EdgeV} AccV#EdgeV end ''}
   in
      EdgesV
   end
end
