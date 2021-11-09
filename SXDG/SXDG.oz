%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:24 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

%% TODO: factor the code into two applications: batch and visual

functor
import
   Application Inspector Open System URL

   Compiler at 'x-ozlib://debusmann/xdg/Compiler/Compiler.ozf'
   Outputs at 'x-ozlib://debusmann/xdg/Outputs/Outputs.ozf'
   Parser at 'x-ozlib://debusmann/xdg/Parser/Parser.ozf'
   Principles at 'x-ozlib://debusmann/xdg/Parser/Principles/Principles.ozf'

   IOzSEF at 'x-ozlib://tack/iozsef/iozsef.ozf'

   BruteForceSearch at 'BruteForceSearch.ozf'
   Helpers at 'Helpers.ozf'
   Log at 'Log.ozf'
   Oracle at 'GlobalOracle.ozf'
   SXDGGrammarServer at 'SXDGGrammarServer.ozf'
   SXDGExternaliser at 'SXDGExternaliser.ozf'
define

   proc {UnsupportedURL U C}
      S = {URL.toVirtualString U}
   in
      {System.showError "Unsupported URL '"#S#"' for "#C}
      {Application.exit 1}
   end

   %% get the arguments
   Options =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   grammar(single type:string char:&g default:"tcp://localhost:1975/")
	   input(single type:string char:&i default:unit)
	   log(single type:bool char:&l default:false)
	   oracle(single type:string char:&o default:"tcp://localhost:4210/")
	   strategy(single type:string char:&s default:"oracle")
	   timeout(single type:int char:&t default:180)
	   visual(single type:bool char:&v default:false)
	  )}

   %% show help message
   if Options.help then
      {System.showError
       'SXDG Parser System                                               \n'#
       'Copyright (C) 2004 Peter Dienes, Alexander Koller, Marco Kuhlmann\n'#
       '                                                                 \n'#
       '  -h, --help           display this help                         \n'#
       '                                                                 \n'#
       '  -g, --grammar=URL   use grammar at URL                         \n'#
       '  -i, --input=URL     use input data at URL                      \n'#
       '  -l, --(no)log       enable logging                             \n'#
       '  -o, --oracle=URL    use oracle at URL                          \n'#
       '  -s, --strategy=S    set search strategy (all, one, oracle)     \n'#
       '  -t, --timeout=N     set timeout for parses (in seconds)        \n'#
       '  -v, --visual        use visualisation                          '
      }
      {Application.exit 1}
   end

   %% ----------------------------------------------------------------
   %% Grammar
   %% ----------------------------------------------------------------

   if Options.grammar == unit then
      {System.showError "No grammar given."}
      {Application.exit 1}
   end
   
   GrammarURL = {URL.make Options.grammar}

   %% ----------------------------------------------------------------
   %% Oracle
   %% ----------------------------------------------------------------

   if Options.strategy == "oracle" andthen Options.oracle == unit then
      {System.showError "No oracle given."}
      {Application.exit 1}
   end
   
   OracleURL = {URL.make Options.oracle}

   %% ----------------------------------------------------------------
   %% Read the input to the parser
   %% ----------------------------------------------------------------

   if Options.input == unit then
      {System.showError "No input given."}
      {Application.exit 1}
   end

   InputURL = {URL.make Options.input}
   
   Sentences

   case InputURL.scheme
   of "file" then
      FileName =
      {Helpers.string.concatWith "/" {URL.normalizePath InputURL.path}}
   in
      try
	 Sentences =
	 {List.map {Helpers.file.getLines FileName} Helpers.removePunctuation}
      catch fileDoesNotExist then
	 {System.showError "Input file does not exist: "#FileName}
	 {Application.exit 1}
      end
   else
      {UnsupportedURL InputURL "input data"}
   end
   
   %% ----------------------------------------------------------------
   %% SXDG class
   %% ----------------------------------------------------------------

   LogPrefix = "SXDG"
   LoggingLevel = if Options.log then 0 else 3 end

   class SXDG from Log.logged
      attr
	 grammarURL
	 useGrammarServer
	 grammarServerHost grammarServerPort grammarServerO
	 grammarFile
	 grammar
	 oracleURL
	 useOracle
	 oracleHost oraclePort oracleO
	 externaliserO
	 
      meth init(GrammarURL OracleURL LoggingLevel)
	 Log.logged,init
	 {self log(LogPrefix "initialisation")}

	 loggingLevel <- LoggingLevel
	 grammarURL <- GrammarURL
	 oracleURL <- OracleURL
	 
	 {self initGrammarServer}
	 {self initOracle}
      end

      %% grammar server
      meth initGrammarServer
	 case @grammarURL.scheme
	 of "tcp" then
	    [Host PortString] = {String.tokens @grammarURL.authority &:}
	    Port = {String.toInt PortString}
	 in
	    useGrammarServer <- true
	    grammarServerHost <- Host
	    grammarServerPort <- Port
	    grammarServerO <- {New SXDGGrammarServer.grammarServer init}
	    {self log(LogPrefix "using grammar server: "#Host#" @ "#Port)}
	    {@grammarServerO setLoggingLevel(@loggingLevel)}
	 [] "file" then
	    GrammarFile =
	    {Helpers.string.concatWith "/" {URL.normalizePath @grammarURL.path}}
	 in	    
	    useGrammarServer <- false
	    {self log(LogPrefix "compiling the grammar at "#GrammarFile)}
	    grammar <-
	    {Compiler.files2PLC [GrammarFile]
	     Principles.principles Outputs.outputs 'record' false}
	    {self log(LogPrefix "finished compiling the grammar")}
	 end
      end

      %% oracle
      meth initOracle
	 case @oracleURL
	 of unit then
	    useOracle <- false
	 else
	    useOracle <- true
	    case @oracleURL.scheme
	    of "tcp" then
	       [Host PortString] = {String.tokens @oracleURL.authority &:}
	       Port = {String.toInt PortString}
	    in
	       oracleHost <- Host
	       oraclePort <- Port
	       oracleO <- {New Oracle.oracle init}
	       {@oracleO setLoggingLevel(@loggingLevel)}
	       {self log(LogPrefix "using oracle: "#Host#" @ "#Port)}
	    end
	 end
      end

      %% externaliser
      meth createExternaliser
	 {self log(LogPrefix "creating the externaliser")}
	 externaliserO <- {New SXDGExternaliser.externaliser init(@grammar)}
	 {@externaliserO setLoggingLevel(@loggingLevel)}
	 if @useOracle then {@oracleO setExternaliser(@externaliserO)} end
	 {self log(LogPrefix "finished creating the externaliser")}
      end
      
      meth connect
	 %% grammar server
	 if @useGrammarServer then
	    {self log(LogPrefix "connecting to the grammar server")}
	    {@grammarServerO connect(@grammarServerHost @grammarServerPort)}
	    {self log(LogPrefix "connection established")}
	 end

	 %% oracle
	 if @useOracle then
	    {self log(LogPrefix "connecting to the oracle")}
	    {@oracleO connect(@oracleHost @oraclePort)}
	    {self log(LogPrefix "connection established")}
	 end

	 if {Not @useGrammarServer} then {self createExternaliser} end
      end

      meth parse(Id Words $)
	 Sentence = {Helpers.string.concatWith " " Words}
	 {self log(LogPrefix "next input sentence: "#Sentence)}

	 %% grammar
	 if @useGrammarServer then
	    GrammarString
	 in
	    {self log(LogPrefix "requesting a grammar from the grammar server")}
	    {@grammarServerO getGrammar(Words GrammarString)}
	    {self log(LogPrefix "requested grammar retrieved")}
	    {self log(LogPrefix "compiling the retrieved grammar")}
	    grammar <-
	    {Compiler.uLVS2PLC GrammarString
	     Principles.principles Outputs.outputs
	     '' 'record' false}
	    {self log(LogPrefix "finished compiling the grammar")}
	    {self createExternaliser}
	 end
      
	 %% search script
	 {self log(LogPrefix "creating the search script")}
	 Script = {Parser.make {Helpers.stripPOSTags Words} @grammar false}
	 {self log(LogPrefix "finished creating the search script")}

	 %% IOzSEF information action
	 ShowTree =
	 proc {$ Nodes}
	    %% TODO: display the Id of the node
	    {{Outputs.open @grammar Inspector.inspect} 1 Nodes}
	 end

	 %% IOzSEF popup action
	 ShowProb =
	 fun {$ Node}
	    {Helpers.string.pad
	     {@oracleO messageEvaluate({Node getId($)} $)} 5}
	 end

	 %% Register IOzSEF actions
	 proc {RegisterIOzSEFActions}
	    {IOzSEF.addInformationAction "Show tree" root ShowTree}
	    {IOzSEF.addPopUpAction "Show probability" node ShowProb}
	 end

	 %% return values from the search engine
	 Solutions Stats

	 SummaryElement = {New Helpers.xml.element init("summary")}
	 SolutionsElement = {New Helpers.xml.element init("solutions")}
	 StatisticsElement = {New Helpers.xml.element init("statistics")}

	 Time1 Time2

	 %% collect the statistics
	 proc {CollectStatistics}
	    for Key#Value in time#(Time2-Time1)|Stats do
	       KeyValueElement =
	       {New Helpers.xml.element init("key-value-pair")}
	    in
	       {KeyValueElement addAttribute("value" Value)}
	       {KeyValueElement addAttribute("key" Key)}
	       {StatisticsElement addChild(KeyValueElement)}
	    end
	    {SummaryElement addChild(StatisticsElement)}
	    {self log(LogPrefix "collected statistics")}
	 end
      in
	 {SummaryElement addAttribute("id" Id)}
	 
	 %% do the search
	 {self log(LogPrefix "launching search engine")}
	 {Time.time Time1}
	 case Options.strategy
	 of "all" then
	    if Options.visual then
	       {IOzSEF.exploreAll Script}
	       {RegisterIOzSEFActions}
	       {Wait _}
	    else
	       BFSO = {New BruteForceSearch.bruteForceSearchClass init}
	    in
	       {BFSO setLoggingLevel(@loggingLevel)}
	       thread
		  {BFSO search(Script Options.timeout Solutions Stats)}
	       end
	    end
	 [] "one" then
	    if Options.visual then
	       {IOzSEF.exploreOne Script}
	       {RegisterIOzSEFActions}
	       {Wait _}
	    else
	       {IOzSEF.searchOneWithStats Script Solutions Stats}
	    end
	 [] "oracle" then
	    if Options.visual then
	       {IOzSEF.exploreOracle Script @oracleO}
	       {RegisterIOzSEFActions}
	       {Wait _}
	    else
	       {IOzSEF.searchOracle Script @oracleO Solutions Stats}
	    end
	 end

	 %% collect solutions and statistics
	 {self log(LogPrefix "waiting for search engine")}
	 {Value.waitOr {Time.alarm Options.timeout*1000} Solutions}
	 {Time.time Time2}
	 if {Value.isDet Solutions} then
	    {self log(LogPrefix "search engine finished")}

	    {CollectStatistics}
	    {SolutionsElement addAttribute("count" {List.length Solutions})}
	    
	    %% collect solutions
	    for Root in Solutions do
	       SolutionElement = {New Helpers.xml.element init("solution")}
	       Description = {@externaliserO describe(Root $)}
	       Externalisation = {@externaliserO externalise(Description $)}
	    in
	       {SolutionElement addChildString(Externalisation)}
	       {SolutionsElement addChild(SolutionElement)}
	    end
	    {SummaryElement addChild(SolutionsElement)}
	    {self log(LogPrefix "collected solutions")}
	 else
	    {self log(LogPrefix "search engine timed out")}
	    TimeoutElement = {New Helpers.xml.element init("timeout")}
	 in
	    if {Not Options.strategy=="all"} then
	       {IOzSEF.cancelSearch}
	    end
	    {TimeoutElement addAttribute("value" Options.timeout)}
	    {SummaryElement addChild(TimeoutElement)}

	    %% If the search engine timed out, but intermediate
	    %% statistics are available, collect them.
	    if {Value.isDet Stats} then {CollectStatistics} end
	 end
	 {SummaryElement toString($)}
      end

      meth close
	 if @useOracle then
	    {self log(LogPrefix "closing the connection to the oracle")}
	    {@oracleO close}
	    {self log(LogPrefix "connection closed")}
	 end
	 
	 if @useGrammarServer then
	    {self log(LogPrefix "closing the connection to the grammar server")}
	    {@grammarServerO close}
	    {self log(LogPrefix "connection closed")}
	 end
      end

      meth reset
	 if @useOracle then
	    {self log(LogPrefix "resetting the oracle")}
	    {@oracleO messageReset(_)}
	    {self log(LogPrefix "oracle reset")}
	 end

	 %% HACK: The grammar server currently expects its connection
	 %% to be closed after every sentence.  This should really be
	 %% changed such that it handles a reset message, like the
	 %% oracle does.

	 if @useGrammarServer then
	    {self log(LogPrefix "closing the connection to the grammar server")}
	    {@grammarServerO close}
	    {self log(LogPrefix "connection closed")}
	    {Time.delay 1000}
	    {self initGrammarServer}
	    {self log(LogPrefix "connecting to the grammar server")}
	    {@grammarServerO connect(@grammarServerHost @grammarServerPort)}
	    {self log(LogPrefix "connection established")}
	 end
      end
   end

   %% SXDG object
   SXDGO =
   case Options.strategy
   of "all" then
      {New SXDG init(GrammarURL unit LoggingLevel)}
   [] "one" then
      {New SXDG init(GrammarURL unit LoggingLevel)}
   [] "oracle" then
      {New SXDG init(GrammarURL OracleURL LoggingLevel)}
   end

   %% emitter for results
   class Output from Open.file Open.text end
   EmitterO
in
   if {Not Options.visual} then
      {New Output init(name:stdout) EmitterO}
      {EmitterO putS("<report count='"#{List.length Sentences}#"'>")}
   end

   %% parse each sentence
   {SXDGO connect}
   {List.forAllInd Sentences
    proc {$ Id Words}
       {EmitterO putS({SXDGO parse(Id Words $)})}
       {SXDGO reset}
    end}
   {SXDGO close}
   
   if {Not Options.visual} then
      {EmitterO putS("</report>")}
      {EmitterO close}
   end

   {Application.exit 0}
end
