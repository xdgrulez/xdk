%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Module(link)

   Helpers(getFilePart getSuffix dup) at 'Helpers.ozf'
export
   Merge
prepare
   ListForAllInd = List.forAllInd
   RecordForAllInd = Record.forAllInd
   RecordToDictionary = Record.toDictionary
   RecordToList = Record.toList
define
   %% Merge: SLE1 SLE2 V -> SLE
   %% Merges SLE1 and SLE2 together to one SLE (if possible).  V is
   %% the path to the file yielding SLE (just used for more detailed
   %% exceptions).
   fun {Merge SLE1 SLE2 V}
      {Compare SLE1 SLE2 V}
      %% merge lexical entries
      AEntriesDict = {RecordToDictionary SLE1.aEntriesRec}
      {RecordForAllInd SLE2.aEntriesRec
       proc {$ A Entries2}
	  Entries1 = {CondSelect AEntriesDict A nil}
	  Entries11 = {Filter Entries1
		       fun {$ Entry}
			  {Not {Member Entry Entries2}}
		       end}
       in
	  AEntriesDict.A := {Append Entries11 Entries2}
       end}
      AEntriesRec = {Dictionary.toRecord o AEntriesDict}
      As = {Arity AEntriesRec}
      EntriesI = {FoldL As
		  fun {$ AccI A}
		     Entries = AEntriesRec.A
		     I = {Length Entries}
		  in
		     AccI+I
		  end 0}
      %%
      SLE = grammar(
	       %% (dimensions)
	       usedDIDAs: SLE2.usedDIDAs
	       allDIDAs: SLE2.allDIDAs
	       dIDADimension1Rec: SLE2.dIDADimension1Rec
	       %% (principles)
	       pnPrinciple1Rec: SLE2.pnPrinciple1Rec
	       usedPns: SLE2.usedPns
	       chosenPns: SLE2.chosenPns
	       pnCAPriITups: SLE2.pnCAPriITups
	       %% (outputs)
	       dIDAUsedOnsRec: SLE2.dIDAUsedOnsRec
	       onOutput1Rec: SLE2.onOutput1Rec
	       chosenOns: SLE2.chosenOns
	       usedOns: SLE2.usedOns
	       %% (entries)
	       aEntriesRec: AEntriesRec
	       as: As
	       entriesI: EntriesI
	       %% (the rest)
	       entry1Tn: SLE2.entry1Tn
	       nodeTn: SLE2.nodeTn
	       node1Tn: SLE2.node1Tn
	       tnTypeRec: SLE2.tnTypeRec
	       )
   in
      SLE
   end
   %% Compare: SLE1 SLE2 V -> U
   %% Compares SLE1 and SLE2, raises an exception if the type definitions
   %% are different.
   %% V is the path to the file yielding SLE2 (for more
   %% detailed exceptions).
   proc {Compare SLE1 SLE2 V}
      fun {A2V A}
	 case A
	 of entry1Tn then 'entry type definitions'
	 [] modelTn then 'model type definitions'
	 [] tnTypeRec then 'type definitions'
	 end
      end
      %%
      proc {Compare1 A NSLRec1 NSLRec2}
	 proc {Compare2 SL1 SL2}
	    if {IsList SL1} then
	       if {Not {IsList SL2}} orelse {Not {Length SL1}=={Length SL2}} then
		  raise error1('functor':'Compiler/Merger.ozf' 'proc':'Compare2' msg:'Merge: Different '#{A2V A}#' ('#A#') in file: '#V info:o(SL1 SL2) coord:noCoord file:noFile) end
	       end
	       {ListForAllInd SL1
		proc {$ I SL1I}
		   SL2I = {Nth SL2 I}
		in
		   {Compare2 SL1I SL2I}
		end}
	    elseif {IsRecord SL1} then
	       SLs1 = {RecordToList SL1}
	       SLs2 = {RecordToList SL2}
	    in
	       {Compare2 SLs1 SLs2}
	    elseif {IsName SL1} then
	       SL11 = NSLRec1.SL1
	       if {Not {HasFeature NSLRec2 SL2}} then
		  raise error1('functor':'Compiler/Merger.ozf' 'proc':'Compare2' msg:'Merge: Different '#{A2V A}#' ('#A#') in file: '#V info:o(SL1 SL2) coord:noCoord file:noFile) end
	       end
	       SL21 = NSLRec2.SL2
	    in
	       {Compare2 SL11 SL21}
	    else
	       if {Not SL1==SL2} then
		  raise error1('functor':'Compiler/Merger.ozf' 'proc':'Compare2' msg:'Merge: Different '#{A2V A}#' ('#A#') in file: '#V info:o(SL1 SL2) coord:noCoord file:noFile)  end
	       end
	    end
	 end
	 %%
	 SL1 = SLE1.A
	 SL2 = SLE2.A
      in
	 {Compare2 SL1 SL2}
      end
      %%
      TnTypeRec1 = SLE1.tnTypeRec
      TnTypeRec2 = SLE2.tnTypeRec
   in
      {Compare1 entry1Tn TnTypeRec1 TnTypeRec2}
      {Compare1 nodeTn TnTypeRec1 TnTypeRec2}
      {Compare1 node1Tn TnTypeRec1 TnTypeRec2}
      {Compare1 tnTypeRec TnTypeRec1 TnTypeRec2}
   end
end
