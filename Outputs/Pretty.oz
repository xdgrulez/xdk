%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Inspector(inspect)
export
   Pretty
prepare
   ListToRecord = List.toRecord
   RecordMapInd = Record.mapInd
define
   fun lazy {Pretty Nodes G AbbrB}
      {Pretty1 Nodes G AbbrB}
   end
   %%
   %% Pretty1: Nodes G AbbrB -> OLs
   %% Prettifies node records Nodes, using grammar record G.
   %% If AbbrB then abbreviates.
   fun {Pretty1 Nodes G AbbrB}
      UsedDIDAs = G.usedDIDAs
      DIDA2AttrsLat = G.dIDA2AttrsLat
      DIDA2EntryLat = G.dIDA2EntryLat
      UsedPns = G.usedPns
      Pn2DIDA = G.pn2DIDA
      Pn2ModelLat = G.pn2ModelLat
      NodeLat = G.nodeLat
      %%
      NodeOLs =
      {Map Nodes
       fun {$ Node}
	  Rec = NodeLat.record
	  Rec1 = {RecordMapInd Rec
		  fun {$ A _} Node.A end}
	  OL1 = {NodeLat.pretty Rec1 AbbrB}
	  %%
	  Tups =
	  {Map UsedDIDAs
	   fun {$ DIDA}
	      AttrsLat = {DIDA2AttrsLat DIDA}
	      AttrsOL = {AttrsLat.pretty Node.DIDA.attrs AbbrB}
	      %%
	      EntryLat = {DIDA2EntryLat DIDA}
	      EntryOL = {EntryLat.pretty Node.DIDA.entry AbbrB}
	      %%
	      ModelOLs =
	      {Map UsedPns
	       fun {$ Pn}
		  DIDA1 = {Pn2DIDA Pn}
	       in
		  if DIDA1==DIDA then
		     ModelLat = {Pn2ModelLat Pn}
		     Rec = ModelLat.record
		     Rec1 =
		     {RecordMapInd Rec
		      fun {$ A _} Node.DIDA.model.A end}
		     OL1 = {ModelLat.pretty Rec1 AbbrB}
		  in
		     OL1
		  else
		     o
		  end
	       end}
	      %%
	      ModelOL =
	      {FoldL ModelOLs
	       fun {$ AccModelOL ModelOL}
		  {Adjoin ModelOL AccModelOL}
	       end o}
	   in
	      DIDA#o(attrs: AttrsOL
		     entry: EntryOL
		     model: ModelOL)
	   end}
	  OL2 = {ListToRecord o Tups}
	  %%
	  OL3 = {Adjoin OL1 OL2}
       in
	  OL3
       end}
   in
      NodeOLs
   end
end
