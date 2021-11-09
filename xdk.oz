%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint:Breakpoint)
   
   Application(exit getArgs)
   Browser(browse close)
   Inspector(close configure inspect)
   Module(link)
   Open(file text)
   OS(pipe system)
   Property(put)
   Search(base)
   System(show showError showInfo printInfo)
   Tk(addYScrollbar batch button entry frame label listbox
      menu menuentry return scrollbar toplevel variable)
   TkTools(menubar)
   
   Helpers(allButLast addHandlers changeSuffix e2V getFilePart getWords segment
	   tkDialog tkDialogImage tkDialog2 tkGetOpenFiles tkError tkGetI tkGetS tkGetSublist
	   memberInd x2V vs2S getLines getTime getSuffix putV
	   fileV2TmpUrlV) at 'Helpers.ozf'
   
   Compiler(files2SLC sLC2File) at 'Compiler/Compiler.ozf'
   NodesCompiler(partitionAs as2WordAs fileAs2NodesProc) at 'Compiler/NodesCompiler.ozf'
   Converter(convert) at 'Compiler/Converter.ozf'
   
%   Outputs(close outputs open) at 'Outputs/Outputs.ozf'
   Pretty(pretty) at 'Outputs/Pretty.ozf'
   
   Solver(make getProfile) at 'Solver/Solver.ozf'
%   Principles(principles) at 'Solver/Principles/Principles.ozf'

   LemComparer(compare) at 'Extras/LemComparer.ozf'
   OrderingsGenerator(generate) at 'Extras/OrderingsGenerator.ozf'
   SolvingStatistics(perform) at 'Extras/SolvingStatistics.ozf'
   CPKit(options kits optionDef optionsStr) at 'Solver/Principles/Lib/CPKit.hub.ozf'

   PrincipleManager(open) at 'PrincipleManager/PrincipleManager.ozf'
   OutputManager(open) at 'OutputManager/OutputManager.ozf'
prepare
   ListMapInd = List.mapInd
   ListToTuple = List.toTuple
   ListToRecord = List.toRecord
define
   {Helpers.addHandlers}
   %%
   A2S = Atom.toString
   %%
   S2A = String.toAtom
   %%
   S2I = String.toInt
   %%
   V2A = VirtualString.toAtom
   %%
   %% GetInput: U -> WordAsFileAsTup
   %% Gets a pair of word atoms WordAs and file atoms FileAs from
   %% widget SInputW.
   fun {GetInput}
      As = {Helpers.getWords SInputW}
      WordAs#FileAs = {NodesCompiler.partitionAs As}
   in
      WordAs#FileAs
   end

   %% GetWords: U -> WordAs
   %% Gets atoms WordAs from widget SInputW.
   fun {GetWords}
      WordAs#_ = {GetInput}
   in
      WordAs
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Create global variables (arranged in dictionary GlobalDict)
   GlobalDict = {NewDictionary}
   %% grammar
   proc {ResetG}
      GlobalDict.g := unit
   end
   {ResetG}

   %% grammar path
   proc {ResetGPathSs}
      GlobalDict.gPathSs := nil
   end
   {ResetGPathSs}

   %% examples
   proc {ResetEAs}
      GlobalDict.eAs := nil
   end
   {ResetEAs}

   %% examples
   proc {ResetEPathS}
      GlobalDict.ePathS := ""
   end
   {ResetEPathS}

   %% solutions
   proc {ResetSolutionsI}
      GlobalDict.solutionsI := 9999
   end
   {ResetSolutionsI}

   %% failures
   proc {ResetFailuresI}
      GlobalDict.failuresI := 9999
   end
   {ResetFailuresI}

   %% timeout
   proc {ResetTimeoutI}
      GlobalDict.timeoutI := 3600
   end
   {ResetTimeoutI}

   %% recomputation
   proc {ResetRecoI}
      GlobalDict.recoI := 1
   end
   {ResetRecoI}

   %% open outputs
   proc {ResetOpenOutputsProc}
      Proc = proc {$ _ _} skip end
   in
      GlobalDict.openOutputsProc := Proc
   end
   {ResetOpenOutputsProc}

   %% close outputs
   proc {ResetCloseOutputsProc}
      Proc = proc {$} skip end
   in
      GlobalDict.closeOutputsProc := Proc
   end
   {ResetCloseOutputsProc}

   %% DIDATkvarTups
   proc {ResetDIDATkvarTups}
      GlobalDict.dIDATkvarTups := nil
   end
   {ResetDIDATkvarTups}

   %% DCheckButtonWs
   proc {ResetDCheckButtonWs}
      GlobalDict.dCheckButtonWs := nil
   end
   {ResetDCheckButtonWs}

   %% PnTkvarTups
   proc {ResetPnTkvarTups}
      GlobalDict.pnTkvarTups := nil
   end
   {ResetPnTkvarTups}

   %% PSubMenuWs
   proc {ResetPSubMenuWs}
      GlobalDict.pSubMenuWs := nil
   end
   {ResetPSubMenuWs}

   %% PCascadeWs
   proc {ResetPCascadeWs}
      GlobalDict.pCascadeWs := nil
   end
   {ResetPCascadeWs}

   %% PCheckButtonWs
   proc {ResetPCheckButtonWs}
      GlobalDict.pCheckButtonWs := nil
   end
   {ResetPCheckButtonWs}

   %% OnTkvarTups
   proc {ResetOnTkvarTups}
      GlobalDict.onTkvarTups := nil
   end
   {ResetOnTkvarTups}

   %% OSubMenuWs
   proc {ResetOSubMenuWs}
      GlobalDict.oSubMenuWs := nil
   end
   {ResetOSubMenuWs}

   %% OCascadeWs
   proc {ResetOCascadeWs}
      GlobalDict.oCascadeWs := nil
   end
   {ResetOCascadeWs}

   %% OCheckButtonWs
   proc {ResetOCheckButtonWs}
      GlobalDict.oCheckButtonWs := nil
   end
   {ResetOCheckButtonWs}

   %% OracleO
   proc {ResetOracleO}
      GlobalDict.oracleO := unit
   end
   {ResetOracleO}

   %% ConnectedPortI
   proc {ResetConnectedPortI}
      GlobalDict.connectedPortI := unit
   end
   {ResetConnectedPortI}

   %% PortI
   proc {ResetPortI}
      GlobalDict.portI := 4711
   end
   {ResetPortI}

   %% PortI
   proc {ResetOrderedDIDAs}
      GlobalDict.orderedDIDAs := [lp]
   end
   {ResetOrderedDIDAs}

   %% InputAs
   proc {ResetInputAs}
      GlobalDict.inputAs := nil
   end
   {ResetInputAs}
   
   %% PrinciplesFunctor
   proc {ResetPrinciplesFunctor}
      GlobalDict.principlesFunctor := unit
   end
   {ResetPrinciplesFunctor}

   %% OutputsFunctor
   proc {ResetOutputsFunctor}
      GlobalDict.principlesFunctor := unit
   end
   {ResetOutputsFunctor}

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ExplorerFunctor
   IOzSeFFunctor
   [ExplorerFunctor] = {Module.link ['x-oz://system/Explorer.ozf']}
   [IOzSeFFunctor] = {Module.link ['x-ozlib://tack/iozsef/iozsef.ozf']}

   [OracleFunctor] = {Module.link ['SXDG/XDGOracle.ozf']}
   [XDGExternaliserFunctor] = {Module.link ['SXDG/XDGExternaliser.ozf']}

   %%
   {Inspector.configure widgetTreeFont font(family:courier size:10 weight:normal)}
   {Inspector.configure widgetShowStrings false}
   %%
   {Property.put 'errors.depth' 10000}
   {Property.put 'errors.width' 10000}
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Error handling
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% HandleException: E -> U
   %% Displays an error dialog using Helpers.tkError, with title 'XDK:
   %% Error' and text specified by the exception E.
   proc {HandleException E}
      DebugB = {DebugTkvar tkReturnInt($)}==1
      V = {Helpers.e2V E}
      if DebugB orelse V=='unhandled error' then {Inspector.inspect E} end
   in
      {Helpers.tkError 'XDK: Error' V}
   end
   %%
   proc {CheckG G}
      if G==unit then
	 raise error1('functor':'xdk.ozf' 'proc':'CheckG' msg:'No successfully compiled grammar.' info:o coord:noCoord file:noFile) end
      end
   end
   %%
   proc {CheckGPathSs Ss}
      if Ss==nil then
	 raise error1('functor':'xdk.ozf' 'proc':'CheckGPathSs' msg:'No grammar.' info:o coord:noCoord file:noFile) end
      end
   end
   %%
   proc {CheckEAs As}
      if As==nil then
	 raise error1('functor':'xdk.ozf' 'proc':'CheckEAs' msg:'No examples.' info:o coord:noCoord file:noFile) end
      end
   end
   %%
   proc {CheckEPathS S}
      if S==nil then
	 raise error1('functor':'xdk.ozf' 'proc':'CheckEPathS' msg:'No examples path.' info:o coord:noCoord file:noFile) end
      end
   end
   %%
   proc {CheckWords As}
      if As==nil then
	 raise error1('functor':'xdk.ozf' 'proc':'CheckWords' msg:'No input.' info:o coord:noCoord file:noFile) end
      end
      %%
