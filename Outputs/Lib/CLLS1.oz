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
   
   Helpers(appendList) at 'Helpers.ozf'

   Parser(parseVS) at 'CLLS/Parser.ozf'
   CLLS2Lits(convert) at 'CLLS/CLLS2Lits.ozf'
export
   Open
   Close
prepare
   FoldLInd = List.foldLInd
define
   V2A = VirtualString.toAtom
   %%
   %% GetProc: V -> Proc
   %% Returns Proc: A -> A (used here to make node variables unique).
   fun {GetProc V}
      Proc = fun {$ A} {V2A A#'_'#'f'#V} end
   in
      Proc
   end
   %% Open: DIDA I OutputRec -> U
   proc {Open DIDA I OutputRec}
      NodeOLs = OutputRec.nodeOLs
      LexLits = {FoldLInd NodeOLs
		 fun {$ IndexI AccLits NodeOL}
		    ConsV = NodeOL.DIDA.entry.cons
		    if ConsV=='_' then
		       WordA = NodeOL.DIDA.entry.word
		    in
		       raise error1('functor':'Outputs/Lib/CLLS.ozf' 'proc':'Open' msg:'Cannot get unique CLLS fragment for word "'#WordA#'" with index '#IndexI#' (it appears that lexical entries with different CLLS fragments can still be selected).' info:o(IndexI NodeOL) coord:noCoord file:noFile) end
		    end
		    CLLS = {Parser.parseVS ConsV}
		    Proc = {GetProc IndexI}
		    AnchorA = NodeOL.DIDA.entry.anchor
		    Lits = {CLLS2Lits.convert CLLS Proc AnchorA}
		 in
		    {Append AccLits Lits}
		 end nil}
      %%
      DomLits =
      if {HasFeature OutputRec.edges.ledges sc} then
	 SCLEdges = OutputRec.edges.ledges.sc
	 SCLDEdges = OutputRec.edges.ldedges.sc
      in
	 {FoldL {Append SCLEdges SCLDEdges}
	  fun {$ AccLits Edge}
	     I1 = Edge.1
	     I2 = Edge.2
	     LA = Edge.3
	     %%
	     NodeOL1 = {Nth NodeOLs I1}
	     VarAs1 = NodeOL1.DIDA.entry.dom.LA
	     Proc1 = {GetProc I1}
	     %%
	     NodeOL2 = {Nth NodeOLs I2}
	     VarAs2 = NodeOL2.DIDA.entry.roots
	     Proc2 = {GetProc I2}
	  in
	     if {Not VarAs1==nil orelse VarAs2==nil} then
		VarA1 = {Proc1 VarAs1.1}
		VarA2 = {Proc2 VarAs2.1}
		Lit = dom(VarA1 VarA2)
	     in
		Lit|AccLits
	     else
		AccLits
	     end
	  end nil}
      else
	 nil
      end
      %%
      LamLits =
      if {HasFeature OutputRec.edges.ledges pa} then
	 PALEdges = OutputRec.edges.ledges.pa
      in
	 {FoldL PALEdges
	  fun {$ AccLits edge(I1 I2 LA)}
	     NodeOL1 = {Nth NodeOLs I1}
	     VarAs1 = NodeOL1.DIDA.entry.var.LA
	     Proc1 = {GetProc I1}
	     %%
	     NodeOL2 = {Nth NodeOLs I2}
	     VarAs2 = NodeOL2.DIDA.entry.lam.LA
	     Proc2 = {GetProc I2}
	  in
	     if {Not VarAs1==nil orelse VarAs2==nil} then
		VarA1 = {Proc1 VarAs1.1}
		VarA2 = {Proc2 VarAs2.1}
		Lit = lam(VarA1 VarA2)
	     in
		Lit|AccLits
	     else
		AccLits
	     end
	  end nil}
      else
	 nil
      end
      %%
      Lits = {Helpers.appendList [LexLits DomLits LamLits]}
      %%
      PrintProc = OutputRec.printProc
   in
      {PrintProc Lits}
   end
   %% Close: DIDA -> U
   proc {Close _}
      skip
   end
end
