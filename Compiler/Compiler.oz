%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)

%   Inspector(inspect:Inspect)
   
   FS(include exclude subset disjoint intersect card)
   Module(link manager)
   Open(socket text file)
   Pickle(load saveCompressed)
   URL(resolve make)
   
   Helpers(expandUrlV changeSuffix getSuffix mv pickleCompile
	   isSubset v2PortI cIL2A iIL2I) at 'Helpers.ozf'
   
   ULParser(parseUrl parseV) at 'UL/Parser.ozf'
   UL2IL(convert) at 'UL/UL2IL.ozf'

   XMLParser(parseUrl parseV) at 'XML/Parser.ozf'
   XML2IL(convert) at 'XML/XML2IL.ozf'
   
   TypeCollector(collectTypes) at 'TypeCollector.ozf'
   TypeChecker(check) at 'TypeChecker.ozf'
   LatticeMaker(makeTnLatRec) at 'LatticeMaker.ozf'
   Encoder(encode) at 'Encoder.ozf'
   Merger(merge) at 'Merger.ozf'
export
   Files2SLE
   Files2SLC
   File2SLE
   File2SLC
   SLE2File
   SLC2File

   ULFile2SLE
   ULVS2SLE
   ULSocket2SLE
   ULFile2SLC
   ULVS2SLC
   ULSocket2SLC

   XMLFile2SLE
   XMLVS2SLE
   XMLSocket2SLE
   XMLFile2SLC
   XMLVS2SLC
   XMLSocket2SLC
prepare
   ListFoldLInd = List.foldLInd
   RecordMap = Record.map
   RecordSubtractList = Record.subtractList
