%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD(reflect)
   FS(include)
export
   Get
prepare
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
define
   %% PosSort: DIDA Node1 Node2 -> B
   %% Returns true if the position of Node1 < position of Node2 and
   %% false if not.
   fun {PosSort Node1 Node2}
      M1 = Node1.pos
      M2 = Node2.pos
      D1 = {FS.include $ M1}
      D2 = {FS.include $ M2}
      I1 = {FD.reflect.min D1}
      I2 = {FD.reflect.min D2}
   in
      I1<I2
   end
   %% Get: Nodes -> Proc
   %% Creates a procedure Proc: I -> I1 mapping indices to positions.
   fun lazy {Get Nodes}
      Nodes1 =
      {Sort Nodes
       fun {$ Node1 Node2}
	  {PosSort Node1 Node2}
       end}
      %% finally, map the indices to the positions of the obtained
      %% ordering Nodes1.
      IndexIPosITups = {ListMapInd Nodes1
			fun {$ PosI Node1}
			   IndexI = Node1.index
			in
			   IndexI#PosI
			end}
      IndexIPosIRec = {ListToRecord o IndexIPosITups}
      fun {IndexI2PosI IndexI} IndexIPosIRec.IndexI end
   in
      IndexI2PosI
   end
end
