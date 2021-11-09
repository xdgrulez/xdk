%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(showError)

   FD(equi)
   FS(reflect value var reified unionN diff)
export
   Get
prepare
   RecordForAllInd = Record.forAllInd
define
   fun {GetLowerBoundList M}
      Is =
      if {FS.reflect.cardOf.lowerBound M}>999 then
	 {System.showError 'Outputs/Edges.ozf: Cannot reflect lower bound of set containing >999 elements.\n'}
	 nil
      else
	 {FS.reflect.lowerBoundList M}
      end
   in
      Is
   end
   %% GetEdges: Nodes G -> EdgesRec
   %% Using node records Nodes and grammar record G, returns edges
   %% record:
   %% o(edges: DIDAEdgesRec
   %%   ledges: DIDALEdgesRec
   %%   lusedges: DIDALUSEdgesRec
   %%   %%
   %%   dedges: DIDADEdgesRec
   %%   ldedges: DIDALDEdgesRec
   %%   lusdedges: DIDALUSDEdgesRec)
   %%
   %% * DIDAEdgesRec: all determined edges edge(I1 I2) on dimension
   %% DIDA whose edge label is determined or not
   %% * DIDALEdgesRec: all determined labeled edges edge(I1 I2 LA) on
   %% dimension DIDA whose edge label is determined
   %% * DIDALUSEdgesRec: all determined edges edge(I1 I2) on dimension
   %% DIDA whose edge label is not determined
   %%
   %% * DIDADEdgesRec: all determined dominance edges dom(I1 I2) on
   %% dimension DIDA whose edge label is determined or not
   %% * DIDALDEdgesRec: all determined labeled dominance edges dom(I1
   %% I2 LA) on dimension DIDA whose edge label is determined
   %% * DIDALUSDEdgesRec: all determined dominance edges dom(I1 I2)
   %% on dimension DIDA whose edge label is not determined
   fun lazy {Get Nodes G}
      UsedDIDAs = G.usedDIDAs
      %%
      DIDAEdgesDict = {NewDictionary}
      DIDALEdgesDict = {NewDictionary}
      DIDALUSEdgesDict = {NewDictionary}
      %%
      DIDADEdgesDict = {NewDictionary}
      DIDALDEdgesDict = {NewDictionary}
      DIDALUSDEdgesDict = {NewDictionary}
      %%
      for Node in Nodes do
	 {RecordForAllInd Node
	  proc {$ DIDA SL}
	     if {Member DIDA UsedDIDAs} then
		if {Not {HasFeature Node index}} then
		   raise error1('functor':'Outputs/Edges.ozf' 'proc':'Get' msg:'Node has no index feature.' info:o(Node) coord:noCoord file:noFile) end
		end
		I1 = Node.index
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all edges
		M = {CondSelect SL.model daughters FS.value.empty}
		Is = {GetLowerBoundList M}
		Edges = {Map Is
			 fun {$ I2} edge(I1 I2) end}
		Edges1 = {CondSelect DIDAEdgesDict DIDA nil}
		Edges2 = {Append Edges1 Edges}
		DIDAEdgesDict.DIDA := Edges2
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all edges whose edge label is determined
		LAMRec = {CondSelect SL.model daughtersL o}
		{RecordForAllInd LAMRec
		 proc {$ LA M}
		    Is = {GetLowerBoundList M}
		    LEdges = {Map Is
			      fun {$ I2} edge(I1 I2 LA) end}
		    LEdges1 = {CondSelect DIDALEdgesDict DIDA nil}
		    LEdges2 = {Append LEdges1 LEdges}
		 in
		    DIDALEdgesDict.DIDA := LEdges2
		 end}
		if {Not {HasFeature DIDALEdgesDict DIDA}} then
		   DIDALEdgesDict.DIDA := nil
		end
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all edges whose edge label is undetermined
		LEdges = {CondSelect DIDALEdgesDict DIDA nil}
		LEdges1 = {Map LEdges
			   fun {$ edge(I1 I2 _)} edge(I1 I2) end}
		LUSEdges = {Filter Edges2
			    fun {$ Edge} {Not {Member Edge LEdges1}} end}
		DIDALUSEdgesDict.DIDA := LUSEdges
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all dominance edges
		DaughtersM = {CondSelect SL.model daughters FS.value.empty}
		DEdges =
		if {Not {IsDet DaughtersM}} then
		   %% DownIs1 = all nodes below whose mother is undetermined
		   DownM = {CondSelect SL.model down FS.value.empty}
		   DownIs = {GetLowerBoundList DownM}
		   DownIs1 =
		   {Filter DownIs
		    fun {$ I}
		       MothersM = {Nth Nodes I}.DIDA.model.mothers
		    in
		       {Not {IsDet MothersM}}
		    end}
		   %% DownDownIs = all nodes below the nodes in DownIs
		   DownDownMs =
		   {Map DownIs1
		    fun {$ I}
		       Node = {Nth Nodes I}
		    in
		       {CondSelect Node.DIDA.model down FS.value.empty}
		    end}
		   DownDownM = {FS.unionN DownDownMs}
		   DownDownIs = {GetLowerBoundList DownDownM}
		   %% DownIs2 = all nodes in DownIs1 which are not in DownDownIs
		   DownIs2 = {Filter DownIs1
			      fun {$ I} {Not {Member I DownDownIs}} end}
		   DEdges = {Map DownIs2
			     fun {$ I} dom(I1 I) end}
		in
		   DEdges
		else
		   nil
		end
		DEdges1 = {CondSelect DIDADEdgesDict DIDA nil}
		DEdges2 = {Append DEdges1 DEdges}
		DIDADEdgesDict.DIDA := DEdges2
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all dominance edges whose edge label is
		%% determined
		DownLAMRec = {CondSelect SL.model downL o}
		{RecordForAllInd DownLAMRec
		 proc {$ LA M}
		    %% DownLIs = all nodes below an edge labeled LA
		    DownLIs = {GetLowerBoundList M}
		    %% DownIs = all nodes which are endpoints of an
		    %% unlabeled edge in DEdges2
		    DownIs = {Map DEdges2
			      fun {$ dom(_ I)} I end}
		    %% DownLIs1 = all nodes below an edge labeled LA which
		    %% are an endpoint of an unlabeled edge in DEdges2
		    DownLIs1 = {Filter DownLIs
				fun {$ I} {Member I DownIs} end}
		    %%
		    LDEdges = {Map DownLIs1
			       fun {$ I2} dom(I1 I2 LA) end}
		    LDEdges1 = {CondSelect DIDALDEdgesDict DIDA nil}
		    LDEdges2 = {Append LDEdges1 LDEdges}
		 in
		    DIDALDEdgesDict.DIDA := LDEdges2
		 end}
		if {Not {HasFeature DIDALDEdgesDict DIDA}} then
		   DIDALDEdgesDict.DIDA := nil
		end
		%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% collect all dominance edges whose edge label is
		%% undetermined
		LDEdges = {CondSelect DIDALDEdgesDict DIDA nil}
		LDEdges1 = {Map LDEdges
			    fun {$ dom(I1 I2 _)} dom(I1 I2) end}
		LUSDEdges = {Filter DEdges2
			     fun {$ DEdge} {Not {Member DEdge LDEdges1}} end}
	     in
		DIDALUSDEdgesDict.DIDA := LUSDEdges
	     end
	  end}
      end
      DIDAEdgesRec = {Dictionary.toRecord o DIDAEdgesDict}
      DIDALEdgesRec = {Dictionary.toRecord o DIDALEdgesDict}
      DIDALUSEdgesRec = {Dictionary.toRecord o DIDALUSEdgesDict}
      DIDADEdgesRec = {Dictionary.toRecord o DIDADEdgesDict}
      DIDALDEdgesRec = {Dictionary.toRecord o DIDALDEdgesDict}
      DIDALUSDEdgesRec = {Dictionary.toRecord o DIDALUSDEdgesDict}
   in
      o(edges: DIDAEdgesRec
	ledges: DIDALEdgesRec
	lusedges: DIDALUSEdgesRec
	dedges: DIDADEdgesRec
	ldedges: DIDALDEdgesRec
	lusdedges: DIDALUSDEdgesRec)
   end
end
