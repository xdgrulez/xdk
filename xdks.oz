%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
   
   Application(exit getArgs)
   Search(base)
   System(showError showInfo printInfo show)
   
   Helpers(addHandlers x2V e2V vs2S vs2A segment getLines
	   getTime getSuffix changeSuffix) at 'Helpers.ozf'

   Module(link)
   
%   Principles(principles) at 'Solver/Principles/Principles.ozf'
   Outputs(outputs open) at 'Outputs/Outputs.ozf'
   Compiler(files2SLC) at 'Compiler/Compiler.ozf'
   NodesCompiler(partitionAs as2WordAs fileAs2Nodes) at 'Compiler/NodesCompiler.ozf'

   Solver(make getProfile) at 'Solver/Solver.ozf'
   
   SolvingStatistics(perform) at 'Extras/SolvingStatistics.ozf'
   CPKit(options kits optionDef optionsStr) at 'Solver/Principles/Lib/CPKit.hub.ozf'
prepare
   ListLast = List.last
define
   {Helpers.addHandlers}
   %%
   [PrinciplesFunctor] = {Module.link ['Solver/Principles/Principles.ozf']}
   %%
   S2A = String.toAtom
   %%
   V2A = VirtualString.toAtom
   %%
   GlobalDict = {NewDictionary}
   GlobalDict.inputAs := nil
   GlobalDict.g := unit
   %%
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)                  
	   
	   grammars(single type:list(string) char:&g default:nil)
	   examples(single type:string char:&e default:unit)

	   input(single type:string char:&i default:unit)

	   mode(single type:string char:&m default:"parse")
	   profile(single type:bool char:&f default:false)
	   memoize(single type:CPKit.optionDef default:CPKit.options.1)
	   lazyvars(single type:bool default:true)
	   search(single type:string char:&s default:"all")

	   solutions(single type:int char:&u default:99999)
	   failures(single type:int char:&a default:99999)
	   timeout(single type:int char:&t default:3600)
	   reco(single type:int char:&c default:5)
	   outputs(single type:bool char:&o default:false)
	   
	   debug(single type:bool char:&d default:false)
	  )}
   %% help
   if AArgRec.help then
      {System.showError
       '*XDG Development Kit (XDK): Solver*\n'#
       '--(no)help                         display this help\n'#
       ' -h\n'#
       '--grammars <File1,...,FileN>       select grammar files\n'#
       ' -g                                (e.g. -g Acl01.ul,Acl01-2.ul\n'#
       '                                    default: no files)\n'#
       '--examples <File>                  select examples file\n'#
       ' -e                                (e.g. --examples Acl01.txt\n'#
       '                                    default: "")\n'#
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
       '--search first|all|print|flatzinc  search for first solutions or all,\n'#
       '                                   or print or print FlatZinc\n'#
       ' -s                                (e.g. --search all\n'#
       '                                    default: all)\n'#
       '--solutions <Int>                  set maximum number of solutions to <Int>\n'#
       ' -u                                (e.g. --solutions 4711\n'#
       '                                    default: 99999)\n'#
       '--failures <Int>                   set maximum number of failures to <Int>\n'#
       ' -a                                (solving statistics)\n'#
       '                                   (e.g. --failures 4711\n'#
       '                                    default: 99999)\n'#
       '--timeout <Int>                    set timeout (in seconds)\n'#
       ' -t                                (solving statistics)\n'#
       '                                   (e.g. --timeout 4711\n'#
       '                                    default: 3600)\n'#
       '--reco <Int>                       set maximum recomputation distance to <Int>\n'#
       ' -c                                (e.g. --reco 25\n'#
       '                                    default: 5)\n'#
       '--(no)outputs                      open all used outputs\n'#
       ' -o                                (default: nooutputs)\n'#
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
   ModeS = AArgRec.mode
   ModeA =
   case ModeS
   of "generate" then generate
   else parse
   end
   %% profile
   ProfileB = AArgRec.profile
   %% Memoize
   MemoizeA = AArgRec.memoize
   %% Lazyvars
   LazyvarsB = AArgRec.lazyvars
   %% search
   SearchS = AArgRec.search
   SearchA =
   case SearchS
   of "first" then first
   [] "print" then print
   [] "flatzinc" then flatzinc
   else all
   end
   %% solutions
   SolutionsI =
   case SearchA
   of first then 1
   else AArgRec.solutions
   end
   %% failures
   FailuresI = AArgRec.failures
   %% timeout
   TimeoutI = AArgRec.timeout
   %% reco
   RecoI = AArgRec.reco
   %% outputs
   OutputsB = AArgRec.outputs
   %% debug
   DebugB = AArgRec.debug
   %%
   if GSs==nil then
      {System.showError 'No grammar.'}
      {Application.exit 1}
   end
   %%
   try
      fun {GetGrammar InputAs}
	 OldG = GlobalDict.g
	 OldInputAs = GlobalDict.inputAs
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
	    InputA = {V2A
		      {FoldL InputAs
		       fun {$ AccA InputA}
			  AccA#InputA#' '
		       end ''}}
	    MetaX = InputA
	    G = {Compiler.files2SLC GSs MetaX PrincipleILs OutputILs DebugB System.showError}
	    GlobalDict.g := G
	 in
	    G
	 else
	    OldG
	 end
      in
	 G
      end
      %%
      ES1 = if ES==unit then
	       GS = {ListLast GSs}
	    in
	       {Helpers.changeSuffix GS "txt"}
	    else
	       ES
	    end
      %%
      Ss =
      if InputS==unit then
	 Ss1 = {Helpers.getLines ES1}
      in
	 if Ss1==nil then
	    {System.showError 'No input and could not read examples from file '#ES1#'.'}
	    {Application.exit 1}
	 end
	 Ss1
      else
	 [InputS]
      end
      %%
      PrincipleILs = PrinciplesFunctor.principles
      OutputILs = Outputs.outputs
      %% prepare solving statistics
      ExampleAs = {Map Ss
		   fun {$ S} {S2A S} end}
      %%
      SegmentProc = Helpers.segment
      %%
      MakeSolverScriptProc =
      fun {$ WordAs FileAs EI}
	 G = {GetGrammar WordAs}
	 %%
	 I = {Length WordAs}
	 WordA = {V2A
		  {FoldL WordAs
		   fun {$ AccA WordA}
		      AccA#WordA#' '
		   end ''}}
	 MetaX = WordA
	 Nodes = {NodesCompiler.fileAs2Nodes FileAs I G MetaX DebugB System.showError}
	 %%
	 UrlV = case SearchA
		of print then {Helpers.changeSuffix GSs.1 'csp'#EI}
		[] flatzinc then {Helpers.changeSuffix GSs.1 'fzn'#EI}
		else ""
		end
	 %%
	 Options = o(debug: DebugB
		     lazyvars: LazyvarsB
		     memoize: MemoizeA
		     mode: ModeA
		     profile: ProfileB
		     search: SearchA#UrlV)
      in
	 {{Solver.make G Options PrinciplesFunctor} WordAs Nodes}
      end
      %%
      PartitionAs = NodesCompiler.partitionAs
      %%
      PrintProc = System.printInfo
      %%
      GetOpenOutputsProc = 
      if OutputsB then
	 fun {$ WordAs}
	    G = {GetGrammar WordAs}
	    OpenProc = {Outputs.open G PrintProc}
	 in
	    OpenProc
	 end
      else
	 fun {$ _}
	    proc {$ _ _} skip end
	 end
      end
      %%
      SolvingStartProc = System.showError
      %%
      SolvingEndProc = System.showError
      %%
      GetProfileProc = Solver.getProfile
      %%
      GetAs2AEntriesRecProc = fun {$ WordAs}
				 G = {GetGrammar WordAs}
			      in
				 G.as2AEntriesRec
			      end
      %%
      GrammarPathV = {Helpers.vs2S GSs}
      %%
      ExamplesPathV = if InputS==unit then
			 ES1
		      else
			 '(input)'
		      end
      %%
      DateV = {Helpers.getTime}
      %%
      GetUsedDIDAs =
      fun {$ WordAs}
	 G = {GetGrammar WordAs}
      in
	 G.usedDIDAs
      end
      %%
      GetUsedPrinciples =
      fun {$ WordAs}
	 G = {GetGrammar WordAs}
	 UsedPns = G.usedPns
	 PnPrincipleRec = G.pnPrincipleRec
      in
	 {Map UsedPns
	  fun {$ Pn} PnPrincipleRec.Pn end}
      end
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
	      getUsedDIDAs: GetUsedDIDAs
	      getUsedPrinciples: GetUsedPrinciples
	      searchA: SearchA
	      debug: DebugB)
   in
      {SolvingStatistics.perform Rec}
   catch E then
      V = {Helpers.e2V E}
   in
      {System.showError '\n'#V}
      if DebugB orelse V=='unhandled error' then {System.show E} end
   end
in
   {Application.exit 0}
end
