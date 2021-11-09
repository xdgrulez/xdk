%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(cIL2A) at 'Helpers.ozf'
export
   Decode
prepare
   RecordMapInd = Record.mapInd
define
   fun lazy {Decode Nodes G}
      UsedDIDAs = G.usedDIDAs
      DIDA2AttrsLat = G.dIDA2AttrsLat
      DIDA2EntryLat = G.dIDA2EntryLat
      UsedPns = G.usedPns
      Pn2DIDA = G.pn2DIDA
      Pn2ModelLat = G.pn2ModelLat
      NodeLat = G.nodeLat
      %%
      NodeILs =
      {Map Nodes
       fun {$ Node}
	  %% get tuples CILILTups1 using NodeLat
	  %% (fields: entryIndex, index, pos, nodeSet, and word)
	  Rec = NodeLat.record
	  Rec1 = {RecordMapInd Rec
		  fun {$ A _} Node.A end}
	  IL1 = {NodeLat.decode Rec1}
	  CILILTups1 = {CondSelect IL1 args nil}
	  %% for each used dimension DIDA in UsedDIDAs, get CILILTups2
	  %% (fields: attrs, entry, and model)
	  CILILTups2 =
	  {Map UsedDIDAs
	   fun {$ DIDA}
	      %% use AttrsLat to get AttrsIL
	      AttrsLat = {DIDA2AttrsLat DIDA}
	      AttrsIL = {AttrsLat.decode Node.DIDA.attrs}
	      %% use EntryLat to get EntryIL
	      EntryLat = {DIDA2EntryLat DIDA}
	      EntryIL = {EntryLat.decode Node.DIDA.entry}
	      %% use ModelLat to get ModelILs
	      ModelILs =
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
		     IL1 = {ModelLat.decode Rec1}
		  in
		     IL1
		  else
		     elem(tag: record
			  args: nil)
		  end
	       end}
	      %% append the args (features) of all ModelIL in ModelILs
	      CILILTups =
	      for ModelIL in ModelILs append:Append do
		 CILILTups1 = {CondSelect ModelIL args nil}
	      in
		 {Append CILILTups1}
	      end
	      %% and construct a new IL record ModelIL using with args CILILTups
	      ModelIL = elem(tag: record
			     args: CILILTups)
	   in
	      elem(tag: constant
		   data: DIDA)#
	      elem(tag: record
		   args: [elem(tag: constant
			       data: 'attrs')#
			  AttrsIL
			  %%
			  elem(tag: constant
			       data: 'entry')#
			  EntryIL
			  %%
			  elem(tag: constant
			       data: 'model')#
			  ModelIL])
	   end}
	  %%
	  CILILTups = {Append CILILTups1 CILILTups2}
       in
	  elem(tag: record
	       args: CILILTups)
       end}
   in
      NodeILs
   end
end
