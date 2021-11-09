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
export
   Open
   Close
define
   %% Open: DIDA I OutputRec -> U
   %% Prints XML output for dimension DIDA, solution I, and output
   %% record OutputRec.
   proc {Open DIDA I OutputRec}
      BeginV =
      '<graph dimension="'#DIDA#'">\n'
      NodesV = {MakeNodes DIDA OutputRec}
      EdgesV = {MakeEdges DIDA OutputRec}
      EndV = '</graph>\n'
      AllV = BeginV#NodesV#EdgesV#EndV
      PrintProc = OutputRec.printProc
   in
      {PrintProc AllV}
   end
   %% Close: DIDA -> U
   %% Does nothing.
   proc {Close _}
      skip
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeNodes: DIDA OutputRec -> NodesV
   %% Makes a virtual string of XML output nodes for dimension DIDA
   %% and output record OutputRec.
   fun {MakeNodes DIDA OutputRec}
      NodeOLs = OutputRec.nodeOLs
      Index2Pos = OutputRec.index2Pos
      NodeVs = {Map NodeOLs
		fun {$ NodeOL}
		   IndexI = NodeOL.index
		   PosI = {Index2Pos IndexI}
		   %%
		   A = NodeOL.word
		   %%
		   SelfA = {CondSelect NodeOL.DIDA.model 'self' ''}
		   LabelA = case SelfA
			    of '_'(...) then ''
			    else SelfA
			    end
		   LabelA1 = case LabelA
			     of '' then ''
			     else ' label="'#LabelA#'"'
			     end
		in
		   '<node'#
		   ' index="'#PosI#'"'#
		   ' word="'#A#'"'#
		   LabelA1#
		   '/>\n'
		end}
      NodesV = {FoldL NodeVs
		fun {$ AccV NodeV} AccV#NodeV end ''}
   in
      NodesV
   end
   %% MakeEdges: DIDA OutputRec -> EdgesV
   %% Makes a virtual string of XML output edges for dimension DIDA
   %% and output record OutputRec.
   fun {MakeEdges DIDA OutputRec}
      EdgesRec = OutputRec.edges
      DIDALEdgesRec = EdgesRec.ledges
      DIDALUSEdgesRec = EdgesRec.lusedges
      LEdges = DIDALEdgesRec.DIDA
      LUSEdges = DIDALUSEdgesRec.DIDA
      Index2Pos = OutputRec.index2Pos
      EdgeVs = {Map LEdges
		fun {$ edge(IndexI1 IndexI2 LA)}
		   PosI1 = {Index2Pos IndexI1}
		   PosI2 = {Index2Pos IndexI2}
		in
		   '<edge'#
		   ' index1="'#PosI1#'"'#
		   ' index2="'#PosI2#'"'#
		   ' label="'#LA#'"'#
		   '/>\n'
		end}
      EdgeVs1 = {Map LUSEdges
		 fun {$ edge(IndexI1 IndexI2)}
		    PosI1 = {Index2Pos IndexI1}
		    PosI2 = {Index2Pos IndexI2}
		 in
		    '<edge'#
		   ' index1="'#PosI1#'"'#
		   ' index2="'#PosI2#'"'#
		   '/>\n'
		 end}
      EdgeVs2 = {Append EdgeVs EdgeVs1}
      EdgesV = {FoldL EdgeVs2
		fun {$ AccV EdgeV} AccV#EdgeV end ''}
   in
      EdgesV
   end
end