define
   class SocketK from Open.socket end
   %%
   %% Files2SLE: Vs MetaX PrincipleILs OutputILs DebugB PrintProc -> SLE
   %% Encodes files at URLs Vs, using meta data MetaX for socket
   %% communication, principle definitions PrincipleILs, and output
   %% definitions OutputILs, yielding SLEs. Then merges all the SLEs
   %% together to one SLE (if possible). Prints out debugging
   %% information if DebugB==true, and is quiet otherwise. Prints out
   %% progress information with procedure PrintProc.
   fun {Files2SLE Vs MetaX PrincipleILs OutputILs DebugB PrintProc}
      if Vs==nil then
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'Files2SLE' msg:'No files.' info:o coord:noCoord file:noFile) end
      end
      SLEs = {Map Vs
	      fun {$ V} {File2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc} end}
      SLE1|SLEs1 = SLEs
      SLE = {ListFoldLInd SLEs1
	     fun {$ I AccSLE SLE}
		V = {Nth Vs I+1}
		AccSLE1 = {Merger.merge AccSLE SLE V}
	     in
		AccSLE1
	     end SLE1}
   in
      SLE
   end
   %% Files2SLC: Vs MetaX PrincipleILs OutputILs DebugB PrintProc -> SLC
   %% Encodes files at URLs V, using meta data MetaX, principle
   %% definitions PrincipleILs, and output definitions OutputILs,
   %% yielding SLEs.  Then turns resulting stateless SLE into stateful
   %% SLC.  DebugB and PrintProc are as above.
   fun {Files2SLC Vs MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLE = {Files2SLE Vs MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% File2SLE: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLE
   %% Encodes file at URL V, using meta data MetaX, principle
   %% definitions PrincipleILs, and output definitions OutputILs.
   %% DebugB and PrintProc are as above.
   fun {File2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SuffixS = {Helpers.getSuffix V}
      SLE =
      case SuffixS
      of "ul" then {ULFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      [] "ulsocket" then {ULSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      [] "xml" then {XMLFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      [] "xmlsocket" then {XMLSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      [] "ilp" then {ILPickle2SLE V PrincipleILs OutputILs DebugB PrintProc}
      [] "ozf" then {ILFunctor2SLE V PrincipleILs OutputILs DebugB PrintProc}
      [] "slp" then {SLPickle2SLE V DebugB PrintProc}
      else
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'File2SLE' msg:'Unsupported suffix: '#SuffixS info:o(V) coord:noCoord file:noFile) end
      end
   in
      SLE
   end
   %% File2SLC: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLC
   %% Encodes file at URL V, using meta data MetaX, principle
   %% definitions PrincipleILs, and output definitions OutputILs. Then
   %% turns resulting stateless SLE into stateful SLC. DebugB and
   %% PrintProc are as above.
   fun {File2SLC V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLE = {File2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% UL2SLE: UL PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {UL2SLE UL PrincipleILs OutputILs DebugB PrintProc}
      IL = {UL2IL.convert UL}
      SLE = {EncodeIL IL PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% ULFile2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {ULFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Parsing UL ... '}
      UL = {ULParser.parseUrl V}
      {PrintProc 'Parsing UL done.'}
      SLE = {UL2SLE UL PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% ULVS2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {ULVS2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Parsing UL ... '}
      UL = {ULParser.parseV V}
      {PrintProc 'Parsing UL done.'}
      SLE = {UL2SLE UL PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% ULSocket2SLE: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {ULFromSocket PortI MetaX}
      ClientO = {New SocketK init}
      {Delay 100}
      {ClientO connect(host:localhost port:PortI)}
      {ClientO write(vs:MetaX)}
      {ClientO shutDown(how:[send])}
      V = {ClientO read(list:$ size:all)}
   in
      {ClientO close}
      V
   end
   %%
   fun {ULSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      PortI = {Helpers.v2PortI V}
      {PrintProc 'Getting UL from socket (port '#PortI#') ... '}
      V1 = {ULFromSocket PortI MetaX}
      {PrintProc 'Getting UL from socket (port '#PortI#') done.'}
      if V1==false then
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'ULSocket2SLE' msg:'Could not obtain UL grammar from socket (port '#PortI#').' info:o(V) coord:noCoord file:noFile) end
      end
      %%
      SLE = {ULVS2SLE V1 PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% ULFile2SLC: V PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {ULFile2SLC V PrincipleILs OutputILs DebugB PrintProc}
      SLE = {ULFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% ULVS2SLC: V PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {ULVS2SLC V PrincipleILs OutputILs DebugB PrintProc}
      SLE = {ULVS2SLE V PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% ULSocket2SLC: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {ULSocket2SLC V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLE = {ULSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% XML2SLE: Elements PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {XML2SLE Elements PrincipleILs OutputILs DebugB PrintProc}
      IL = {XML2IL.convert Elements}
      SLE = {EncodeIL IL PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% XMLFile2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {XMLFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Parsing XML ... '}
      Elements = {XMLParser.parseUrl V}
      {PrintProc 'Parsing XML done.'}
      SLE = {XML2SLE Elements PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% XMLVS2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {XMLVS2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Parsing XML ... '}
      Elements = {XMLParser.parseV V}
      {PrintProc 'Parsing XML done.'}
      SLE = {XML2SLE Elements PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% XMLSocket2SLE: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {XMLFromSocket PortI MetaX}
      ClientO = {New SocketK init}
      {Delay 100}
      {ClientO connect(host:localhost port:PortI)}
      {ClientO write(vs:MetaX)}
      {ClientO shutDown(how:[send])}
      V = {ClientO read(list:$ size:all)}
   in
      {ClientO close}
      V
   end
   %%
   fun {XMLSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      PortI = {Helpers.v2PortI V}
      {PrintProc 'Getting XML from socket (port '#PortI#') ... '}
      V1 = {XMLFromSocket PortI MetaX}
      {PrintProc 'Getting XML from socket (port '#PortI#') done.'}
      if V1==false then
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'XMLSocket2SLE' msg:'Could not obtain XML grammar from socket (port '#PortI#').' info:o(V) coord:noCoord file:noFile) end
      end
      %%
      SLE = {XMLVS2SLE V1 PrincipleILs OutputILs DebugB PrintProc}
   in
      SLE
   end
   %% XMLFile2SLC: V PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {XMLFile2SLC V PrincipleILs OutputILs DebugB PrintProc}
      SLE = {XMLFile2SLE V PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% XMLVS2SLC: V PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {XMLVS2SLC V PrincipleILs OutputILs DebugB PrintProc}
      SLE = {XMLVS2SLE V PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% XMLSocket2SLC: V MetaX PrincipleILs OutputILs DebugB PrintProc -> SLC
   fun {XMLSocket2SLC V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLE = {XMLSocket2SLE V MetaX PrincipleILs OutputILs DebugB PrintProc}
      SLC = {SLE2SLC SLE PrintProc}
   in
      SLC
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ILPickle2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {ILPickle2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Loading IL ... '}
      IL = {Pickle.load V}
      SLE = {EncodeIL IL PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Loading IL done.'}
   in
      SLE
   end
   %% ILFunctor2SLE: V PrincipleILs OutputILs DebugB PrintProc -> SLE
   fun {ILFunctor2SLE V PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Loading IL ... '}
      [Functor] = {Module.link [V]}
      if {Not {HasFeature Functor grammar}} then
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'ILFunctor2SLE' msg:'Oz functor is no IL functor: it does not export the grammar under the key grammar' info:o(V) coord:noCoord file:noFile) end
      end
      IL = Functor.grammar
      SLE = {EncodeIL IL PrincipleILs OutputILs DebugB PrintProc}
      {PrintProc 'Loading IL done.'}
   in
      SLE
   end
   %% SLPickle2SLE: V DebugB PrintProc -> SLE
   fun {SLPickle2SLE V DebugB PrintProc}
      {PrintProc 'Loading SL ... '}
      SLE = {Pickle.load V}
      {PrintProc 'Loading SL done.'}
   in
      SLE
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% SLE2File: SLE V DebugB PrintProc -> U
   %% Saves SLE at URL V. DebugB and PrintProc are as above.
   proc {SLE2File SLE V DebugB PrintProc}
      {PrintProc 'Saving pickle ... '}
      {Pickle.saveCompressed SLE V 9}
      {PrintProc 'Saving pickle done.'}
   end
   %% SLC2File: SLC V DebugB PrintProc -> U
   %% Saves SLC at URL V (turns stateful SLC into stateless SLE
   %% first). DebugB and PrintProc are as above.
   proc {SLC2File SLC V DebugB PrintProc}
      SLE = {SLC2SLE SLC}
   in
      {SLE2File SLE V DebugB PrintProc}
   end
   %% EncodeIL: IL PrincipleILs OutputILs DebugB PrintProc -> SLC
   %% Encodes intermediate language expression IL, using principle
   %% definitions PrincipleILs, and output definitions OutputILs.
   %% DebugB and PrintProc are as above.
   fun {EncodeIL IL PrincipleILs OutputILs DebugB PrintProc}
      %% add principle and output definitions
      PrincipleILs1 = {CondSelect IL principles nil}
      PrincipleILs2 = {Append PrincipleILs1 PrincipleILs}
      OutputILs1 = {CondSelect IL outputs nil}
      OutputILs2 = {Append OutputILs1 OutputILs}
      IL1 = {Adjoin IL
	     elem(principles: PrincipleILs2
		  %%
		  outputs: OutputILs2)}
      %% collect types
      {PrintProc 'Collecting types ... '}
      IL2#TnTypeDict#AClassILTCoRec#Entry1Tn#NodeTn#Node1Tn =
      {TypeCollector.collectTypes IL1 DebugB PrintProc}
      {PrintProc 'Collecting types done.'}
      %% typecheck
      {PrintProc 'Checking types ... '}
      IL3#AClassILTChRec#TnTypeRec = {TypeChecker.check IL2 TnTypeDict AClassILTCoRec}
      {PrintProc 'Checking types done.'}
      %% make lattices
      TnLatRec = {LatticeMaker.makeTnLatRec TnTypeRec}
      %% encode
      {PrintProc 'Encoding ... '}
      SLE = {Encoder.encode IL3 TnTypeRec TnLatRec AClassILTChRec Entry1Tn NodeTn Node1Tn DebugB PrintProc}
      {PrintProc 'Encoding done.'}
   in
      SLE
   end
   %%
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% SLC2SLE: SLC -> SLE
   %% Reduce a stateful SLC expression SLC into a stateless SLE
   %% expression SLE.
   fun {SLC2SLE SLC}
      {RecordSubtractList SLC
       [dIDADimensionRec
	dIDA2AttrsLat
	dIDA2EntryLat
	dIDA2LabelLat
	%% (principles)
	pnPrincipleRec
	pn2Principle
	pn2ModelLat
	pn2DIDA
	pnIsActive
	procProcPnCAPriITups
	%% (outputs)
	onOutputRec
	onOutputTups
	%% (entries)
	checkAsInEntries
	as2ABRec
	as2AEntriesRec
	%% the rest
	entry1Lat
	nodeLat
	node1Lat]}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% SLE2SLC: SLE PrintProc -> SLC
   %% Compile SLE expression SLE into SLC expression SLC (-> add
   %% stateful features to the stateless SLE). Prints out progress
   %% information with procedure PrintProc.
   fun {SLE2SLC SLE PrintProc}
      %% make lattices
      TnTypeRec = SLE.tnTypeRec
      TnLatRec = {LatticeMaker.makeTnLatRec TnTypeRec}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% (dimensions)
      %% add feature dIDADimensionRec, and to each dimension,
      %% features attrsLat, entryLat, and labelLat
      DIDADimension1Rec = SLE.dIDADimension1Rec
      DIDADimensionRec = {RecordMap DIDADimension1Rec
			  fun {$ Dimension1}
			     AttrsTn = Dimension1.attrsTn
			     AttrsLat = TnLatRec.AttrsTn
			     %%
			     EntryTn = Dimension1.entryTn
			     EntryLat = TnLatRec.EntryTn
			     %%
			     LabelTn = Dimension1.labelTn
			     LabelLat = TnLatRec.LabelTn
			     %%
			     UsedOns = Dimension1.usedOns
			  in
			     dimension(attrsTn: AttrsTn
				       attrsLat: AttrsLat
				       entryTn: EntryTn
				       entryLat: EntryLat
				       labelTn: LabelTn
				       labelLat: LabelLat
				       usedOns: UsedOns)
			  end}
      %% create functions DIDA2AttrsLat, DIDA2EntryLat, and
      %% DIDA2LabelLat
      fun {DIDA2AttrsLat DIDA} DIDADimensionRec.DIDA.attrsLat end
      fun {DIDA2EntryLat DIDA} DIDADimensionRec.DIDA.entryLat end
      fun {DIDA2LabelLat DIDA} DIDADimensionRec.DIDA.labelLat end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% (principles)
      %% add features dA2DIDA, argRecProc, argsLat, and modelLat to
      %% each principle
      PnPrinciple1Rec = SLE.pnPrinciple1Rec
      PnPrincipleRec = {RecordMap PnPrinciple1Rec
			fun {$ Principle1}
			   PIDA = Principle1.pIDA
			   %%
			   ModelTn = Principle1.modelTn
			   ModelLat = TnLatRec.ModelTn
			   %%
			   Constraints = Principle1.constraints
			   %%
			   DVADIDARec = Principle1.dVADIDARec
			   fun {DVA2DIDA A} DVADIDARec.A end
			   %%
			   DIDAs = Principle1.dIDAs
			   %%
			   ArgRec = Principle1.argRec
			   ArgRecProc = {CompileArgRec ArgRec}
			   %%
			   ArgsTn = Principle1.argsTn
			   ArgsLat = TnLatRec.ArgsTn
			   %%
			   Pn = Principle1.pn
			   %%
			   DIDA = Principle1.dIDA
			in
			   principle(pIDA: PIDA
				     modelTn: ModelTn
				     modelLat: ModelLat
				     constraints: Constraints
				     dVADIDARec: DVADIDARec
				     dVA2DIDA: DVA2DIDA
				     dIDAs: DIDAs
				     argRec: ArgRec
				     argRecProc: ArgRecProc
				     argsTn: ArgsTn
				     argsLat: ArgsLat
				     pn: Pn
				     dIDA: DIDA)
			end}
      %% create function Pn2Principle
      fun {Pn2Principle Pn} PnPrincipleRec.Pn end
      %% create function Pn2ModelLat
      fun {Pn2ModelLat Pn}
	 Principle = {Pn2Principle Pn}
      in
	 Principle.modelLat
      end
      %% create function Pn2DIDA
      fun {Pn2DIDA Pn}
	 Principle = {Pn2Principle Pn}
      in
	 Principle.dIDA
      end
      %% create function PnIsActive
      fun {PnIsActive Pn UsedDIDAs UsedPns}
	 Principle = {Pn2Principle Pn}
	 DIDA = Principle.dIDA
	 DIDAs = Principle.dIDAs
      in
	 {Member DIDA UsedDIDAs} andthen
	 {Member Pn UsedPns} andthen
	 {Helpers.isSubset DIDAs UsedDIDAs}
      end
      %% create a module manager
      {PrintProc 'Linking constraint functors ...'}
      Manager = {New Module.manager init}
      %% create ProcProcPnCAPriITups (= link all constraint
      %% functors, get their constraints, get their profile
      %% procedures)
      PnCAPriITups = SLE.pnCAPriITups
      ProcProcPnCAPriITups =
      {Map PnCAPriITups
       fun {$ Pn#CA#PriI}
	  BaseA = 'Solver/Principles/Lib/'
	  Url = {URL.resolve BaseA CA#'.ozf'}
	  ModuleRec = {Manager link(url:Url $)}
	  Proc = ModuleRec.constraint
	  Proc1 = {CondSelect ModuleRec profile noProfile}
       in
	  Proc#Proc1#Pn#CA#PriI
       end}
      {PrintProc 'Linking constraint functors done.'}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% (outputs)
      %% add features open and close to each Output
      {PrintProc 'Linking output functors ...'}
      OnOutput1Rec = SLE.onOutput1Rec
      OnOutputRec = {RecordMap OnOutput1Rec
		     fun {$ Output1}
			OIDA = Output1.idref
			%%
			FunctorA = Output1.'functor'
			%%
			DIDA = Output1.dIDA
			%%
			BaseA = 'Outputs/Lib/'
			Url = {URL.resolve BaseA FunctorA#'.ozf'}
			ModuleRec = {Manager link(url:Url $)}
			OpenProc = ModuleRec.open
			CloseProc = ModuleRec.close
		     in
			output(idref: OIDA
			       'functor': FunctorA
			       dIDA: DIDA
			       open: OpenProc
			       close: CloseProc)
		     end}
      {PrintProc 'Linking output functors done.'}
      %% order the outputs alphabetically 1) by their name, and 2) by
      %% their dimension name (to match the order of the outputs in
      %% the Outputs menu in the GUI)
      OnOutputTups = {Record.toListInd OnOutputRec}
      OnOutputTups1 = {Sort OnOutputTups
		       fun {$ _#Output1 _#Output2}
			  OIDA1 = Output1.idref
			  OIDA2 = Output2.idref
		       in
			  OIDA1=<OIDA2
		       end}
      OnOutputTups2 = {Sort OnOutputTups1
		       fun {$ _#Output1 _#Output2}
			  DIDA1 = Output1.dIDA
			  DIDA2 = Output2.dIDA
		       in
			  DIDA1=<DIDA2
		       end}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% (entries)
      %% create lexical lookup functions
      AEntriesRec = SLE.aEntriesRec
      %%
      %% CheckAsInEntries: As -> U
      %% Raises an exception if any A in As is not in the lexicon.
      proc {CheckAsInEntries As}
	 for A in As do
	    if {Not {HasFeature AEntriesRec A}} then
	       raise error1('functor':'Compiler/Compiler.ozf' 'proc':'CheckAsInEntries' msg:'Word not contained in lexicon: '#A info:o coord:noCoord file:noFile)
	       end
	    end
	 end
      end
      %%
      %% As2ABRec: As -> ABRec
      %% Gets ABRec for words As. ABRec maps each word A to true (if A
      %% is in the lexicon), or false (if A is not in the lexicon).
      fun {As2ABRec As}
	 ABDict = {NewDictionary}
	 for A in As do
	    if {Not {HasFeature ABDict A}} then
	       ABDict.A := {HasFeature AEntriesRec A}
	    end
	 end
	 ABRec = {Dictionary.toRecord o ABDict}
      in
	 ABRec
      end
      %%
      %% As2AEntriesRec: As -> AEntriesRec
      %% Gets AEntriesRec for words As.
      fun {As2AEntriesRec As}
	 AEntriesDict = {NewDictionary}
	 for A in As do
	    if {Not {HasFeature AEntriesDict A}} then
	       Entries = AEntriesRec.A
	    in
	       AEntriesDict.A := Entries
	    end
	 end
	 AEntriesRec1 = {Dictionary.toRecord o AEntriesDict}
      in
	 AEntriesRec1
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% the rest
      %% get Entry1Lat
      Entry1Tn = SLE.entry1Tn
      Entry1Lat = TnLatRec.Entry1Tn
      %% get NodeLat
      NodeTn = SLE.nodeTn
      NodeLat = TnLatRec.NodeTn
      %% get Node1Lat
      Node1Tn = SLE.node1Tn
      Node1Lat = TnLatRec.Node1Tn
      %%
      {PrintProc 'All Done.'}
   in
      {Adjoin SLE
       grammar(
	  %% (dimensions)
	  dIDADimensionRec: DIDADimensionRec
	  dIDA2AttrsLat: DIDA2AttrsLat
	  dIDA2EntryLat: DIDA2EntryLat
	  dIDA2LabelLat: DIDA2LabelLat
	  %% (principles)
	  pnPrincipleRec: PnPrincipleRec
	  pn2Principle: Pn2Principle
	  pn2ModelLat: Pn2ModelLat
	  pn2DIDA: Pn2DIDA
	  pnIsActive: PnIsActive
	  procProcPnCAPriITups: ProcProcPnCAPriITups
	  %% (outputs)
	  onOutputRec: OnOutputRec
	  onOutputTups: OnOutputTups2
	  %% (entries)
	  checkAsInEntries: CheckAsInEntries
	  as2ABRec: As2ABRec
	  as2AEntriesRec: As2AEntriesRec
	  %% the rest
	  entry1Lat: Entry1Lat
	  nodeLat: NodeLat
	  node1Lat: Node1Lat
	  )}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CompileArgRec: SL -> Proc
   %% Compile an argument record of a principle SL into an argument record
   %% procedure Proc.
   %% Proc: A AXRec -> SL, where
   %% A is a principle argument, and
   %% AXRec is a mapping ('_'|'^'|l) -> X:
   %% * '_': current daughter (Node)
   %% * '^': current mother (Node)
   %% * ql: current label (A)
   fun {CompileArgRec SL}
      Proc =
      fun {$ A AXRec}
	 fun {Eval SL1}
	    case SL1
	    of featurepath(...) then {EvalFeaturepath SL1 AXRec}
	    [] o(...) then {RecordMap SL1 Eval}
	    [] _|_ then {Map SL1 Eval}
	    else SL1
	    end
	 end
	 %%
	 if {Not {HasFeature SL A}} then
	    raise error1('functor':'Compiler/Compiler.ozf' 'proc':'CompileArgRec' msg:'Cannot access argument: '#A info:o(AXRec SL) coord:noCoord file:noFile) end
	 end
	 SL1 = SL.A
      in
	 {Eval SL1}
      end
   in
      Proc
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% EvalFeaturepath: SL AXRec -> SL1
   %% Evaluate featurepath SL, where
   %% AXRec is a mapping ('_'|'^'|ql) -> X:
   %% * '_': current daughter (Node)
   %% * '^': current mother (Node)
   %% * ql: current quantified label (A)
   fun {EvalFeaturepath SL AXRec}
      featurepath(root: RootA
		  dimension_idref: DIDA
		  aspect: AspectA
		  fields: FieldAs ...) = SL
      if {Not {HasFeature AXRec RootA}} then
	 raise error1('functor':'Compiler/Compiler.ozf' 'proc':'EvalFeaturepath' msg:'Root in a feature path cannot be resolved: '#RootA info:o(AXRec SL) coord:noCoord file:noFile) end
      end
      Node = AXRec.RootA
      %%
      Node1 = Node.DIDA
      %%
      Node2 = Node1.AspectA
      %%
      Node3 =
      {FoldL FieldAs
       fun {$ AccRec FieldA}
	  FieldA1 =
	  if FieldA==ql then
	     if {Not {HasFeature AXRec ql}} then
		raise error1('functor':'Compiler/Compiler.ozf' 'proc':'EvalFeaturepath' msg:'Quantified label in a feature path cannot be resolved.' info:o(AXRec ql SL) coord:noCoord file:noFile) end
	     end
	     AXRec.ql
	  else
	     FieldA
	  end
       in
	  AccRec.FieldA1
       end
       Node2}
   in
      Node3
   end
end
