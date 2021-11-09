%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   Open
   Close
define
   %% Open: DIDA I OutputRec -> U
   %% Prints nodes in the abbreviated output language for dimension
   %% DIDA, solution I, and output record OutputRec.
   proc {Open DIDA I OutputRec}
      NodeOLAbbrs = OutputRec.nodeOLAbbrs
      NodeOLAbbrs1 =
      {Map NodeOLAbbrs
       fun {$ NodeOLAbbr}
	  EntryIndexI = NodeOLAbbr.entryIndex
	  IndexI = NodeOLAbbr.index
	  PosI = NodeOLAbbr.pos
	  WordA = NodeOLAbbr.word
	  Rec = o(entryIndex: EntryIndexI
		  index: IndexI
		  pos: PosI
		  word: WordA
		  DIDA: NodeOLAbbr.DIDA)
       in
	  Rec
       end}
      PrintProc = OutputRec.printProc
   in
      {PrintProc I#NodeOLAbbrs1}
   end
   %% Close: DIDA -> U
   %% Does nothing.
   proc {Close _}
      skip
   end
end