%      {Inspector.inspect 'CheckWords'#As}
      Ss = GlobalDict.gPathSs
   in
      {CheckGPathSs Ss}
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Grammars
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% GetSearchProc: U -> SearchProc
   %% Gets search procedure depending on the value of SearchTkvar.
   fun {GetSearchProc}
      SearchA = {SearchTkvar tkReturnAtom($)}
      SearchProc =
      proc {$ Proc}
	 Nodes
      in
	 case SearchA
	 of first then
	    {MetaExplorerOne Proc}
	 [] all then
	    {MetaExplorerAll Proc}
	 else
	    {Proc Nodes}
	 end
      end
   in
      SearchProc
   end

   %% GetPrintProc: U -> PrintProc
   %% Gets print procedure depending on the value of PrintTkvar.
   fun {GetPrintProc}
      PrintA = {PrintTkvar tkReturnAtom($)}
      PrintProc =
      case PrintA
      of browse then
	 Browser.browse
      [] stdout then
	 proc {$ X}
	    if {IsVirtualString X} then
	       {System.showInfo X}
	    else
	       {System.show X}
	    end
	 end
      [] file then
	 proc {$ X}
	    S =
	    {Tk.return tk_getSaveFile(title: 'XDK: Print to file'
				      filetypes: q(q('All files' '*')))}
	 in
	    if {Not S==""} then
	       V = if {IsVirtualString X} then
		      X
		   else
		      {Helpers.x2V X}
		   end
	    in
	       {Helpers.putV V S}
	    end
	 end
      else
	 Inspector.inspect
      end
   in
      PrintProc
   end
   
   %% SetGrammar: Ss InputAs1 -> U
   %% Sets a grammar composed from the grammars located at paths Ss
   %% and for input sentence InputAs1.
   proc {SetGrammar Ss InputAs1}
      if Ss==nil then
	 raise error1('functor':'xdk.ozf' 'proc':'SetGrammar' msg:'No grammar.' info:o coord:noCoord file:noFile) end
      end
      InputAs = if InputAs1==nil then ['test'] else InputAs1 end
   in
      try
	 %% assign path S1 to GlobalDict.gPathS
	 GlobalDict.gPathSs := Ss
	 %% set grammar status
	 Ss1 = {Map Ss Helpers.getFilePart}
	 S1 = {Helpers.vs2S Ss1}
	 {GStatusW tk(configure text: 'Grammar: '#S1#' (not successfully compiled)')}
	 %% load new grammar
	 InputA = {V2A
		   {FoldL InputAs
		    fun {$ AccA InputA}
		       AccA#InputA#' '
		    end ''}}
	 MetaX = InputA
	 [PrinciplesFunctor] = {Module.link ['Solver/Principles/Principles.ozf']}
	 GlobalDict.principlesFunctor := PrinciplesFunctor
	 PrincipleILs = PrinciplesFunctor.principles
	 [OutputsFunctor] = {Module.link ['Outputs/Outputs.ozf']}
	 GlobalDict.outputsFunctor := OutputsFunctor
	 OutputILs = OutputsFunctor.outputs
	 DebugB = {DebugTkvar tkReturnInt($)}==1
	 G = {Compiler.files2SLC Ss MetaX PrincipleILs OutputILs DebugB Inspector.inspect}
	 %% and assign grammar G to GlobalDict.g
	 GlobalDict.g := G
	 %% get open outputs procedure (OpenOutputsProc)
	 PrintProc = {GetPrintProc}
	 OpenOutputsProc = {OutputsFunctor.open G PrintProc}
	 %% and assign Proc to GlobalDict.openOutputsProc
	 GlobalDict.openOutputsProc := OpenOutputsProc
	 %% get close outputs procedure
	 CloseOutputsProc = {OutputsFunctor.close G}
	 GlobalDict.closeOutputsProc := CloseOutputsProc
	 %%
	 GlobalDict.inputAs := InputAs
      in
	 {GStatusW tk(configure text: 'Grammar: '#S1)}
	 %%
	 {SetDimensions G}
	 %%
	 {SetPrinciples G}
	 %%
	 {SetOutputs G}
      catch E then
	 {HandleException E}
      end
   end

   %% GetGrammar: InputAs -> G
   %% Gets grammar G for input sentence InputAs.
   fun {GetGrammar InputAs}
      OldG = GlobalDict.g
      OldInputAs = GlobalDict.inputAs
      GSs = GlobalDict.gPathSs
      GlobalDict.inputAs := InputAs
      G =
      if OldG==unit orelse
	 ({Not InputAs==OldInputAs} andthen
	  {Some GSs
	   fun {$ S}
	      SuffixS = {Helpers.getSuffix S}
	   in
	      SuffixS=="ulsocket" orelse SuffixS=="xmlsocket"
	   end}) then
	 {ResetGrammar}
	 {SetGrammar GSs InputAs}
	 G = GlobalDict.g
      in
	 G
      else
	 OldG
      end
      %%
      if G==unit then
	 raise error1('functor':'xdk.ozf' 'proc':'GetGrammar' msg:'No grammar.' info:o coord:noCoord file:noFile) end
      end
      %%
      CheckAsInEntries = G.checkAsInEntries
      {CheckAsInEntries InputAs}
   in
      G
   end

   %% ResetGrammar: U -> U
   %% Resets a grammar:
   %% * closes the output windows
   %% * resets the meta explorer (closes it)
   %% * resets the output menu
   %% * resets the principle menu
   %% * resets the dimensions menu
   %% * resets the GStatusW widget
   %% * resets G
   %% * resets OpenOutputsProc
   %% * resets CloseOutputsProc
   %% * resets GPathSs
   proc {ResetGrammar}
      {CloseOutputWindows}
      %%
      {MetaExplorerClose}
      %%
      {ResetOutputs}
      %%
      {ResetPrinciples}
      %%
      {ResetDimensions}
      %% reset grammar status
      {GStatusW tk(configure text: 'Grammar: ')}
      %% reset G
      {ResetG}
      %% reset OpenOutputsProc
      {ResetOpenOutputsProc}
      %% reset CloseOutputsProc
      {ResetCloseOutputsProc}
      %% reset GPathS
      {ResetGPathSs}
   end

   %% UpdateDimensions: U -> U
   %% Updates usedDIDAs feature of the current grammar and updates the
   %% outputs.
   proc {UpdateDimensions}
      WordAs = {GetWords}
%      {Inspector.inspect 'UpdateDimensions'#WordAs}
      G = {GetGrammar WordAs}
   in
      if {Not G==nil} then
	 UsedDIDAs = {GetUsedDIDAs}
	 G1 = {AdjoinAt G usedDIDAs UsedDIDAs}
      in      
	 GlobalDict.g := G1
      end
      %%
      {UpdateOutputs}
   end
   %% UpdatePrinciples: U -> U
   %% Updates usedPns feature of the current grammar and updates the
   %% outputs.
   proc {UpdatePrinciples}
      WordAs = {GetWords}
%      {Inspector.inspect 'UpdatePrinciples'#WordAs}
      G = {GetGrammar WordAs}
   in
      if {Not G==nil} then
	 UsedPns = {GetUsedPns}
	 G1 = {AdjoinAt G usedPns UsedPns}
      in      
	 GlobalDict.g := G1
      end
      %%
      {UpdateOutputs}
   end
   %% UpdateOutputs: U -> U
   %% Updates usedOns feature of the current grammar, the open outputs
   %% procedure in GlobalDict.openOutputsProc, and the close outputs
   %% procedure in GlobalDict.closeOutputsProc.
   proc {UpdateOutputs}
      WordAs = {GetWords}
%      {Inspector.inspect 'UpdateOutputs'#WordAs}
      G = {GetGrammar WordAs}
   in
      if {Not G==nil} then
	 UsedOns = {GetUsedOns}
	 G1 = {AdjoinAt G usedOns UsedOns}
	 %%
	 PrintProc = {GetPrintProc}
%	 OutputsFunctor = GlobalDict.outputsFunctor
	 [OutputsFunctor] = {Module.link ['Outputs/Outputs.ozf']}
	 GlobalDict.outputsFunctor := OutputsFunctor
	 OpenOutputsProc = {OutputsFunctor.open G1 PrintProc}
	 CloseOutputsProc = {OutputsFunctor.close G1}
      in
	 GlobalDict.g := G1
	 %%
	 GlobalDict.openOutputsProc := OpenOutputsProc
	 GlobalDict.closeOutputsProc := CloseOutputsProc
      end
   end

   %% MakeSolverScript: WordAs FileAs -> Proc
   %% Makes a solver script Proc for words WordAs and files FileAs.
   fun {MakeSolverScript WordAs FileAs}
%      {Inspector.inspect 'MakeSolverScript'#WordAs}
      G = {GetGrammar WordAs}
      %%
      DebugB = {DebugTkvar tkReturnInt($)}==1
      I = {Length WordAs}
      WordA = {V2A
	       {FoldL WordAs
		fun {$ AccA WordA}
		   AccA#WordA#' '
		end ''}}
      MetaX = WordA
      NodesProc = {NodesCompiler.fileAs2NodesProc FileAs I G MetaX DebugB Inspector.inspect}
   in
      if {Not G==nil} then
	 LazyvarsB = {LazyvarsTkvar tkReturnInt($)}==1
	 MemoizeA = {MemoizeTkvar tkReturnAtom($)}
	 ModeA = {ModeTkvar tkReturnAtom($)}
	 ProfileB = {ProfileTkvar tkReturnInt($)}==1
	 SearchA = {SearchTkvar tkReturnAtom($)}
	 FileS =
	 case SearchA
	 of print then
	    FileS = {Tk.return tk_getSaveFile(title: 'XDK: Print CSP'
					      filetypes: q(q('CSP files' '*.csp*')
							   q('All files' '*')))}
	 in
	    if FileS=="" then
	       raise error1('functor':'xdk.ozf' 'proc':'MakeSolverScript' msg:'Cannot print CSP without a file name.' info:o coord:noCoord file:noFile) end
	    end
	    FileS
	 [] flatzinc then
	    FileS = {Tk.return tk_getSaveFile(title: 'XDK: Print FlatZinc'
					      filetypes: q(q('FlatZinc files' '*.fzn*')
							   q('All files' '*')))}
	 in
	    if FileS=="" then
	       raise error1('functor':'xdk.ozf' 'proc':'MakeSolverScript' msg:'Cannot print FlatZinc without a file name.' info:o coord:noCoord file:noFile) end
	    end
	    FileS
	 else
	    ""
	 end
	 Options = o(debug:DebugB
		     lazyvars:LazyvarsB
		     memoize:MemoizeA
		     mode:ModeA
		     profile:ProfileB
		     search:SearchA#FileS)
	 PrinciplesFunctor = GlobalDict.principlesFunctor
	 Proc = {{Solver.make G Options PrinciplesFunctor} WordAs NodesProc}
      in
	 Proc
      end
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Examples
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% SetExamples: S -> U
   %% Sets the example sentences contained in the file corresponding
   %% to path S.
   proc {SetExamples S}
      try
	 ESs = {Helpers.getLines S}
	 EAs = {Map ESs S2A}
	 %% assign examples path S to GlobalDict.ePathS
	 GlobalDict.ePathS := S
	 %% assign examples EAs to GlobalDict.eAs
	 GlobalDict.eAs := EAs
	 %% set examples status
	 S1 = {Helpers.getFilePart S}
	 {EStatusW tk(configure text: 'Examples: '#S1)}
      in
	 if {Not EAs==nil} then
	    ATup = {ListToTuple o EAs}
	 in
	    {EListW tk(insert 'end' ATup)}
	 end
      catch E then
	 {HandleException E}
      end
   end

   %% ResetExamples: U -> U
   %% Resets the EListW widget, the EStatusW widget, and EAs and
   %% EPathS.
   proc {ResetExamples}
      %% reset the list of examples
      I = {EListW tkReturnInt(size $)}
   in
      {EListW tk(delete 0 I-1)}
      %% reset examples status
      {EStatusW tk(configure text: 'Examples: ')}
      %% reset EAs
      {ResetEAs}
      %% reset EPathS
      {ResetEPathS}
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Menus/Buttons
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Project-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% About: U -> U
   %% Displays the about dialog.
   proc {About}
      {Helpers.tkDialogImage 'XDK: About' 'XDG Development Kit: Graphical User Interface\n\nCopyright 2001-2011\n\nVersion 1.6.51\n\nby Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and\nDenys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans)' 'xdk.gif'}
   end
   %% GetOpenFiles: U -> Ss
   %% Lets the user select a list of files Ss with a file dialog.
   fun {GetOpenFiles}
      Ss = {Helpers.tkGetOpenFiles
	    'XDK: Open grammars'
	    q(q('Grammar files' '*.ul')
	      q('Grammar files' '*.xml')
	      q('Grammar files' '*.ilp')
	      q('Grammar files' '*.ozf')
	      q('Grammar files' '*.slp')
	      q('All files' '*'))}
   in
      Ss 
   end
   %% OpenGrammars1: Ss -> U
   %% Opens grammars Ss.
   proc {OpenGrammars1 Ss}
      if {Not Ss==nil} then
	 {ResetGrammar}
	 {SetGrammar Ss nil}
	 %%
	 S1 = Ss.1
	 S2 = {Helpers.changeSuffix S1 "txt"}
      in
	 {ResetExamples}
	 {SetExamples S2}
      end
   end

   %% OpenGrammars: U -> U
   %% Opens a list of grammars (using a file dialog).
   proc {OpenGrammars}
      Ss = {GetOpenFiles}
   in
      if {Not Ss==nil} then
	 {OpenGrammars1 Ss}
      end
   end

   %% OpenGrammarSocket: U -> U
   %% Opens a grammar or a socket (using a string dialog).
   proc {OpenGrammarSocket}
      S = 
      {Helpers.tkGetS 
       'XDK: Open grammar' 'Grammar file/socket'
       "4712.ulsocket"}
   in
      if {Not S==""} then
	 {OpenGrammars1 [S]}
      end
   end

   %% ReloadGrammars: U -> U
   %% Reloads the grammars whose urls are in GlobalDict.gPathSs.
   proc {ReloadGrammars}
      try
	 Ss = GlobalDict.gPathSs
	 {CheckGPathSs Ss}
	 {ResetGrammar}
	 {SetGrammar Ss nil}
	 %%
	 S1 = Ss.1
	 S2 = {Helpers.changeSuffix S1 "txt"}
      in
	 {ResetExamples}
	 {SetExamples S2}
      catch E then
	 {HandleException E}
      end
   end
   
   %% ConvertGrammar: U -> U
   %% Converts grammars (and nodesets).
   proc {ConvertGrammar}
      try
	 FromS =
	 {Tk.return tk_getOpenFile(title: 'XDK: Convert grammar/nodeset: Source'
				   filetypes: q(q('Grammar/nodeset files' '*.ul')
						q('Grammar/nodeset files' '*.xml')
						q('Grammar/nodeset files' '*.ilp')
						q('Grammar/nodeset files' '*.ozf')
						q('All files' '*')))}
      in
	 if {Not FromS==""} then
	    ToS =
	    {Tk.return tk_getSaveFile(title: 'XDK: Convert grammar/nodeset: Destination'
				      filetypes: q(q('Grammar/nodeset files' '*.ul')
						   q('Grammar/nodeset files' '*.xml')
						   q('Grammar/nodeset files' '*.ilp')
						   q('All files' '*')))}
	 in
	    if {Not ToS==""} then
	       {Converter.convert FromS ToS Inspector.inspect}
	    end
	 end
      catch E then
	 {HandleException E}
      end
   end

   %% SaveCompiledGrammar: U -> U
   %% Saves the currently loaded grammar.
   proc {SaveCompiledGrammar}
      try
	 WordAs = {GetWords}
%	 {Inspector.inspect 'SaveCompiledGrammar'#WordAs}
	 G = {GetGrammar WordAs}
	 {CheckG G}
	 S = {Tk.return tk_getSaveFile(title: 'XDK: Save compiled grammar'
				       filetypes: q(q('Grammar files (compiled, record)' '*.slp')
						    q('All files' '*')))}
      in
	 if {Not S==""} then
	    DebugB = {DebugTkvar tkReturnInt($)}==1
	 in
	    {Compiler.sLC2File G S DebugB Inspector.inspect}
	 end
      catch E then
	 {HandleException E}
      end
   end
   
   %% OpenExamples: U -> U
   %% Opens an examples file (using a file dialog).
   proc {OpenExamples}
      S = {Tk.return tk_getOpenFile(title: 'XDK: Open examples'
				    filetypes: q(q('Text files' '*.txt')
						 q('All files' '*')))}
   in
      if {Not S==""} then
	 {ResetExamples}
	 {SetExamples S}
      end
   end

   %% ReloadExamples: U -> U
   %% Reloads the examples file whose url is in GlobalDict.ePathS.
   proc {ReloadExamples}
      try
	 S = GlobalDict.ePathS
      in
	 {CheckEPathS S}
	 {ResetExamples}
	 {SetExamples S}
      catch E then
	 {HandleException E}
      end
   end

   %% CloseOutputWindows: U -> U
   %% Closes all output windows.
   proc {CloseOutputWindows}
      CloseOutputsProc = GlobalDict.closeOutputsProc
   in
      {CloseOutputsProc}
   end

   %% OpenPrincipleManager: U -> U
   %% Opens the Principle Manager.
   proc {OpenPrincipleManager}
      try
	 %% Filter
	 FilterV =
	 if GlobalDict.g==unit then
	    ""
	 else
	    WordAs#_ = {GetInput}
	    G = {GetGrammar WordAs}
	    PnPrincipleRec = G.pnPrincipleRec
	    PIDAs =
	    for Pn in G.usedPns collect:Collect do
	       Principle = PnPrincipleRec.Pn
	       PIDA = Principle.pIDA
	    in
	       {Collect PIDA}
	    end
	    PIDA1|PIDAs1 = PIDAs
	    FilterV1 = PIDA1#"$"#{FoldL PIDAs1
				  fun {$ AccV PIDA}
				     AccV#"|"#PIDA#"$"
				  end ""}
	 in
	    FilterV1
	 end
	 %% Debug
	 DebugB = {DebugTkvar tkReturnInt($)}==1
	 %%
	 PostBuildProc =
	 proc {$}
	    ReloadB = {ReloadTkvar tkReturnInt($)}==1
	 in
	    if ReloadB andthen {Not GlobalDict.g==unit} then
	       {ReloadGrammars}
	    end
	 end
	 %%
	 AXRec = o(filter: FilterV
		   grammar: ""
		   builddeffile: BuildDefFileB
		   ozeditor: OzEditorS
		   uleditor: ULEditorS
		   xmleditor: XMLEditorS
		   %%
		   pwoptimize: PWOptimizeB
		   pwseon: PWSeonB
		   pwadhoc: PWAdhocB
		   %%
		   log: LogA
		   debug: DebugB
		   %%
		   postbuild: PostBuildProc)
      in
	 {PrincipleManager.open AXRec}
      catch E then
	 {HandleException E}
      end
   end

   %% OpenOutputManager: U -> U
   %% Opens the Output Manager.
%    proc {OpenOutputManager}
%       try
% 	 %% Filter
% 	 FilterV =
% 	 if GlobalDict.g==unit then
% 	    ""
% 	 else
% 	    WordAs#_ = {GetInput}
% 	    G = {GetGrammar WordAs}
% 	    PnPrincipleRec = G.pnPrincipleRec
% 	    PIDAs =
% 	    for Pn in G.usedPns collect:Collect do
% 	       Principle = PnPrincipleRec.Pn
% 	       PIDA = Principle.pIDA
% 	    in
% 	       {Collect PIDA}
% 	    end
% 	    PIDA1|PIDAs1 = PIDAs
% 	    FilterV1 = PIDA1#"$"#{FoldL PIDAs1
% 				  fun {$ AccV PIDA}
% 				     AccV#"|"#PIDA#"$"
% 				  end ""}
% 	 in
% 	    FilterV1
% 	 end
% 	 %% Debug
% 	 DebugB = {DebugTkvar tkReturnInt($)}==1
% 	 %%
% 	 PostBuildProc =
% 	 proc {$}
% 	    ReloadB = {ReloadTkvar tkReturnInt($)}==1
% 	 in
% 	    if ReloadB andthen {Not GlobalDict.g==unit} then
% 	       {ReloadGrammars}
% 	    end
% 	 end
% 	 %%
% 	 AXRec = o(filter: FilterV
% 		   grammar: ""
% 		   builddeffile: BuildDefFileB
% 		   ozeditor: OzEditorS
% 		   uleditor: ULEditorS
% 		   xmleditor: XMLEditorS
% 		   %%
% 		   pwoptimize: PWOptimizeB
% 		   pwseon: PWSeonB
% 		   pwadhoc: PWAdhocB
% 		   %%
% 		   log: LogA
% 		   debug: DebugB
% 		   %%
% 		   postbuild: PostBuildProc)
%       in
% 	 {OutputManager.open AXRec}
%       catch E then
% 	 {HandleException E}
%       end
%    end

   %% Quit: U -> U
   %% Quits the application.
   proc {Quit}
      Status=0
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Search-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% SetOraclePort: U -> U
   %% Sets GlobalDict.portI.
   proc {SetOraclePort}
      PortI =
      {Helpers.tkGetI
       'XDK: Set oracle port' 'Oracle port'
       GlobalDict.portI}
   in
      GlobalDict.portI := PortI
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Dimensions-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% SetDimensions: G -> U
   %% Sets up the dimensions menu for grammar G.
   proc {SetDimensions G}
      if {Not G==unit} then
	 AllDIDAs = G.allDIDAs
	 UsedDIDAs = G.usedDIDAs
	 DIDATkvarTups =
	 {Map AllDIDAs
	  fun {$ DIDA}
	     B = {Member DIDA UsedDIDAs}
	     Tkvar = {New Tk.variable tkInit(B)}
	  in
	     DIDA#Tkvar
	  end}
	 GlobalDict.dIDATkvarTups := DIDATkvarTups
	 %%
	 MenuButtonW = MenuW.dimensions.menu
	 DCheckButtonWs =
	 {Map DIDATkvarTups
	  fun {$ DIDA#Tkvar}
	     {New Tk.menuentry.checkbutton tkInit(parent: MenuButtonW
						  label: DIDA
						  var: Tkvar
						  action: UpdateDimensions)}
	  end}
      in
	 GlobalDict.dCheckButtonWs := DCheckButtonWs
      end
   end

   %% ResetDimensions: U -> U
   %% Resets the dimension menu.
   proc {ResetDimensions}
      {ResetDIDATkvarTups}
      %%
      DCheckButtonWs = GlobalDict.dCheckButtonWs
   in
      for DCheckButtonW in DCheckButtonWs do
	 {DCheckButtonW tkClose}
      end
      {ResetDCheckButtonWs}
   end

   %% GetUsedDIDAs: U -> DIDAs
   %% Gets all currently used dimension IDs DIDAs (alphabetically sorted).
   fun {GetUsedDIDAs}
      DIDATkvarTups = GlobalDict.dIDATkvarTups
      UsedDIDAs =
      for DIDA#Tkvar in DIDATkvarTups collect:Collect do
	 B = {Tkvar tkReturnInt($)}==1
      in
	 if B then {Collect DIDA} end
      end
      UsedDIDAs1 = {Sort UsedDIDAs Value.'=<'}
   in
      UsedDIDAs1
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Principles-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% SetPrinciples: G -> U
   %% Sets up the principles menu for grammar G.
   proc {SetPrinciples G}
      if {Not G==unit} then
	 ChosenPns = G.chosenPns
	 UsedPns = G.usedPns
	 Pn2DIDA = G.pn2DIDA
	 Pn2Principle = G.pn2Principle
	 %% create dictionary mapping each dimension to the list of
	 %% principles on that dimension
	 DIDAPnsDict = {NewDictionary}
	 for Pn in ChosenPns do
	    DIDA = {Pn2DIDA Pn}
	 in
	    DIDAPnsDict.DIDA := Pn|{CondSelect DIDAPnsDict DIDA nil}
	 end
	 DIDAPnsTups = {Dictionary.entries DIDAPnsDict}
	 %% sort principles on the dimensions according to their IDs
	 DIDAPnsTups1 =
	 {Map DIDAPnsTups
	  fun {$ DIDA#Pns}
	     Pns1 =
	     {Sort Pns
	      fun {$ Pn1 Pn2}
		 Principle1 = {Pn2Principle Pn1}
		 PIDA1 = Principle1.pIDA
		 Principle2 = {Pn2Principle Pn2}
		 PIDA2 = Principle2.pIDA
	      in
		 PIDA1=<PIDA2
	      end}
	  in
	     DIDA#Pns1
	  end}
	 %% sort dimensions according to their IDs
	 DIDAPnsTups2 =
	 {Sort DIDAPnsTups1
	  fun {$ DIDA1#_ DIDA2#_} DIDA1=<DIDA2 end}
      in
	 for DIDA#Pns in DIDAPnsTups2 do
	    %% create Tk variables for each principle on DIDA
	    PnTkvarTups =
	    {Map Pns
	     fun {$ Pn}
		B = {Member Pn UsedPns}
		Tkvar = {New Tk.variable tkInit(B)}
	     in
		Pn#Tkvar
	     end}
	    GlobalDict.pnTkvarTups :=
	    {Append {CondSelect GlobalDict pnTkvarTups nil} PnTkvarTups}
	    %%
	    PnTkvarRec = {ListToRecord o PnTkvarTups}
	    %% create submenu for DIDA
	    SubMenuW = {New Tk.menu tkInit(parent: MenuW.principles.menu)}
	    GlobalDict.pSubMenuWs :=
	    {Append {CondSelect GlobalDict pSubMenuWs nil} [SubMenuW]}
	    %% create cascade menu entry for DIDA
	    CascadeW =
	    {New Tk.menuentry.cascade tkInit(parent: MenuW.principles.menu
					     label: DIDA
					     menu: SubMenuW)}
	    GlobalDict.pCascadeWs :=
	    {Append {CondSelect GlobalDict pCascadeWs nil} [CascadeW]}
	    %% create check buttons for each principle on DIDA
	    CheckButtonWs =
	    {Map Pns
	     fun {$ Pn}
		Principle = {Pn2Principle Pn}
		PIDA = Principle.pIDA
		DIDAs = Principle.dIDAs
		DIDAsS = {Helpers.vs2S DIDAs}
		V = PIDA#' ('#DIDAsS#')'
		Tkvar = PnTkvarRec.Pn
	     in
		{New Tk.menuentry.checkbutton
		 tkInit(parent: SubMenuW
			label: V
			var: Tkvar
			action: UpdatePrinciples)}
	     end}
	 in
	    GlobalDict.pCheckButtonWs :=
	    {Append {CondSelect GlobalDict pCheckButtonWs nil} CheckButtonWs}
	 end
      end
   end

   %% ResetPrinciples: U -> U
   %% Resets the principles menu.
   proc {ResetPrinciples}
      {ResetPnTkvarTups} 
      %%
      PSubMenuWs = GlobalDict.pSubMenuWs
      PCascadeWs = GlobalDict.pCascadeWs
      PCheckButtonWs = GlobalDict.pCheckButtonWs
   in
      for PSubMenuW in PSubMenuWs do {PSubMenuW tkClose} end
      {ResetPSubMenuWs}
      for PCascadeW in PCascadeWs do {PCascadeW tkClose} end
      {ResetPCascadeWs}
      for PCheckButtonW in PCheckButtonWs do {PCheckButtonW tkClose} end
      {ResetPCheckButtonWs}
   end

   %% GetUsedPns: U -> Pns
   %% Gets all currently used principle names Pns.
   fun {GetUsedPns}
      PnTkvarTups = GlobalDict.pnTkvarTups
      UsedPns =
      for Pn#Tkvar in PnTkvarTups collect:Collect do
	 B = {Tkvar tkReturnInt($)}==1
      in
	 if B then {Collect Pn} end
      end
   in
      UsedPns
   end
   
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Outputs-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %% SetOutputs: G -> U
   %% Sets up the outputs menu for grammar G.
   proc {SetOutputs G}
      if {Not G==unit} then
	 ChosenOns = G.chosenOns
	 UsedOns = G.usedOns
	 OnOutputRec = G.onOutputRec
	 %% create dictionary mapping each dimension to the list of
	 %% outputs on that dimension
	 DIDAOnsDict = {NewDictionary}
	 for On in ChosenOns do
	    Output = OnOutputRec.On
	    DIDA = Output.dIDA
	 in
	    DIDAOnsDict.DIDA := On|{CondSelect DIDAOnsDict DIDA nil}
	 end
	 DIDAOnsTups = {Dictionary.entries DIDAOnsDict}
	 %% sort outputs on the dimensions according to their IDs
	 DIDAOnsTups1 =
	 {Map DIDAOnsTups
	  fun {$ DIDA#Ons}
	     Ons1 =
	     {Sort Ons
	      fun {$ On1 On2}
		 Output1 = OnOutputRec.On1
		 OIDA1 = Output1.idref
		 Output2 = OnOutputRec.On2
		 OIDA2 = Output2.idref
	      in
		 OIDA1=<OIDA2
	      end}
	  in
	     DIDA#Ons1
	  end}
	 %% sort dimensions according to their IDs
	 DIDAOnsTups2 =
	 {Sort DIDAOnsTups1
	  fun {$ DIDA1#_ DIDA2#_} DIDA1=<DIDA2 end}
      in
	 for DIDA#Ons in DIDAOnsTups2 do
	    %% create Tk variables for each output on DIDA
	    OnTkvarTups =
	    {Map Ons
	     fun {$ On}
		B = {Member On UsedOns}
		Tkvar = {New Tk.variable tkInit(B)}
	     in
		On#Tkvar
	     end}
	    GlobalDict.onTkvarTups :=
	    {Append {CondSelect GlobalDict onTkvarTups nil} OnTkvarTups}
	    %%
	    OnTkvarRec = {ListToRecord o OnTkvarTups}
	    %% create submenu for DIDA
	    SubMenuW = {New Tk.menu tkInit(parent: MenuW.outputs.menu)}
	    GlobalDict.oSubMenuWs :=
	    {Append {CondSelect GlobalDict oSubMenuWs nil} [SubMenuW]}
	    %% create cascade menu entry for DIDA
	    CascadeW =
	    {New Tk.menuentry.cascade tkInit(parent: MenuW.outputs.menu
					     label: DIDA
					     menu: SubMenuW)}
	    GlobalDict.oCascadeWs :=
	    {Append {CondSelect GlobalDict oCascadeWs nil} [CascadeW]}
	    %% create check buttons for each output on DIDA
	    CheckButtonWs =
	    {Map Ons
	     fun {$ On}
		Output = OnOutputRec.On
		OIDA = Output.idref
		Tkvar = OnTkvarRec.On
	     in
		{New Tk.menuentry.checkbutton
		 tkInit(parent: SubMenuW
			label: OIDA
			var: Tkvar
			action: UpdateOutputs)}
	     end}
	 in
	    GlobalDict.oCheckButtonWs :=
	    {Append {CondSelect GlobalDict oCheckButtonWs nil} CheckButtonWs}
	 end
      end
   end
   
   %% ResetOutputs: U -> U
   %% Resets the outputs menu.
   proc {ResetOutputs}
      {ResetOnTkvarTups} 
      %%
      OSubMenuWs = GlobalDict.oSubMenuWs
      OCascadeWs = GlobalDict.oCascadeWs
      OCheckButtonWs = GlobalDict.oCheckButtonWs
   in
      for OSubMenuW in OSubMenuWs do {OSubMenuW tkClose} end
      {ResetOSubMenuWs}
      for OCascadeW in OCascadeWs do {OCascadeW tkClose} end
      {ResetOCascadeWs}
      for OCheckButtonW in OCheckButtonWs do {OCheckButtonW tkClose} end
      {ResetOCheckButtonWs}
   end

   %% GetUsedOns: U -> Ons
   %% Gets all currently used output names Ons.
   fun {GetUsedOns}
      OnTkvarTups = GlobalDict.onTkvarTups
      UsedOns =
      for On#Tkvar in OnTkvarTups collect:Collect do
	 B = {Tkvar tkReturnInt($)}==1
      in
	 if B then {Collect On} end
      end
   in
      UsedOns
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Extras-menu
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   proc {CompareLemSolutionsNoFilter}
      {CompareLemSolutions1 none}
   end
   %%
   proc {CompareLemSolutionsSimpleFilter}
      {CompareLemSolutions1 simple}
   end
   %%
   proc {CompareLemSolutionsTaggerFilter}
      {CompareLemSolutions1 tagger}
   end
   %%
   proc {CompareLemSolutions1 FilterA}
      try
	 WordAs#FileAs = {GetInput}
	 {CheckWords WordAs}
%      {Inspector.inspect 'CompareLemSolutions'#WordAs}
	 G = {GetGrammar WordAs}
	 Proc = {MakeSolverScript WordAs FileAs}
	 {Inspector.inspect 'Using filter '#FilterA}
	 {Inspector.inspect 'Getting all solutions (XDK) ...'}
	 Nodess = {Search.base.all Proc}
	 NodeOLss = {Map Nodess
		     fun {$ Nodes}
			NodeOLs = {Pretty.pretty Nodes G false}
		     in
			NodeOLs
		     end}
	 {Inspector.inspect 'done'}
	 {Inspector.inspect 'Getting all solutions (lem) ...'}
	 Rec = {LemComparer.compare NodeOLss WordAs FilterA}
      in
	 {Inspector.inspect 'done'}
	 {Inspector.inspect 'Lem solutions'#{Length Rec.lemATreeTups}}
	 {Inspector.inspect 'XDK solutions'#{Length Rec.xDKATreeTups}}
	 {Inspector.inspect 'Lem only'}
	 for LemA#_ in Rec.lemOnlyATreeTups do
	    {Inspector.inspect LemA}
	 end
	 %%
	 {Inspector.inspect 'XDK only'}
	 for XDKA#_ in Rec.xDKOnlyATreeTups do
	    {Inspector.inspect XDKA} 
	 end
      catch E then
	 {HandleException E}
      end
   end

   %% GenerateOrderings1: U -> U
   %% Generates and displays all possible orderings for a sentence.
   proc {GenerateOrderings1}
      try
	 WordAs#FileAs = {GetInput}
	 {CheckWords WordAs}
%	 {Inspector.inspect 'GenerateOrderings1'#WordAs}
	 G = {GetGrammar WordAs}
	 {CheckG G}
	 %%
	 OldModeA = {ModeTkvar tkReturnAtom($)}
	 {ModeTkvar tkSet(generate)}
	 Proc = {MakeSolverScript WordAs FileAs}
	 {ModeTkvar tkSet(OldModeA)}
	 %%
	 WordA1|WordAs1 = WordAs
	 WordV = {FoldL WordAs1
		  fun {$ AccV A}
		     AccV#' '#A
		  end WordA1}
	 WordA = {V2A WordV}
	 %%
	 {Inspector.inspect solving#WordA}
	 Nodess = {Search.base.all Proc}
	 {Inspector.inspect 'done'}
	 %%
	 OrderingsRec = {OrderingsGenerator.generate Nodess}
	 %% add Inspector-actions for the sets of solutions
	 ListActionRec =
	 'Outputs'(proc {$ Xs}
		      for X in Xs do
			 if {IsInt X} then
			    I = X
			 in
			    if I=<{Length Nodess} then
			       Nodes = {Nth Nodess I}
			       Proc1 = GlobalDict.openOutputsProc
			    in
			       {Proc1 I Nodes}
			    end
			 end
		      end
		   end)
	 {Inspector.configure listMenu
	  menu(nil nil nil [ListActionRec])}
      in
	 {Inspector.inspect OrderingsRec}
      catch E then
	 {HandleException E}
      end
   end

   %% SolveExamples: U -> U
   %% Goes downwards from the current selection through the list of
   %% examples and calls the "Solve" procedure for each example.
   proc {SolveExamples}
      try
	 EAs = GlobalDict.eAs
	 {CheckEAs EAs}
	 %%
	 OldIndexS = {EListW tkReturn(curselection $)}
	 OldIndexI =
	 if {Not OldIndexS==nil} then {S2I OldIndexS} else 0 end
	 %%
	 SizeS = {EListW tkReturn(size $)}
	 SizeI = {S2I SizeS}-1
      in
	 for I in (OldIndexI+1)..SizeI break:Break do
	    CurIndexS = {EListW tkReturn(curselection $)}
	    if {Not CurIndexS==nil} then {EListW tk(selection clear CurIndexS)} end
	    {EListW tk(selection set I)}
	    {EListW tk(see I)}
	    ExampleS = {EListW tkReturn(get(I) $)}
	    {SInputW tk(delete 0 'end')}
	    {SInputW tk(insert 'end' ExampleS)}
	 in
	    if ExampleS==nil then skip
	    elseif ExampleS.1==&/ then skip
	    elseif ExampleS.1==&* then skip
	    elseif ExampleS.1==&% then skip
	    else
	       {Solve}
	       if I<SizeI then
		  B = {Helpers.tkDialog2 'XDK: Solve examples' 'Continue?'}
	       in
		  if {Not B} then {Break} end
	       else
		  {Helpers.tkDialog 'XDK: Solve examples' 'Done.'}
	       end
	    end
	 end
      catch E then
	 {HandleException E}
      end
   end

   %% SaveSolvingStatistics: U -> U
   %% Saves solving statistics into a file.
   proc {SaveSolvingStatistics}
      try
	 EAs = GlobalDict.eAs
	 {CheckEAs EAs}
	 S = {Tk.return tk_getSaveFile(title: 'XDK: Save solving statistics'
				       filetypes: q(q('XML files' '*.xml')
						    q('All files' '*')))}
      in
	 if {Not S==""} then
	    %% prepare solving statistics
	    ExampleAs = EAs
	    %%
	    SegmentProc = Helpers.segment
	    %%
	    MakeSolverScriptProc = fun {$ WordAs FileAs _} {MakeSolverScript WordAs FileAs} end
	    %%
	    PartitionAs = NodesCompiler.partitionAs
	    %%
	    FileO = {New Open.file init(name: S
				       flags: [create truncate write text])}
	    PrintProc = proc {$ V} {FileO write(vs: V)} end
	    %%
	    OutputsB = {OutputsTkvar tkReturnInt($)}==1
	    GetOpenOutputsProc = 
	    if OutputsB then
	       fun {$ WordAs}
		  G = {GetGrammar WordAs}
		  OutputsFunctor = GlobalDict.outputsFunctor
		  OpenProc = {OutputsFunctor.open G PrintProc}
	       in
		  OpenProc
	       end
	    else
	       fun {$ _}
		  proc {$ _ _} skip end
	       end
	    end
	    %%
	    SolvingStartProc = Inspector.inspect
	    %%
	    SolvingEndProc = Inspector.inspect
	    %%
	    GetProfileProc = Solver.getProfile
	    %%
	    ProfileB = {ProfileTkvar tkReturnInt($)}==1
	    %%
	    GetAs2AEntriesRecProc = fun {$ WordAs}
				       G =
				       if GlobalDict.g==unit then
					  {GetGrammar WordAs}
				       else
					  GlobalDict.g
				       end
				    in
				       G.as2AEntriesRec
				    end
	    %%
	    GrammarPathV = {Helpers.vs2S GlobalDict.gPathSs}
	    %%
	    ExamplesPathV = GlobalDict.ePathS
	    %%
	    ModeA = {ModeTkvar tkReturnAtom($)}
	    %%
	    DateV = {Helpers.getTime}
	    %%
	    SolutionsI = GlobalDict.solutionsI
	    %%
	    FailuresI = GlobalDict.failuresI
	    %%
	    TimeoutI = GlobalDict.timeoutI
	    %%
	    RecoI = GlobalDict.recoI
	    %%
	    GetUsedDIDAs1 =
	    fun {$ WordAs}
	       UsedDIDAs =
	       if GlobalDict.g==unit then
%		  {Inspector.inspect 'GetUsedDIDAs'#WordAs}
		  G = {GetGrammar WordAs}
	       in
		  G.usedDIDAs
	       else
		  {GetUsedDIDAs}
	       end
	    in
	       UsedDIDAs
	    end
	    %%
	    GetUsedPrinciples =
	    fun {$ WordAs}
	       UsedPns#G =
	       if GlobalDict.g==unit then
%		  {Inspector.inspect 'GetUsedPrinciples'#WordAs}
		  G = {GetGrammar WordAs}
		  UsedPns = G.usedPns
	       in
		  UsedPns#G
	       else
		  UsedPns = {GetUsedPns}
		  G = GlobalDict.g
	       in
		  UsedPns#G
	       end
	       PnPrincipleRec = G.pnPrincipleRec
	    in
	       {Map UsedPns
		fun {$ Pn} PnPrincipleRec.Pn end}
	    end
	    %%
	    SearchA = {SearchTkvar tkReturnAtom($)}
	    %%
	    DebugB = {DebugTkvar tkReturnInt($)}==1
	    %%
	    Rec = o(examples: ExampleAs
		    segment: SegmentProc
		    makeSolverScript: MakeSolverScriptProc
		    partitionAs: PartitionAs
		    print: PrintProc
		    getOpenOutputs: GetOpenOutputsProc
		    solvingStart: SolvingStartProc
		    solvingEnd: SolvingEndProc
		    profile: ProfileB
		    getProfile: GetProfileProc
		    getAs2AEntriesRec: GetAs2AEntriesRecProc
		    grammarPath: GrammarPathV
		    examplesPath: ExamplesPathV
		    mode: ModeA
		    date: DateV
		    solutions: SolutionsI
		    failures: FailuresI
		    timeout: TimeoutI
		    reco: RecoI
		    getUsedDIDAs: GetUsedDIDAs1
		    getUsedPrinciples: GetUsedPrinciples
		    searchA: SearchA
		    debug: DebugB)
	 in
	    {SolvingStatistics.perform Rec}
	    {Inspector.inspect 'All done'}
	    {FileO close}
	 end
      catch E then
	 {HandleException E}
      end
   end
   %% SetSolutions: U -> U
   %% Sets GlobalDict.solutionsI.
   proc {SetSolutions}
      SolutionsI =
      {Helpers.tkGetI
       'XDK: Set maximum number of solutions' 'Solutions'
       GlobalDict.solutionsI}
   in
      GlobalDict.solutionsI := SolutionsI
   end
   %% SetFailures: U -> U
   %% Sets GlobalDict.failuresI.
   proc {SetFailures}
      FailuresI =
      {Helpers.tkGetI
       'XDK: Set maximum number of failures' 'Failures'
       GlobalDict.failuresI}
   in
      GlobalDict.failuresI := FailuresI
   end
   %% SetTimeout: U -> U
   %% Sets GlobalDict.timeoutI.
   proc {SetTimeout}
      TimeoutI =
      {Helpers.tkGetI
       'XDK: Set timeout (in seconds)' 'Timeout'
       GlobalDict.timeoutI}
   in
      GlobalDict.timeoutI := TimeoutI
   end
   %% SetReco: U -> U
   %% Sets GlobalDict.recoI.
   proc {SetReco}
      RecoI =
      {Helpers.tkGetI
       'XDK: Set maximum recomputation distance' 'Reco'
       GlobalDict.recoI}
   in
      GlobalDict.recoI := RecoI
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Buttons
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% InspectLexicalEntries: U -> U
   %% Inspects for each word currently in the LInputW widget its
   %% corresponding lexical entries.
   proc {InspectLexicalEntries}
      try
	 WordAs1 = {Helpers.getWords LInputW}
	 WordAITups =
	 for WordA1 in WordAs1 collect:Collect do
	    WordS = {A2S WordA1}
	    WordSs = {String.tokens WordS &#}
	    WordA = if WordSs.1=="" then
		       WordA1
		    else
		       {S2A WordSs.1}
		    end
	 in
	    if {Not WordA==''} then
	       I = if {Length WordSs}==2 then
		      {S2I {Nth WordSs 2}}
		   else
		      0
		   end
	    in
	       {Collect WordA#I}
	    end
	 end
	 WordAs = {Map WordAITups
		   fun {$ WordA#_} WordA end}
	 {CheckWords WordAs}
%	 {Inspector.inspect 'InspectLexicalEntries'#WordAs}
	 OldInputAs = GlobalDict.inputAs
	 G = if {All WordAs
		 fun {$ WordA} {Member WordA OldInputAs} end} then
		{GetGrammar OldInputAs}
	     else
		{GetGrammar WordAs}
	     end
	 {CheckG G}
	 CheckAsInEntries = G.checkAsInEntries
	 {CheckAsInEntries WordAs}
	 %%
	 As2AEntriesRec = G.as2AEntriesRec
	 UsedDIDAs = {GetUsedDIDAs}
	 DIDA2EntryLat = G.dIDA2EntryLat
	 %%
	 AEntriesRec = {As2AEntriesRec WordAs}
      in
	 for A#I in WordAITups do
	    Entries = AEntriesRec.A
	    IEntryTups = if I==0 then
			    {ListMapInd Entries
			     fun {$ I Entry} I#Entry end}
			 else
			    if I<1 orelse I>{Length Entries} then
			       I1 = {Length Entries}
			    in
			       raise error1('functor':'xdk.ozf' 'proc':'InspectLexicalEntries' msg:'Could not select lexical entry '#I#' for '#A#', '#A#' has '#I1#' entries.' info:o(Entries) coord:noCoord file:noFile) end
			    end
			    [I#{Nth Entries I}]
			 end
	    EntryOLs =
	    {FoldL IEntryTups
	     fun {$ AccEntryOLs I#Entry}
		DIDAOLTups =
		{Map UsedDIDAs
		 fun {$ DIDA}
		    SL = Entry.DIDA
		    EntryLat = {DIDA2EntryLat DIDA}
		    OL = {EntryLat.pretty SL true}
		 in
		    DIDA#OL
		 end}
		DIDAOLRec = {ListToRecord o DIDAOLTups}
		%%
		DIDAOLRecs =
		{Map AccEntryOLs
		 fun {$ entry#_#DIDAOLRec} DIDAOLRec end}
		I1 = {Helpers.memberInd DIDAOLRec DIDAOLRecs}
		EntryOL =
		if I1==0 then
		   entry#I#DIDAOLRec
		else
		   A = {V2A '='#I1}
		in
		   entry#I#A
		end
	     in
		{Append AccEntryOLs [EntryOL]}
	     end nil}
	    I1 = {Length IEntryTups}
	 in
	    {Inspector.inspect word#A#entries#I1#EntryOLs}
	 end
      catch E then
	 {HandleException E}
      end
   end
     
   %% Solve: U -> U
   %% Solves the sentence currently in the SInputW widget.
   proc {Solve}
      try
	 WordAs#FileAs = {GetInput}
	 %%
	 {CheckWords WordAs}
	 %%
	 SolverProc = {MakeSolverScript WordAs FileAs}
	 SearchProc = {GetSearchProc}
      in
	 {SearchProc SolverProc}
      catch E then
	 {HandleException E}
      end
   end
   
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MetaExplorer
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Explorer
   proc {ExplorerIA}
      {ExplorerFunctor.object delete(information all)}
      %%
      Proc = proc {$ I Nodes}
		try
		   Proc1 = GlobalDict.openOutputsProc
		in
		   {Proc1 I Nodes}
		catch E then
		   {HandleException E}
		end
	     end
      %%
      ProfileB = {ProfileTkvar tkReturnInt($)}==1
   in
      if ProfileB then
	 {ExplorerFunctor.object add(information
				     proc {$ _ _}
					{Inspector.inspect {Solver.getProfile}}
				     end
				     label:'Profile')}
      end
      {ExplorerFunctor.object add(information Proc label:'Outputs')}
   end
   %%
   proc {ExplorerOne Proc}
      {ExplorerFunctor.object option(search search:5 information:25 failed:true)}
      %%
      {ExplorerFunctor.object one(Proc)}
      {ExplorerIA}
   end
   %%
   proc {ExplorerAll Proc}
      {ExplorerFunctor.object option(search search:5 information:25 failed:true)}
      %%
      {ExplorerFunctor.object all(Proc)}
      {ExplorerIA}
   end
   %%
   proc {ExplorerClose}
      {ExplorerFunctor.object close}
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IOzSeF
   proc {IOzSeFIA}
      {IOzSeFFunctor.deleteInformationAction 'Outputs'}
      %%
      Proc = proc {$ Nodes}
		try
		   Proc1 = GlobalDict.openOutputsProc
		in
		   {Proc1 1 Nodes}
		catch E then
		   {HandleException E}
		end
	     end
   in
      {IOzSeFFunctor.addInformationAction 'Outputs' root Proc}
   end
   %%
   proc {IOzSeFOne Proc}
      {IOzSeFFunctor.setOption recompStrat fixed}
      {IOzSeFFunctor.setOption mrd 5}
      %%
      {IOzSeFFunctor.exploreOne Proc}
      {IOzSeFIA}
   end
   %%
   proc {IOzSeFAll Proc}
      {IOzSeFFunctor.setOption recompStrat fixed}
      {IOzSeFFunctor.setOption mrd 5}
      %%
      {IOzSeFFunctor.explore Proc}
      {IOzSeFIA}
   end
   %%
   proc {IOzSeFClose}
      %% do not access IOzSeFFunctor if not necessary (IOzSeF is
      %% optional, the GUI shall run happily without it)
      if {IsDet IOzSeFFunctor} then
	 {IOzSeFFunctor.close}
      end
   end

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Oracle
   
   %% NewOracleO: U -> OracleO
   fun {NewOracleO}
      OracleO = {New OracleFunctor.oracle init}
      {OracleO setLoggingLevel(0)}
      PortI = GlobalDict.portI
   in
      {OracleO connect("localhost" PortI)}
      GlobalDict.oracleO := OracleO
      GlobalDict.connectedPortI := PortI
      OracleO
   end
   %% GetOracleO: U -> OracleO
   fun {GetOracleO}
      OldOracleO = GlobalDict.oracleO
   in
      if OldOracleO==unit then
	 {NewOracleO}
      else
	 if GlobalDict.portI==GlobalDict.connectedPortI then
	    OldOracleO
	 else
	    {OldOracleO close}
	    {NewOracleO}
	 end
      end
   end
   %%
   proc {OracleOne Proc}
      %% Get oracle object
      OracleO = {GetOracleO}
      %% Set externalizer
      WordAs = {GetWords}
%      {Inspector.inspect 'OracleOne'#WordAs}
      G = {GetGrammar WordAs}
      ExternaliserO = {New XDGExternaliserFunctor.externaliser init(G)}
   in
      {ExternaliserO setLoggingLevel(0)}
      {OracleO setExternaliser(ExternaliserO)}
      %%
      {IOzSeFFunctor.setOption recompStrat fixed}
      {IOzSeFFunctor.setOption mrd 5}
      %%
      {IOzSeFFunctor.exploreOracleOne Proc OracleO}
      %%
      {IOzSeFIA}
   end
   %%
   OracleAll = OracleOne
   %%
   OracleClose = IOzSeFClose
   
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MetaExplorer

   proc {MetaExplorerOne Proc}
      ExplorerA = {ExplorerTkvar tkReturnAtom($)}
   in
      case ExplorerA
      of explorer then {ExplorerOne Proc}
      [] iozsef then {IOzSeFOne Proc}
      else {OracleOne Proc}
      end
   end
   %%
   proc {MetaExplorerAll Proc}
      ExplorerA = {ExplorerTkvar tkReturnAtom($)}
   in
      case ExplorerA
      of explorer then {ExplorerAll Proc}
      [] iozsef then {IOzSeFAll Proc}
      else {OracleAll Proc}
      end
   end
   %%
   proc {MetaExplorerClose}
      {ExplorerClose}
      {IOzSeFClose}
      {OracleClose}
   end
   
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Main
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% get commandline args
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)                  
	   
	   grammars(single type:list(string) char:&g default:nil)
	   examples(single type:string char:&e default:unit)
	   
	   input(single type:string char:&i default:unit)

	   mode(single type:atom(parse generate) char:&m default:parse)
	   profile(single type:bool char:&f default:false)
	   memoize(single type:CPKit.optionDef default:CPKit.options.1)
	   lazyvars(single type:bool default:true)
	   search(single type:atom(all first print flatzinc) char:&s default:all)
	   explorer(single type:atom(explorer iozsef oracle) char:&x default:explorer)
	   port(single type:int char:&p default:4711)
	   print(single type:atom(inspect browse stdout file) char:&n default:inspect)
	   solutions(single type:int char:&u default:9999)
	   failures(single type:int char:&a default:9999)
	   timeout(single type:int char:&t default:3600)
	   reco(single type:int char:&c default:5)
	   outputs(single type:bool char:&o default:false)
	   
	   builddeffile(single type:bool char:&b default:true)
	   ozeditor(single type:string default:"oz")
	   uleditor(single type:string default:"emacs")
	   xmleditor(single type:string default:"emacs")
	   optimize(single type:bool default:true)
	   'allow-seon'(single type:bool default:false)
	   adhoc(single type:bool default:true)
	   
	   log(single type:atom(inspect browse stdout) char:&l default:inspect)
	   reload(single type:bool char:&r default:true)
	   
	   debug(single type:bool char:&d default:false)
	  )}
   %% help
   if AArgRec.help then
      {System.showError
       '*XDG Development Kit (XDK): Graphical user interface*\n\n'#
       '--(no)help                         display this help\n'#
       ' -h\n'#
       '--grammars <File1,...,FileN>       select grammar files\n'#
       ' -g                                (e.g. -g Acl01.ul,Acl01-2.ul\n'#
       '                                    default: no files)\n'#
       '--examples <File>                  select examples file\n'#
       ' -e                                (e.g. --examples Acl01.txt\n'#
       '                                    default: grammar file with suffix "txt")\n'#
       '--input                            provide input\n'#
       ' -i                                (e.g. --input "peter maria liebt"\n'#
       '                                    default: "")\n'#
       '--mode parse|generate              parse or generate\n'#
       ' -m                                (e.g. --mode generate\n'#
       '                                    default: parse)\n'#
       '--(no)profile                      toggle dyn profiling\n'#
       ' -f                                (default: noprofile)\n'#
       '--memoize '#CPKit.optionsStr#'\n'#
       '                                   toggle PW memoization\n'#
       '                                   (default: '#CPKit.options.1#')\n'#
       '--(no)lazyvars                     make PW auto vars lazy\n'#
       '                                   (default: lazyvars)\n'#
       '--search first|all|print|flatzinc  search for first solutions or all\n'#
       '                                   or print or print FlatZinc\n'#
       ' -s                                (e.g. --search all\n'#
       '                                    default: all)\n'#
       '--explorer explorer|iozsef|oracle  use Explorer or IOzSeF or oracle\n'#
       '                                   for search visualization\n'#
       ' -x                                (e.g. --explorer explorer\n'#
       '                                    default: explorer)\n'#
       '--port <Int>                       set oracle port\n'#
       ' -p                                (e.g. --port 42\n'#
       '                                    default 4711)\n'#
       '--print inspect|browse|stdout|file specify print procedure for outputs\n'#
       ' -n                                (e.g. --print inspect\n'#
       '                                    default: inspect)\n'#
       '--solutions <Int>                  set maximum number of solutions to <Int>\n'#
       ' -u                                (solving statistics)\n'#
       '                                   (e.g. --solutions 4711\n'#
       '                                    default: 9999)\n'#
       '--failures <Int>                   set maximum number of failures to <Int>\n'#
       ' -a                                (solving statistics)\n'#
       '                                   (e.g. --failures 4711\n'#
       '                                    default: 9999)\n'#
       '--timeout <Int>                    set timeout (in seconds)\n'#
       ' -t                                (solving statistics)\n'#
       '                                   (e.g. --timeout 4711\n'#
       '                                    default: 3600)\n'#
       '--reco <Int>                       set maximum recomputation distance to <Int>\n'#
       ' -c                                (solving statistics)\n'#
       '                                   (e.g. --reco 25\n'#
       '                                    default: 5)\n'#
       '--(no)outputs                      open all used outputs\n'#
       ' -o                                (solving statistics)\n'#
       '                                   (default: nooutputs)\n\n'#
       '--(no)builddeffile                 build principle definition or not\n'#
       ' -b                                (default: builddeffile)\n'#
       '--ozeditor <Command>               set Oz editor\n'#
       '                                   (e.g. --ozeditor notepad\n'#
       '                                    default oz)\n'#
       '--uleditor <Command>               set UL editor\n'#
       '                                   (e.g. --uleditor notepad\n'#
       '                                    default emacs)\n'#
       '--xmleditor <Command>              set XML editor\n'#
       '                                   (e.g. --xmleditor notepad\n'#
       '                                    default emacs)\n\n'#
       '--(no)optimize                     Principle Writer: optimize\n'#
       '                                   (default: optimize)\n'#
       '--(no)allow-seon                   Principle Writer: generate setExistsOneNodes\n'#
       '                                   (default: noallow-seon)\n'#
       '--(no)adhoc                        Principle Writer: apply adhoc transforms\n'#
       '                                   (default: adhoc)\n\n'#
       '--log inspect|browse|stdout        specify log procedure\n'#
       ' -l                                (e.g. --log browse\n'#
       '                                   default: inspect)\n\n'#
       '--(no)reload                       Add/Remove/Build in Principle Manager\n'#
       ' -r                                triggers grammar reload\n'#
       '                                   (default: reload)\n\n'#
       '--(no)debug                        toggle debug mode\n'#
       ' -d                                (default: nodebug)'
      }
      {Application.exit 1}
   end
   %% grammars
   GSs = AArgRec.grammars
   %% examples
   ES = AArgRec.examples
   %% input
   InputS = AArgRec.input
   %% mode
   ModeA = AArgRec.mode
   %% profile
   ProfileB = AArgRec.profile
   %% Memoize
   MemoizeA = AArgRec.memoize
   %% Lazyvars
   LazyvarsB = AArgRec.lazyvars
   %% search
   SearchA = AArgRec.search
   %% explorer
   ExplorerA = AArgRec.explorer
   %% port
   GlobalDict.portI := AArgRec.port
   %% print
   PrintA = AArgRec.print
   %% solutions
   GlobalDict.solutionsI := AArgRec.solutions
   %% failures
   GlobalDict.failuresI := AArgRec.failures
   %% timeout
   GlobalDict.timeoutI := AArgRec.timeout
   %% reco
   GlobalDict.recoI := AArgRec.reco
   %% outputs
   OutputsB = AArgRec.outputs
   %%
   %% builddeffile
   BuildDefFileB = AArgRec.builddeffile
   %% ozeditor
   OzEditorS = AArgRec.ozeditor
   %% uleditor
   ULEditorS = AArgRec.uleditor
   %% xmleditor
   XMLEditorS = AArgRec.xmleditor
   %% pwoptimize
   PWOptimizeB = AArgRec.optimize
   %% pwseon
   PWSeonB = AArgRec.'allow-seon'
   %% pwadhoc
   PWAdhocB = AArgRec.adhoc
   %% log
   LogA = AArgRec.log
   %% reload
   ReloadB = AArgRec.reload
   %% debug
   DebugB = AArgRec.debug
   %% create status variable
   Status
   %% create (and open) main window
   TopW = {New Tk.toplevel tkInit(title: 'XDK: Main window'
				  delete: proc {$} {Application.exit 0} end)}
   %% create Tk-variables
   ModeTkvar = {New Tk.variable tkInit(ModeA)}
   %%
   ProfileTkvar = {New Tk.variable tkInit(ProfileB)}
   %%
   MemoizeTkvar = {New Tk.variable tkInit(MemoizeA)}
   %%
   LazyvarsTkvar = {New Tk.variable tkInit(LazyvarsB)}
   %%
   SearchTkvar = {New Tk.variable tkInit(SearchA)}
   %%
   ExplorerTkvar = {New Tk.variable tkInit(ExplorerA)}
   %%
   PrintTkvar = {New Tk.variable tkInit(PrintA)}
   %%
   OutputsTkvar = {New Tk.variable tkInit(OutputsB)}
   %%
   ReloadTkvar = {New Tk.variable tkInit(ReloadB)}
   %%
   DebugTkvar = {New Tk.variable tkInit(DebugB)}
   %% create pulldown-menu
   %% consumed shortcuts: c, d, f, g, l, n, o, p, q, r, s, t, u, w, x
   %% string editing shortcuts: a, e, k, v
   MenuEntries =
   [menubutton(text: 'Project'
	       menu:
		[
		 command(label: 'About...'
			 action: About)
		 separator
		 command(label: 'Open grammar files...'
			 action: OpenGrammars
			 key: ctrl(o))
		 command(label: 'Open grammar file/socket...'
			 action: OpenGrammarSocket
			 key: ctrl(t))
		 command(label: 'Reload grammar file(s)'
			 action: ReloadGrammars
			 key: ctrl(r))
		 command(label: 'Save compiled grammar file...'
			 action: SaveCompiledGrammar
			 key: ctrl(s))
		 separator
		 command(label: 'Convert grammar/nodeset file...'
			 action: ConvertGrammar)
		 separator
		 command(label: 'Open examples file...'
			 action: OpenExamples)
		 command(label: 'Reload examples file'
			 action: ReloadExamples
			 key: ctrl(x))
		 separator
		 command(label: 'Close output windows'
			 action: CloseOutputWindows
			 key: ctrl(w))
		 separator
		 command(label: 'Quit'
			 action: Quit
			 key: ctrl(q))
		])
    menubutton(text: 'Search'
	       menu:
                [
		 radiobutton(label: 'Parse'
			     var: ModeTkvar
			     val: parse)
		 radiobutton(label: 'Generate'
			     var: ModeTkvar
			     val: generate)
		 separator
		 checkbutton(label: 'Profile'
			     var: ProfileTkvar)
		 cascade(label: 'Memoize'
			 menu:{Map CPKit.kits
			       fun {$ Kit}
				  radiobutton(label: Kit.abstract
					      var: MemoizeTkvar
					      val: Kit.option)
			       end})
		 checkbutton(label: 'Lazyvars'
			     var: LazyvarsTkvar)
		 separator
		 radiobutton(label: 'IOzSeF'
			     var: ExplorerTkvar
			     val: iozsef)
		 radiobutton(label: 'Oracle'
			     var: ExplorerTkvar
			     val: oracle)
		 separator
		 radiobutton(label: 'First solution'
			     var: SearchTkvar
			     val: first)
		 radiobutton(label: 'All solutions'
			     var: SearchTkvar
			     val: all)
		 radiobutton(label: 'Print CSP'
			     var: SearchTkvar
			     val: print)
		 radiobutton(label: 'Print FlatZinc'
			     var: SearchTkvar
			     val: flatzinc)
		 separator
		 radiobutton(label: 'Explorer'
			     var: ExplorerTkvar
			     val: explorer)
		 radiobutton(label: 'IOzSeF'
			     var: ExplorerTkvar
			     val: iozsef)
		 radiobutton(label: 'Oracle'
			     var: ExplorerTkvar
			     val: oracle)
		 separator
		 command(label: 'Set oracle port...'
			 action: SetOraclePort)
		])
    menubutton(text: 'Dimensions'
	       menu: nil
	       feature: dimensions)
    menubutton(text: 'Principles'
	       menu: nil
	       feature: principles)
    menubutton(text: 'Outputs'
	       menu: nil
	       feature: outputs)
    menubutton(text: 'Managers'
	       menu: [
		      command(label: 'Open Principle Manager...'
			      action: OpenPrincipleManager
			      key: ctrl(p))
% 		      command(label: 'Open Output Manager...'
% 			      action: OpenOutputManager
% 			      key: ctrl(u))
		      separator
		      checkbutton(label: 'Add/Remove/Build triggers grammar reload'
				  var: ReloadTkvar)
		     ])
    menubutton(text: 'Extras'
	       menu: [cascade(label: 'Print'
			      menu: [radiobutton(label: 'inspect'
						 var: PrintTkvar
						 val: inspect
						 action: UpdateOutputs)
				     radiobutton(label: 'browse'
						 var: PrintTkvar
						 val: browse
						 action: UpdateOutputs)
				     radiobutton(label: 'stdout'
						 var: PrintTkvar
						 val: stdout
						 action: UpdateOutputs)
				     radiobutton(label: 'file'
						 var: PrintTkvar
						 val: file
						 action: UpdateOutputs)])
		      separator
		      cascade(label: 'Compare lem solutions'
			      menu: [command(label: 'No filter'
					     action: CompareLemSolutionsNoFilter
					     key: ctrl(n))
				     command(label: 'Simple filter'
					     action: CompareLemSolutionsSimpleFilter
					     key: ctrl(f))
				     command(label: 'Tagger filter'
					     action: CompareLemSolutionsTaggerFilter
					     key: ctrl(c))])
		      separator
		      command(label: 'Generate orderings...'
			      action: GenerateOrderings1
			      key: ctrl(g))
		      separator
		      command(label: 'Solve examples'
			      action: SolveExamples
			      key: ctrl(l))
		      separator
		      cascade(label: 'Solving Statistics'
			      menu: [command(label: 'Save Solving Statistics...'
					     action: SaveSolvingStatistics)
				     separator
				     command(label: 'Set number of solutions...'
					     action: SetSolutions)
				     command(label: 'Set number of failures...'
					     action: SetFailures)
				     command(label: 'Set timeout (in seconds)...'
					     action: SetTimeout)
				     command(label: 'Set recomputation distance...'
					     action: SetReco)
				     checkbutton(label: 'Open outputs'
						 var: OutputsTkvar)])
		      separator
		      checkbutton(label: 'Debug mode'
				  var: DebugTkvar
				  key: ctrl(d))
		     ])]
   MenuW = {TkTools.menubar TopW TopW MenuEntries nil}
   %% create sentence list widget
   EListFrameW = {New Tk.frame tkInit(parent: TopW)}
   EListW = {New Tk.listbox tkInit(parent: EListFrameW
				   width: 70
				   height: 30
				   background: white)}
   {EListW tkBind(event:  '<1>' %% single click (LMB)
		  action: proc {$}
			     S = {EListW tkReturn(size $)}
			  in
			     if {Not S=="0"} then
				S1 = {EListW tkReturn(curselection $)}
				S2 = {EListW tkReturn(get(S1) $)}
			     in
				{SInputW tk(delete 0 'end')}
				{SInputW tk(insert 'end' S2)}
			     end
			  end)}
   {EListW tkBind(event:  '<Double-1>' %% double click (LMB)
		  action: proc {$}
			     S = {EListW tkReturn(size $)}
			  in
			     if {Not S=="0"} then
				S1 = {EListW tkReturn(curselection $)}
				S2 = {EListW tkReturn(get(S1) $)}
			     in
				{SInputW tk(delete 0 'end')}
				{SInputW tk(insert 'end' S2)}
				{Solve}
			     end
			  end)}
   EListScrollW = {New Tk.scrollbar tkInit(parent: EListFrameW)}
   {Tk.addYScrollbar EListW EListScrollW}
   %% create sentence input widget
   SInputFrameW = {New Tk.frame tkInit(parent: TopW)}
   SInputW = {New Tk.entry tkInit(parent: SInputFrameW
				  background: white)}
   if {Not InputS==unit} then {SInputW tk(insert 'end' InputS)} end
   {SInputW tkBind(event:'<Return>' action: Solve)}
   SInputButtonW = {New Tk.button tkInit(parent: SInputFrameW
					 text: 'Solve'
					 action: Solve)}
   %% create lexicon entry input widget
   LInputFrameW = {New Tk.frame tkInit(parent: TopW)}
   LInputW = {New Tk.entry tkInit(parent: LInputFrameW
				  background: white)}
   {LInputW tkBind(event: '<Return>'
		   action: InspectLexicalEntries)}
   LInputButtonW = {New Tk.button tkInit(parent: LInputFrameW
					 text: 'Inspect lexical entries'
					 action: InspectLexicalEntries)}
   %% create grammar status widget
   GStatusFrameW = {New Tk.frame tkInit(parent: TopW)}
   GStatusW = {New Tk.label tkInit(parent: GStatusFrameW)}
   %% create examples status widget
   EStatusFrameW = {New Tk.frame tkInit(parent: TopW)}
   EStatusW = {New Tk.label tkInit(parent: EStatusFrameW)}
   %% new grammar
   {ResetGrammar}
   if {Not GSs==nil} then
      {SetGrammar GSs nil}
   end
   %% new examples
   {ResetExamples}
   if ES==unit then
      if {Not GSs==nil} then
	 S1 = GSs.1
	 S2 = {Helpers.changeSuffix S1 "txt"}
      in
	 {SetExamples S2}
      end
   else
      {SetExamples ES}
   end
   %%
   {Tk.batch [
	      grid(columnconfigure TopW 0 weight:1)
	      grid(rowconfigure TopW 4 weight:1)

	      grid(MenuW row:0 sticky:nw)
	      
	      grid(GStatusFrameW row:1 sticky:nw)
	      grid(GStatusW)

	      grid(EStatusFrameW row:2 sticky:nw)
	      grid(EStatusW)

	      grid(LInputFrameW row:3 sticky:we)
	      grid(columnconfigure LInputFrameW 1 weight:1)
	      grid(rowconfigure LInputFrameW 0 weight:1)
	      grid(LInputButtonW row:0 column:0 sticky:w)
	      grid(LInputW row:0 column:1 sticky:we)

	      grid(EListFrameW row:4 sticky:nswe)
	      grid(columnconfigure EListFrameW 0 weight:1)
	      grid(rowconfigure EListFrameW 0 weight:1)
	      grid(EListW row:0 sticky:nswe)
	      grid(EListScrollW row:0 column:1 sticky:ns)

	      grid(SInputFrameW row:5 sticky:we)
	      grid(columnconfigure SInputFrameW 1 weight:1)
	      grid(rowconfigure SInputFrameW 0 weight:1)
	      grid(SInputButtonW row:0 column:0 sticky:w)
	      grid(SInputW row:0 column:1 sticky:we)

	      focus(SInputW)
	     ]}
   %%
   if {Not InputS==unit} then {Solve} end
   %%
   {Application.exit Status}
end
