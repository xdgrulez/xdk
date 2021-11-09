%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   System(show)

   Inspector(inspect)

   Helpers(cIL2A x2A getPaths checkPath) at 'Helpers.ozf'
export
   Encode
prepare
   ListFoldLInd = List.foldLInd
   ListToRecord = List.toRecord
   RecordMap = Record.map
   RecordToList = Record.toList
define
   %% Encode: IL TnTypeRec TnLatRec AClassILTChRec Entry1Tn NodeTn Node1Tn DebugB PrintProc -> SL
   %% Encodes IL expression IL into SL expression SL. Prints out
   %% debugging information if DebugB==true, and is quiet otherwise.
   %% Prints out progress information with procedure PrintProc.
   fun {Encode IL TnTypeRec TnLatRec AClassILTChRec Entry1Tn NodeTn Node1Tn DebugB PrintProc}
      %% Encode1: IL -> ILEnc
      %% Encodes IL to yield ILEnc.
      fun {Encode1 IL}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
      in
	 case IL
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% grammar
	 of elem(tag: grammar
		 principles: _
		 outputs: _
		 dimensions: DimensionILs
		 usedimensions: UsedDIDCILs
		 classes: _
		 entries: EntryILs ...) then
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% (dimensions)
	    %% encode all dimensions to yield DIDADimension1Rec
	    DIDADimension1Tups = {Map DimensionILs Encode1}
	    DIDADimension1Rec = {ListToRecord o DIDADimension1Tups}
	    %% get list of IDs of all dimensions (AllDIDAs)...
	    AllDIDAs = {Arity DIDADimension1Rec}
	    %% ...and sort it alphabetically
	    AllDIDAs1 = {Sort AllDIDAs Value.'=<'}
	    %% get list of IDs of all used dimensions (UsedDIDAs)
	    UsedDIDAs = {Map UsedDIDCILs Helpers.cIL2A}
	    %% ...and sort it alphabetically
	    UsedDIDAs1 = {Sort UsedDIDAs Value.'=<'}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% (principles)
	    %% get PnPrinciple1Rec
	    PnPrinciple1Rec = {Dictionary.toRecord o PnPrinciple1Dict}
	    %% get list of names of used principles (UsedPns)
	    UsedPns = {Arity PnPrinciple1Rec}
	    %% get list of names of chosen principles (ChosenPns)
	    ChosenPns = UsedPns
	    %% get PnCAPriITups, where tuple Pn#CA#PriI is made up of
	    %% a principle name Pn, a constraint name CA, and a
	    %% constraint priority PriI.
	    PnCAPriITups =
	    for Pn in ChosenPns collect:Collect do
	       Principle1 = PnPrinciple1Rec.Pn
	       CAPriITups = Principle1.constraints
	    in
	       for CA#PriI in CAPriITups do
		  if PriI==0 then
		     Coord = {CondSelect Principle1 coord noCoord}
		  in
		     raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Non edge constraints cannot have priority 0.' info:o(Pn CA PriI Principle1 'grammar') coord:Coord file:File) end
		  end
		  {Collect Pn#CA#PriI}
	       end
	    end
	    %% sort PnCAPriITups according to priority PriI
	    PnCAPriITups1 = {Sort PnCAPriITups
			     fun {$ _#_#PriI1 _#_#PriI2}
				PriI1>=PriI2
			     end}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% (outputs)
	    %% get record mapping dimension IDs to used outputs
	    %% (DIDAUsedOnsRec)
	    DIDAUsedOnsRec = {RecordMap DIDADimension1Rec
			      fun {$ Dimension1} Dimension1.usedOns end}
	    %% get OnOutputRec
	    OnOutput1Rec = {Dictionary.toRecord o OnOutput1Dict}
	    %% get list of names of chosen outputs (ChosenOns)
	    ChosenOns = {Arity OnOutput1Rec}
	    %% get list of names of all used outputs (UsedOns)
	    UsedOns = for DIDA in AllDIDAs1 append:Append do
			 Dimension1 = DIDADimension1Rec.DIDA
			 UsedOns = Dimension1.usedOns
		      in
			 {Append UsedOns}
		      end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% (entries)
	    %% create AEntriesRec: A -> Entries, where A is a word and
	    %% Entries its corresponding lexical entries
	    AEntriesDict = {NewDictionary}
	    %%
	    EntryILsI = {Length EntryILs}
	    {PrintProc 'Storing '#EntryILsI#' sets of lexical entries ... '}
	    %%
	    Entry1Lat = TnLatRec.Entry1Tn
	    Extra = AClassILTChRec#AClassSLsDict#true
	    %%
	    Paths = {Helpers.getPaths Entry1Lat}
	    %%
	    EntriesI =
	    {ListFoldLInd EntryILs
	     fun {$ I AccI EntryIL}
		Coord1 = {CondSelect EntryIL coord Coord}
		File1 = {CondSelect EntryIL file File}
		%% encode lexical entries
		Entries = {Entry1Lat.encode EntryIL Extra}
		%% count lexical entries
		EntriesI1 = {Length Entries}
	     in
		for Entry in Entries do
		   %% check for each lexical entry:
		   %% 1. It has to define the lex dimension.
		   if {Not {HasFeature Entry lex}} then
		      raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Lexical entry does not have define the lex dimension.' info:o(Entry EntryIL 'grammar') coord:Coord1 file:File1) end
		   end
		   AARec = Entry.lex
		   %% 2. On the lex dimension, it has to define the
		   %% word feature.
		   if {Not {HasFeature AARec word}} then
		      raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Lexical entry does not have field word in the lex dimension.' info:o(AARec Entry EntryIL 'grammar') coord:Coord1 file:File1) end
		   end
		   A = AARec.word
		   %% 3. The word feature must be an atom
		   if {Not {IsAtom A}} then
		      raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Lexical entry does not define feature word in the lex dimension.' info:o(AARec Entry EntryIL 'grammar') coord:Coord1 file:File1) end
		   end
		   %% 4. It contains no undefined value
		   for Path in Paths do
		      if {Helpers.checkPath Entry Path}==false then
			 PathA = {Helpers.x2A Path}
		      in
			 raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Undefined value found in lexical entry for word: "'#A#'", feature path: '#PathA#' (hint: check whether you either leave a string value undefined or you redefine it)' info:o(Entry Path 'grammar') coord:Coord1 file:File1) end
		      end
		   end
		   %%
		   Entries1 = {CondSelect AEntriesDict A nil}
		in
		   AEntriesDict.A := Entry|Entries1
		end
		if I mod 20==0 then
		   {PrintProc I#'/'#EntryILsI#' ... '}
		end
		AccI+EntriesI1
	     end 0}
	    %%
	    AEntriesRec = {Dictionary.toRecord o AEntriesDict}
	    %%
	    As = {Arity AEntriesRec}
	    %%
	    {PrintProc 'Stored '#EntriesI#' lexical entries. '}
	 in
	    %% construct the grammar record, behind the features are
	    %% the fields which will be added in the compile step
	    %% ("Compiler.oz")
	    grammar(
	       %% (dimensions)
	       usedDIDAs: UsedDIDAs1
	       allDIDAs: AllDIDAs1
	       dIDADimension1Rec: DIDADimension1Rec %% dIDADimensionRec, dIDA2AttrsLat, dIDA2EntryLat, dIDA2LabelLat
	       %% (principles)
	       pnPrinciple1Rec: PnPrinciple1Rec %% pnPrincipleRec, pn2Principle, Pn2ModelLat, Pn2DIDA, PnIsActive
	       usedPns: UsedPns
	       chosenPns: ChosenPns
	       pnCAPriITups: PnCAPriITups1 %% procProcPnCAPriITups
	       %% (outputs)
	       dIDAUsedOnsRec: DIDAUsedOnsRec
	       onOutput1Rec: OnOutput1Rec %% onOutputRec
	       chosenOns: ChosenOns
	       usedOns: UsedOns
	       %% (entries)
	       aEntriesRec: AEntriesRec %% checkAsInEntries, as2ABRec, as2AEntriesRec
	       as: As
	       entriesI: EntriesI
	       %% (the rest)
	       entry1Tn: Entry1Tn %% entry1Lat
	       nodeTn: NodeTn %% nodeLat
	       node1Tn: Node1Tn %% node1Lat
	       tnTypeRec: TnTypeRec
	       )
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% dimension
	 [] elem(tag: dimension
		 id: DIDCIL
		 attrs: AttrsTn
		 entry: EntryTn
		 label: LabelTn
		 principles: PrincipleILs
		 outputs: OutputILs
		 useoutputs: UseOutputILs ...) then
	    DIDA = {Helpers.cIL2A DIDCIL}
	    %% encode principles and add them to PnPrinciple1Dict
	    for PrincipleIL in PrincipleILs do
	       Principle = {Encode1 PrincipleIL}
	       Pn = Principle.pn
	    in
	       PnPrinciple1Dict.Pn := Principle
	    end
	    %% add choosen outputs to dictionary OnOutput1Dict, and
	    %% collect used outputs in UsedOns
	    UsedOns =
	    for OutputIL in OutputILs collect:Collect do
	       %% get output ID
	       OIDCIL = OutputIL.id
	       OIDA = {Helpers.cIL2A OIDCIL}
	       %% get output functor
	       FunctorCIL = OutputIL.'functor'
	       FunctorA = {Helpers.cIL2A FunctorCIL}
	       %% create a unique name for the output
	       On = {NewName}
	    in
	       %% enter the output into OnOutput1Dict
	       OnOutput1Dict.On := o(idref: OIDA
				     'functor': FunctorA
				     dIDA: DIDA)
	       %% collect the output if it is used
	       if {Member OutputIL UseOutputILs} then {Collect On} end
	    end
	    %%
	    Dimension1 = dimension(attrsTn: AttrsTn
				   entryTn: EntryTn
				   labelTn: LabelTn
				   usedOns: UsedOns)
	 in
	    DIDA#Dimension1
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% useprinciple
	 [] elem(tag: useprinciple
		 idref: PIDCIL
		 dimensions: CILCILTups
		 args: IL
		 modelTn: ModelTn
		 constraints: CAPriIRec
		 %%
		 pn: Pn
		 %%
		 dIDA: DIDA ...) then
	    PIDA = {Helpers.cIL2A PIDCIL}
	    %%
	    DVADIDATups = {Map CILCILTups
			   fun {$ CIL1#CIL2}
			      DVA = {Helpers.cIL2A CIL1}
			      DIDA = {Helpers.cIL2A CIL2}
			   in
			      DVA#DIDA
			   end}
	    DVADIDARec = {ListToRecord o DVADIDATups}
	    DIDAs = {RecordToList DVADIDARec}
	    %%
	    ArgsTn = IL.tn
	    ArgsLat = TnLatRec.ArgsTn
	    Extra = AClassILTChRec#AClassSLsDict#true
	    SLs = {ArgsLat.encode IL Extra}
	    if {Length SLs}>1 then
	       raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Cannot use disjunction in arguments for a principle.' info:o(IL SLs 'useprinciple') coord:Coord file:File) end
	    end
	    SL = if SLs==nil then o else SLs.1 end
	    %%
	    ArgsPaths = {Helpers.getPaths ArgsLat}
	    for Path in ArgsPaths do
	       if {Helpers.checkPath SL Path}==false then
		  DIDAsA = {Helpers.x2A DIDAs}
		  PathA = {Helpers.x2A Path}
	       in		  
		  raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Undefined value found in arguments for principle: '#PIDA#', dimensions: '#DIDAsA#', feature path: '#PathA info:o(SL Path 'grammar') coord:Coord file:File) end
	       end
	    end
	    %%
	    Principle =  principle(pIDA: PIDA
				   modelTn: ModelTn
				   constraints: CAPriIRec
				   dVADIDARec: DVADIDARec
				   dIDAs: DIDAs
				   argRec: SL
				   argsTn: ArgsTn
				   pn: Pn
				   dIDA: DIDA)
	 in
	    Principle
	 else
	    raise error1('functor':'Compiler/Encoder.ozf' 'proc':'Encode1' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
      end
      PnPrinciple1Dict = {NewDictionary}
      OnOutput1Dict = {NewDictionary}
      AClassSLsDict = {NewDictionary}
   in
      {Encode1 IL}
   end
end
