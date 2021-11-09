%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Browser(browse)
   Inspector(configure inspect)
   Module(link)
   OS(getDir mkDir pipe)
   Property(put)
   System(show showError)
   Tk(addYScrollbar batch button entry frame label listbox return
      scrollbar toplevel variable)
   TkTools(dialog menubar)
   
   Path at 'x-oz://system/os/Path.ozf'
   String1 at 'x-oz://system/String.ozf'
   Regex at 'x-oz://contrib/regex'

   Helpers at 'Helpers.ozf'
export
   Open
prepare
   ListDrop = List.drop
   ListIsPrefix = List.isPrefix
   ListLast = List.last
   ListTake = List.take
   ListTakeDropWhile = List.takeDropWhile
   ListToTuple = List.toTuple
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   A2S = Atom.toString
   V2S = VirtualString.toString
   V2A = VirtualString.toAtom
   S2I = String.toInt
   S2A = String.toAtom
define
   %% Plan:
   %%
   %% Create mappings:
   %%   principle ID
   %%     -> Definition file name
   %% Need helper mapping Definition file name -> principle ID, create
   %% by scanning all principles in Solver/Principles/Source/*.ul
   %%     -> Definition functor name
   %% Need helper mapping Definition functor name -> principle ID, create
   %% by scanning all principles in Solver/Principles/*.oz
   %%     -> Constraint functors name
   %%
   %% Resolve either locally (add path prefix Solver/Principles) or globally
   %%   
   %% Find out paths to relevant files given the principle ID
   %%    a) scan Solver/Principles/Source/*.ul files for those with the
   %%       principle ID
   %%       -> Definition File
   %%    b) scan Solver/Principles/*.oz files for those with the
   %%       principle ID
   %%       -> Definition Functor
   %%    c) constraint functors given in principle definition "constraints":
   %%       -> Constraint Functors
   %%    d) other control files:
   %%       -> Solver/Principles/Principles.oz
   %%       -> Solver/Principles/principles.xml
   %%       -> Solver/Principles/makefile.oz
   %%       -> Solver/Principles/Lib/makefile.oz
   %%       -> Solver/Principles/Source/makefile.oz

   %% Add principle:
   %%   Select either Definition file or Definition functor
   %%   Definition file: read principle ID, ID -> principle file name,
   %%     Must be in Solver/Principles/Source/*.ul
   %%     Add Definition file to
   %%       Solver/Principles/Source/makefile.oz
   %%     Compile Definition file
   %%       Call pw.exe in PrincipleWriter/
   %%         Definition functor to
   %%           Solver/Principles/<principle file name.oz>
   %%         Constraint functor to
   %%           Solver/Principles/Lib/<principle file name.oz>
   %%   Definition functor: read principle ID
   %%     Add Definition functor to Solver/Principles/Principles.oz
   %%     Add principle ID to Solver/Principles/principles.xml
   %%     Add Definition functor to Solver/Principles/makefile.oz
   %%     Compile Definition functor
   %%       Call oz -c <Definition functor name> in Solver/Principles/
   %%     Compile Solver/Principles/Principles.oz
   %%       Call oz -c Principles.oz in Solver/Principles/
   %%     Link Definition functor
   %%     Read Constraint functors from Definition functor
   %%     Add Constraint functors to Solver/Principles/Lib/makefile.oz
   %%     Compile Constraint functors
   %%       For each Constraint functor,
   %%         call oz -c <Constraint functor name> in Solver/Principles/Lib
   %%
   %% Delete principle:
   %%   Remove Definition functor from Solver/Principles/Principles.oz
   %%   Remove principle ID from Solver/Principles/principles.xml
   %%   Remove Definition functor from Solver/Principles/makefile.oz
   %%   Remove Constraint functors from Solver/Principles/Lib/makefile.oz
   %%   Remove Definition file from Solver/Principles/Source/makefile.oz
   %%   Move Definition functor to Solver/Principles/Trash/
   %%   Remove compiled Definition functor
   %%   Move Constraint functors to Solver/Principles/Trash/Lib
   %%   Remove compiled Constraint functors
   %%   Move Definition file to Solver/Principles/Trash/Source
   %%
   %% Recover principle:
   %%   Select either Definition file or Definition functor
   %%   Definition file:
   %%     Move Definition file from Trash to Solver/Principles/Source
   %%     Go to Add principle
   %%   Definition functor:
   %%     Compile Definition functor
   %%       Move Definition functor to Solver/Principles
   %%       Call oz -c <Definition functor> in Solver/Principles/
   %%       Link Definition functor
   %%       Read Constraint functors from Definition functor
   %%       Move Constraint functors from Trash to Solver/Principles/Lib
   %%       Go to Add principle
   %%
   %% Rename principle (not directly supported, can be done using delete/add)
   %%   Definition file:
   %%     Write new definition file with the new name.
   %%     Delete old principle.
   %%     Add new principle.
   %%   Definition functor:
   %%     Write new Definition functor with the new name,
   %%       perhaps also let it point to Constraint functors with a new name
   %%     Delete old principle.
   %%     Add new principle.
   %%
   %% Rebuild principle:
   %%   If the option is checked and if a Definition file exists,
   %%     recompile Definition file
   %%       Call pw.exe in Solver/Principles/Source
   %%         Definition functor to
   %%           Solver/Principles/<principle file name.oz>
   %%         Constraint functor to
   %%           Solver/Principles/Lib/<principle file name.oz>
   %%   Compile Definition functor
   %%   Link Definition functor
   %%   Read Constraint functors from Definition functor
   %%   Compile Constraint functors
   %%   Update Solver/Principles/Lib/makefile.oz if the Constraint
   %%     functors have changed.
   %%
   %% Rebuild all principles:
   %%   do Rebuild principle for all principles in the list.
   %%
   %% PrincipleWriter principle definition file
   %% (auch in Solver/Principles)
   %%   -> principle definition 'functor' -> compiled,
   %%   -> principle constraint 'functor'(s) -> compiled
   %%
   %% andere Files:
   %%   makefile.oz,
   %%   Solver/Principles/Principles.oz -> compiled,
   %%   Solver/Principles/makefile.oz, (nicht bei Aenderung)
   %%   Solver/Principles/principles.xml, (nicht bei Aenderung)
   %%   Solver/Principles/Lib/makefile.oz
   %%
   %% Build

   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc {Open AXRec}
      
      proc {LogDebug V}
	 DebugB = {DebugTkvar tkReturnInt($)}==1
      in
	 if DebugB then {LogInfo V} end
      end

      proc {LogInfo V}
	 LogA = {LogTkvar tkReturnAtom($)}
	 A = {V2A V}
      in
	 case LogA
	 of inspect then {Inspector.inspect A}
	 [] browse then {Browser.browse A}
	 [] stdout then {System.show A}
	 end
      end

      proc {BeginLog V}
	 {LogInfo '------------------------------------------------------------'}
	 {LogInfo V#'...'}
	 {LogInfo '------------------------------------------------------------'}
      end

      proc {EndLog V}
	 {LogInfo '------------------------------------------------------------'}
	 {LogInfo V#' done.'}
	 {LogInfo '------------------------------------------------------------'}
      end

      proc {ShowBuildResultsInLog DefFilePathV BuildDefFileB DefFunctorPathV BuildDefFunctorB ConstraintPathVs BuildConstraintBs BuildPrinciplesB}
	 {LogInfo 'Build summary'}
	 %%
	 if {Not DefFilePathV==""} then
	    {LogInfo '  Definition file (Principle Writer)'}
	    {LogInfo '    '#DefFilePathV}
	    {LogInfo '      '#if BuildDefFileB then 'Ok' else 'Failed' end}
	 end
	 %%
	 {LogInfo '  Definition functor'}
	 {LogInfo '    '#DefFunctorPathV}
	 {LogInfo '      '#if BuildDefFunctorB then 'Ok' else 'Failed' end}
	 %%
	 {LogInfo '  Constraint functors'}
	 for ConstraintPathV in ConstraintPathVs I in 1..{Length ConstraintPathVs} do
	    {LogInfo '    '#ConstraintPathV}
	    BuildConstraintB = {Nth BuildConstraintBs I}
	 in
	    {LogInfo '      '#if BuildConstraintB then 'Ok' else 'Failed' end}
	 end
	 %%
	 {LogInfo '  Control file "Principles.oz"'}
	 {LogInfo '    '#'"Solver/Principles/Principles.oz"'}
	 {LogInfo '      '#if BuildPrinciplesB then 'Ok' else 'Failed' end}
	 %%
	 {LogInfo 'Build '#
	  if BuildDefFileB andthen
	     BuildDefFunctorB andthen
	     {All BuildConstraintBs fun {$ B} B end} andthen
	     BuildPrinciplesB then
	     'successful'
	  else
	     'failed'
	  end}
      end

      proc {HandleException E}
	 DebugB = {DebugTkvar tkReturnInt($)}==1
	 V = {Helpers.e2V E}
	 if DebugB orelse V=='unhandled error' then {Inspector.inspect E} end
      in
	 {Helpers.tkError 'XDK: Principle Manager: Error' V}
      end

      proc {Try Proc}
	 try
	    {Proc}
	 catch E then
	    {HandleException E}
	 end
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      GlobalDict = {Dictionary.new}
      GlobalDict.ozEditor := unit
      GlobalDict.ulEditor := unit
      GlobalDict.xmlEditor := unit
      GlobalDict.principleDefs := unit
      GlobalDict.filter := unit
      
      proc {SetPrincipleDefs}
	 [PrinciplesFunctor] =
	 {Module.link ['Solver/Principles/Principles.ozf']}
      in
	 GlobalDict.principleDefs := PrinciplesFunctor.principles
      end

      fun {GetPrincipleDefs}
	 if GlobalDict.principleDefs==unit then
	    {SetPrincipleDefs}
	 end
	 GlobalDict.principleDefs
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      fun {SplitLines Ss BeginPrefixS EndPrefixS IndentS EditProc}
	 Ss1
	 Ss2
	 {ListTakeDropWhile
	  Ss
	  fun {$ S} {Not {ListIsPrefix BeginPrefixS S}} end
	  Ss1
	  Ss2}
	 Ss11 = {Append Ss1 {ListTake Ss2 1}}
	 Ss21 = {ListDrop Ss2 1}
	 Ss3
	 Ss4
	 {ListTakeDropWhile
	  Ss21
	  fun {$ S} {Not {ListIsPrefix EndPrefixS S}} end
	  Ss3
	  Ss4}
	 Ss31 =
	 {Map Ss3
	  fun {$ S} {String1.lstrip S unit} end}
	 %%
	 Ss32 = {EditProc Ss31}
	 %%
	 Ss33 = {Map Ss32
		 fun {$ S} {Append IndentS S} end}
      in
	 Ss11#Ss33#Ss4
      end

      fun {EditLines Ss BeginPrefixS EndPrefixS IndentS EditProc}
	 Ss1#Ss2#Ss3 = {SplitLines Ss BeginPrefixS EndPrefixS IndentS EditProc}
      in
	 {Append Ss1 {Append Ss2 Ss3}}
      end

      fun {MakeAddLinesProc LineVs}
	 LineSs = {Map LineVs V2S}
	 fun {EditProc Ss}
	    Ss1 = {Append LineSs Ss}
	    Ss2 = {Helpers.noDoubles Ss1}
	    Ss3 = {Sort Ss2
		   fun {$ S1 S2}
		      A1 = {S2A S1}
		      A2 = {S2A S2}
		   in
		      A1 < A2
		   end}
	 in
	    Ss3
	 end
      in
	 EditProc
      end
      fun {MakeRemoveLinesProc LineVs}
	 LineSs = {Map LineVs V2S}
	 fun {EditProc Ss}
	    Ss1 =
	    {Filter Ss
	     fun {$ S}
		{All LineSs
		 fun {$ LineS}
		    {Not {ListIsPrefix LineS S}}
		 end}
	     end}
	 in
	    Ss1
	 end
      in
	 EditProc
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      fun {CompileDefFile DefFileV DefFunctorV ConstraintV OptionVs}
	 ParameterVs =
	 {Append ["-p" DefFileV
		  "-e" DefFunctorV
		  "-c" ConstraintV] OptionVs}
	 WriteSocketI
	 {LogDebug "PrincipleWriter/pw"}
	 for ParameterV in ParameterVs do
	    {LogDebug ParameterV}
	 end
	 {OS.pipe "PrincipleWriter/pw" ParameterVs _ _#WriteSocketI}
	 Ss = {Helpers.readFromSocket WriteSocketI}
      in
	 Ss
      end

      fun {CompileOz FileV OptionVs}
	 ParameterVs =
	 {Append ["-c" FileV "-o" FileV#"f" "-v"] OptionVs}
	 WriteSocketI
	 {LogDebug "ozc"}
	 for ParameterV in ParameterVs do
	    {LogDebug ParameterV}
	 end
	 {OS.pipe "ozc" ParameterVs _ _#WriteSocketI}
	 Ss = {Helpers.readFromSocket WriteSocketI}
      in
	 Ss
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      fun {GetFileNames DirS ExcludeFileNameSs ExtensionS SubS}
	 FileNameSs = {OS.getDir DirS}
	 ExcludeFileNameSs1 = {Append ExcludeFileNameSs ["." ".."]}
	 SubS1 = {Append &'|SubS "'"}
	 SubS2 = {Append &"|SubS "\""}
	 FileNameSs1 = {Filter FileNameSs
			fun {$ FileNameS}
			   {Not {Member FileNameS ExcludeFileNameSs1}} andthen
			   {Path.extension FileNameS}==ExtensionS andthen
			   local
			      FileContentS = {Helpers.getS DirS#"/"#FileNameS}
			   in
			      {Helpers.isSubstring SubS1 FileContentS} orelse
			      {Helpers.isSubstring SubS2 FileContentS}
			   end
			end}
      in
	 FileNameSs1
      end

      fun {GetPrincipleIDs UrlV}
	 S = {Helpers.getS UrlV}
	 RE = {Regex.make "principle\\.[A-Za-z0-9]*"}
	 MATCHES = {Regex.allMatches RE S}
	 BS = {ByteString.make S}
	 Ss =
	 {Map MATCHES
	  fun {$ MATCH}
	     BS1 = {ByteString.slice BS MATCH.0.1 MATCH.0.2}
	     S1 = {ByteString.toString BS1}
	  in
	     S1
	  end}
      in
	 Ss
      end

      fun {GetPrinciples FilterV}
	 PrincipleDefs = {GetPrincipleDefs}
	 PrincipleAs = {Map PrincipleDefs
			fun {$ PrincipleDef} PrincipleDef.id.data end}
	 RE = {Regex.make FilterV}
	 PrincipleAs1 = {Filter PrincipleAs
			 fun {$ PrincipleA}
			    PrincipleS = {A2S PrincipleA}
			    MATCH = {Regex.search RE PrincipleS}
			 in
			    {Not MATCH==false}
			 end}
      in
	 PrincipleAs1
      end

      fun {PathV2FilterV PathV}
	 IDSs = {GetPrincipleIDs PathV}
	 if IDSs==nil then
	    raise error1('functor':'xdkpm.ozf' 'proc':'ImportFilterFromGrammar' msg:'Selected file does not contain a principle ID.' info:o(PathV) coord:noCoord file:noFile) end
	 end
	 {LogDebug 'File "'#PathV#'" contains the following principle IDs:'}
	 for IDS in IDSs do
	    {LogDebug '  '#IDS}
	 end
	 IDS1|IDSs1 = IDSs
	 FilterV = IDS1#"$"#{FoldL IDSs1
			     fun {$ AccV IDS}
				AccV#"|"#IDS#"$"
			     end ""}
      in
	 FilterV
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {AddToPrinciples IDSuffixS}
	 {LogDebug 'Adding "'#IDSuffixS#"(principle)"#'" to "'#"Solver/Principles/Principles.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/Principles.oz"}
	 EditProc1 = {MakeAddLinesProc [IDSuffixS#"(principle)"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "   " EditProc1}
	 %%
	 {LogDebug 'Adding "'#IDSuffixS#".principle"#'" to "'#"Solver/Principles/Principles.oz"}
	 EditProc2 = {MakeAddLinesProc [IDSuffixS#".principle"]}
	 Ss2 = {EditLines Ss1 "% begin list 2" "% end list 2" "    " EditProc2}
      in
	 {Helpers.putLines Ss2 "Solver/Principles/Principles.oz"}
      end

      proc {RemoveFromPrinciples IDSuffixS}
	 {LogDebug 'Removing "'#IDSuffixS#"(principle)"#'" from "'#"Solver/Principles/Principles.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/Principles.oz"}
	 EditProc1 = {MakeRemoveLinesProc [IDSuffixS#"(principle)"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "   " EditProc1}
	 %%
	 {LogDebug 'Removing "'#IDSuffixS#".principle"#'" from "'#"Solver/Principles/Principles.oz"}
	 EditProc2 = {MakeRemoveLinesProc [IDSuffixS#".principle"]}
	 Ss2 = {EditLines Ss1 "% begin list 2" "% end list 2" "    " EditProc2}
      in
	 {Helpers.putLines Ss2 "Solver/Principles/Principles.oz"}
      end

      proc {AddToPrinciplesMakefile IDSuffixS}
	 {LogDebug 'Adding "\''#IDSuffixS#".ozf\'"#'" to "'#"Solver/Principles/makefile.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/makefile.oz"}
	 EditProc1 = {MakeAddLinesProc ["'"#IDSuffixS#".ozf'"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/makefile.oz"}
      end

      proc {RemoveFromPrinciplesMakefile IDSuffixS}
	 {LogDebug 'Removing "\''#IDSuffixS#".ozf\'"#'" from "'#"Solver/Principles/makefile.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/makefile.oz"}
	 EditProc1 = {MakeRemoveLinesProc ["'"#IDSuffixS#".ozf'"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/makefile.oz"}
      end

      proc {AddToLibMakefile ConstraintFileVs}
	 for ConstraintFileV in ConstraintFileVs do
	    {LogDebug 'Adding "\''#ConstraintFileV#".ozf\'"#'" to "'#"Solver/Principles/Lib/makefile.oz"}
	 end
	 Ss = {Helpers.getLines "Solver/Principles/Lib/makefile.oz"}
	 EditProc1 = {MakeAddLinesProc
		      {Map ConstraintFileVs
		       fun {$ ConstraintFileV} "'"#ConstraintFileV#".ozf'" end}}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/Lib/makefile.oz"}
      end

      proc {RemoveFromLibMakefile ConstraintFileVs}
	 for ConstraintFileV in ConstraintFileVs do
	    {LogDebug 'Removing "\''#ConstraintFileV#".ozf\'"#'" from "'#"Solver/Principles/Lib/makefile.oz"}
	 end
	 Ss = {Helpers.getLines "Solver/Principles/Lib/makefile.oz"}
	 EditProc1 = {MakeRemoveLinesProc
		      {Map ConstraintFileVs
		       fun {$ ConstraintFileV} "'"#ConstraintFileV#".ozf'" end}}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/Lib/makefile.oz"}
      end

      proc {AddToSourceMakefile IDSuffixS}
	 {LogDebug 'Adding "\''#IDSuffixS#".ul\'"#'" to "'#"Solver/Principles/Source/makefile.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/Source/makefile.oz"}
	 EditProc1 = {MakeAddLinesProc ["'"#IDSuffixS#".ul'"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/Source/makefile.oz"}
      end

      proc {RemoveFromSourceMakefile IDSuffixS}
	 {LogDebug 'Removing "\''#IDSuffixS#".ul\'"#'" from "'#"Solver/Principles/Source/makefile.oz"}
	 Ss = {Helpers.getLines "Solver/Principles/Source/makefile.oz"}
	 EditProc1 = {MakeRemoveLinesProc ["'"#IDSuffixS#".ul'"]}
	 Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/Source/makefile.oz"}
      end

      proc {AddToPrinciplesXML IDSuffixS}
	 {LogDebug 'Adding "<principleDef id="principle.'#IDSuffixS#'/>" to "'#"Solver/Principles/principles.xml"}
	 Ss = {Helpers.getLines "Solver/Principles/principles.xml"}
	 EditProc1 = {MakeAddLinesProc ["<principleDef id=\"principle."#IDSuffixS#"\"/>"]}
	 Ss1 = {EditLines Ss "<!-- begin list 1" "<!-- end list 1" "" EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/principles.xml"}
      end

      proc {RemoveFromPrinciplesXML IDSuffixS}
	 {LogDebug 'Removing "<principleDef id="principle.'#IDSuffixS#'/>" from "'#"Solver/Principles/principles.xml"}
	 Ss = {Helpers.getLines "Solver/Principles/principles.xml"}
	 EditProc1 = {MakeRemoveLinesProc ["<principleDef id=\"principle."#IDSuffixS#"\"/>"]}
	 Ss1 = {EditLines Ss "<!-- begin list 1" "<!-- end list 1" "" EditProc1}
      in
	 {Helpers.putLines Ss1 "Solver/Principles/principles.xml"}
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {CopyDefFile SourcePathS IDS IDSuffixS}
	 SuffixS = {Helpers.getSuffix SourcePathS}
	 DestPathV =
	 case SuffixS
	 of "ul" then "Solver/Principles/Source/"#IDSuffixS#".ul"
	 [] "oz" then "Solver/Principles/"#IDSuffixS#".oz"
	 else
	    raise error1('functor':'xdkpm.ozf' 'proc':'CopyDefFile' msg:'Expected either suffix "ul" (principle definition file) or "oz" (principle definition functor) but got: "'#SuffixS#'".' info:o(IDS IDSuffixS SuffixS) coord:noCoord file:noFile) end
	 end
	 DestPathS = {V2S DestPathV}
	 %%
	 IDAs = {GetPrinciples ""}
	 IDA = {S2A IDS}
	 if {Member IDA IDAs} then
	    raise error1('functor':'xdkpm.ozf' 'proc':'CopyDefFile' msg:'Principle ID already exists: "'#IDA#'".' info:o(IDS IDSuffixS SuffixS SourcePathS DestPathS IDA IDAs) coord:noCoord file:noFile) end
	 end
	 FileFunctorA = 
	 case SuffixS
	 of "ul" then 'principle definition file'
	 [] "oz" then 'principle definition functor'
	 end
      in
	 if SourcePathS==DestPathS then
	    {LogInfo FileFunctorA#' "'#SourcePathS#'" is already in the appropriate directory.'}
	 else
	    if {Helpers.fileExists DestPathS} then
	       OverwriteB = {Helpers.tkDialog2 'XDK: Principle Manager' FileFunctorA#' "'#DestPathS#'" already exists. Are you sure to overwrite it with '#FileFunctorA#' "'#SourcePathS#'"?'}
	    in
	       if {Not OverwriteB} then
		  raise error1('functor':'xdkpm.ozf' 'proc':'CopyDefFile' msg:'Add principle canceled.' info:o(IDS IDSuffixS SuffixS SourcePathS DestPathS IDA IDAs) coord:noCoord file:noFile) end
	       end
	    end
	    {LogInfo 'Copying '#FileFunctorA#' from "'#SourcePathS#'" to "'#DestPathS#'".'}
	    {Helpers.dup SourcePathS DestPathS}
	 end
      end

      proc {CopyConstraints DefFunctorDirS ConstraintFileVs}
	 for ConstraintFileV in ConstraintFileVs continue:Continue do
	    SourcePathV = DefFunctorDirS#"/Lib/"#ConstraintFileV#".oz"
	    DestPathV = "Solver/Principles/Lib/"#ConstraintFileV#".oz"
	 in
	    if {Not {Helpers.fileExists SourcePathV}} then
	       {LogInfo 'Constraint functor "'#SourcePathV#'" not found. Continuing.'}
	       {Continue}
	    end
	    if {Helpers.fileExists DestPathV} then
	       OverwriteB = {Helpers.tkDialog2 'XDK: Principle Manager' 'Constraint functor "'#DestPathV#'" already exists. Are you sure to overwrite it with "'#SourcePathV#'"?'}
	    in
	       if {Not OverwriteB} then
		  {LogInfo 'Constraint functor "'#SourcePathV#'" not copied. Continuing.'}
		  {Continue}
	       end
	    end
	    {LogInfo 'Copying constraint functor from "'#SourcePathV#'" to "'#DestPathV#'".'}
	    {Helpers.dup SourcePathV DestPathV}
	 end
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      fun {BuildDefFile DefFilePathV DefFunctorPathV ConstraintPathV}
	 {LogInfo 'Compiling principle definition file '#DefFilePathV}
	 OptionVs =
	 [if {PWOptimizeTkvar tkReturnInt($)}==1 then
	     "--optimize"
	  else
	     "--nooptimize"
	  end
	  %%
	  if {PWSeonTkvar tkReturnInt($)}==1 then
	     "--allow-seon"
	  else
	     "--noallow-seon"
	  end
	  %%
	  if {PWAdhocTkvar tkReturnInt($)}==1 then
	     "--adhoc"
	  else
	     "--noadhoc"
	  end]
	 DefFileOutputSs =
	 {CompileDefFile
	  DefFilePathV
	  DefFunctorPathV
	  ConstraintPathV
	  OptionVs}
      in
	 for S in DefFileOutputSs do
	    {LogInfo "  "#S}
	 end
	 if DefFileOutputSs==nil then
	    false
	 else
	    {ListIsPrefix "Saved constraint functor in " {ListLast DefFileOutputSs}}
	 end
      end

      fun {BuildDefFunctor DefFunctorPathV}
	 {LogInfo {V2A 'Compiling principle definition functor '#DefFunctorPathV}}
	 DefFunctorOutputSs = {CompileOz DefFunctorPathV nil}
      in
	 for S in DefFunctorOutputSs do
	    {LogInfo "  "#S}
	 end
	 if DefFunctorOutputSs==nil then
	    false
	 else
	    {ListLast DefFunctorOutputSs}=="% -------------------- accepted"
	 end
      end

      fun {BuildConstraints ConstraintPathVs}
	 BuildConstraintBs =
	 for ConstraintPathV in ConstraintPathVs collect:Collect do
	    {LogInfo 'Compiling principle constraint functor '#ConstraintPathV}
	    ConstraintOutputSs = {CompileOz ConstraintPathV nil}
	 in
	    for S in ConstraintOutputSs do
	       {LogInfo "  "#S}
	    end
	    if ConstraintOutputSs==nil then
	       {Collect false}
	    else
	       {Collect {ListLast ConstraintOutputSs}=="% -------------------- accepted"}
	    end
	 end
      in
	 BuildConstraintBs
      end

      fun {BuildPrinciples}
	 {LogInfo 'Compiling control file Solver/Principles/Principles.oz'}
	 PrinciplesOutputSs = {CompileOz "Solver/Principles/Principles.oz" nil}
      in
	 for S in PrinciplesOutputSs do
	    {LogInfo "  "#S}
	 end
	 GlobalDict.principleDefs := unit
	 if PrinciplesOutputSs==nil then
	    false
	 else
	    {ListLast PrinciplesOutputSs}=="% -------------------- accepted"
	 end
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {HighlightPrinciple IDS}
	 SizeS = {ListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    SizeI = {S2I SizeS}
	 in
	    for IndexI in 0..SizeI-1 break:Break do
	       IDS1 = {ListW tkReturn(get(IndexI) $)}
	    in
	       if IDS1==IDS then
		  CurIndexS = {ListW tkReturn(curselection $)}
	       in
		  if {Not CurIndexS==nil} then {ListW tk(selection clear CurIndexS)} end
		  {ListW tk(selection set IndexI)}
		  {ListW tk(see IndexI)}
		  {Break}
	       end
	    end
	 end
      end

      proc {SetPrinciples PrincipleAs}
	 PrincipleARec = {ListToTuple o PrincipleAs}
	 SizeI = {ListW tkReturnInt(size $)}
      in
	 {ListW tk(delete 0 SizeI-1)}
	 if {Not PrincipleAs == nil} then
	    {ListW tk(insert 'end' PrincipleARec)}
	 end
	 {ListRemoveButtonW tk(configure state:disabled)}
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {About}
	 {Helpers.tkDialogImage 'XDK: About' 'XDG Development Kit: Principle Manager\n\nCopyright 2008\n\nby Ralph Debusmann <rade@ps.uni-sb.de>' 'xdk.gif'}
      end

      proc {Quit}
	 {ToplevelW tkClose}
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {AddPrinciples}
	 PathSs = {Helpers.tkGetOpenFiles
		   'XDK: Principle Manager: Add...'
		   q(q('Principle definition file/functor' '*.ul')
		     q('Principle definition file/functor' '*.oz')
		     q('All files' '*'))}
      in
	 for PathS in PathSs do
	    {BeginLog 'Add principle'}
	    %%
	    IDSs = {GetPrincipleIDs PathS}
	    if IDSs==nil then
	       raise error1('functor':'xdkpm.ozf' 'proc':'AddPrinciple' msg:'Principle definition file/definition functor does not contain a principle ID.' info:o(PathS) coord:noCoord file:noFile) end
	    end
	    IDS = IDSs.1
	    IDSuffixS = {Helpers.getSuffix IDS}
	    IDSuffixCh|IDSuffixS1 = IDSuffixS
	    IDSuffixS2 = {Char.toUpper IDSuffixCh}|IDSuffixS1
	    %%
	    SuffixS = {Helpers.getSuffix PathS}
	    %% Copy principle definition file/functor
	    {CopyDefFile PathS IDS IDSuffixS2}
	    %% Build principle definition file
	    DefFilePathV#BuildDefFileB =
	    case SuffixS
	    of "ul" then
	       {AddToSourceMakefile IDSuffixS2}
	       DefFilePathV = "Solver/Principles/Source/"#IDSuffixS2#".ul"
	       DefFunctorPathV = "Solver/Principles/"#IDSuffixS2#".oz"
	       ConstraintPathV = "Solver/Principles/Lib/"#IDSuffixS2#".oz"
	       BuildDefFileB = {BuildDefFile DefFilePathV DefFunctorPathV ConstraintPathV}
	    in
	       DefFilePathV#BuildDefFileB
	    [] "oz" then
	       ""#true
	    end
	    %% Build principle definition functor
	    DefFunctorPathV = "Solver/Principles/"#IDSuffixS2#".oz"
	    BuildDefFunctorB = {BuildDefFunctor DefFunctorPathV}
	    %% Build principles
	    {AddToPrinciples IDSuffixS2}
	    {AddToPrinciplesMakefile IDSuffixS2}
	    {AddToPrinciplesXML IDSuffixS}
	    BuildPrinciplesB = {BuildPrinciples}
	    %% Build constraint functors
	    ConstraintFileVs =
	    case SuffixS
	    of "ul" then
	       [IDSuffixS2]
	    [] "oz" then
	       [DefFunctor] = {Module.link [DefFunctorPathV#"f"]}
	       ConstraintILs = DefFunctor.principle.constraints
	       ConstraintAs = {Map ConstraintILs
			       fun {$ ConstraintIL} ConstraintIL.1.data end}
	       DirS = {Path.dirname PathS}
	       {CopyConstraints DirS ConstraintAs}
	    in
	       ConstraintAs
	    end
	    %%
	    {AddToLibMakefile ConstraintFileVs}
	    ConstraintPathVs = {Map ConstraintFileVs
				fun {$ ConstraintFileV}
				   "Solver/Principles/Lib/"#ConstraintFileV#".oz"
				end}
	    BuildConstraintBs = {BuildConstraints ConstraintPathVs}
	 in
	    {ShowBuildResultsInLog
	     DefFilePathV BuildDefFileB
	     DefFunctorPathV BuildDefFunctorB
	     ConstraintPathVs BuildConstraintBs
	     BuildPrinciplesB}
	    %%
	    {FilterPrinciples}
	    {HighlightPrinciple IDS}
	    {SetPrinciple}
	    %%
	    {PostBuildProc}
	    %%
	    {EndLog 'Add principle'}
	 end
      end

      proc {RemovePrinciples}
	 SizeS = {ListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    CurIndexS = {ListW tkReturn(curselection $)}
	    CurIndexSs = {String.tokens CurIndexS & }
	 in
	    for CurIndexS1 in CurIndexSs do
	       IDS = {ListW tkReturn(get(CurIndexS1) $)}
	       RemoveB = {Helpers.tkDialog2 'XDK: Principle Manager' 'Are you sure to remove principle "'#IDS#'"?'}
	    in
	       if RemoveB then
		  {BeginLog 'Remove principle'}
		  IDSuffixS = {Helpers.getSuffix IDS}
		  IDSuffixCh|IDSuffixS1 = IDSuffixS
		  IDSuffixS2 = {Char.toUpper IDSuffixCh}|IDSuffixS1
		  %%
		  IDA = {S2A IDS}
		  %%
		  DefFilePathV = IDADefFilePathVDict.IDA
		  %%
		  {RemoveFromPrinciplesXML IDSuffixS}
		  {RemoveFromPrinciples IDSuffixS2}
		  {RemoveFromPrinciplesMakefile IDSuffixS2}
		  if {Not DefFilePathV==""} then
		     {RemoveFromSourceMakefile IDSuffixS2}
		  end
		  %%
		  if {Not {Helpers.fileExists "Solver/Principles/Trash"}} then
		     {OS.mkDir "Solver/Principles/Trash" ['S_IWUSR' 'S_IRUSR' 'S_IRGRP' 'S_IROTH']}
		  end
		  if {Not {Helpers.fileExists "Solver/Principles/Trash/Source"}} then
		     {OS.mkDir "Solver/Principles/Trash/Source" ['S_IWUSR' 'S_IRUSR' 'S_IRGRP' 'S_IROTH']}
		  end
		  if {Not {Helpers.fileExists "Solver/Principles/Trash/Lib"}} then
		     {OS.mkDir "Solver/Principles/Trash/Lib" ['S_IWUSR' 'S_IRUSR' 'S_IRGRP' 'S_IROTH']}
		  end
		  %%
		  if DefFilePathV=="" then
		     {LogInfo 'Moving "Solver/Principles/'#IDSuffixS2#'.oz" to "Solver/Principles/Trash/'#IDSuffixS2#'.oz".'}
		     {Helpers.mv "Solver/Principles/"#IDSuffixS2#".oz" "Solver/Principles/Trash/"#IDSuffixS2#".oz"}
		  else
		     {LogInfo 'Moving "Solver/Principles/Source/'#IDSuffixS2#'.ul" to "Solver/Principles/Trash/Source"'#IDSuffixS2#'.ul".'}
		     {Helpers.mv "Solver/Principles/Source/"#IDSuffixS2#".ul" "Solver/Principles/Trash/Source/"#IDSuffixS2#".ul"}
		  end
		  %%
		  BuildPrinciplesB = {BuildPrinciples}
	       in
		  {LogInfo 'Build summary'}
		  {LogInfo '  Control file "Principles.oz"'}
		  {LogInfo '    '#'"Solver/Principles/Principles.oz"'}
		  {LogInfo '      '#if BuildPrinciplesB then 'Ok' else 'Failed' end}
		  {LogInfo 'Build '#if BuildPrinciplesB then 'successful' else 'failed' end}
		  %%
		  {FilterPrinciples}
		  %%
		  {PostBuildProc}
		  %%
		  {EndLog 'Remove principle'}
	       end
	    end
	 end
      end

      proc {ImportFilterFromGrammars}
	 PathSs = {Helpers.tkGetOpenFiles
		   'XDK: Principle Manager: Import filter from grammars...'
		   q(q('Grammar files' '*.ul')
		     q('Grammar files' '*.xml')
		     q('All files' '*'))}
      in
	 {FilterEntryW tk(delete 0 'end')}
	 for PathS in PathSs do
	    {BeginLog 'Import filter from grammar'}
	    %%
	    FilterV = {PathV2FilterV PathS}
	    GlobalDict.filter := FilterV
	 in
	    {FilterEntryW tk(insert 'end' FilterV)}
	    {FilterPrinciples}
	    %%
	    {EndLog 'Import filter from grammar'}
	 end
      end

      proc {ResetToLastImportedFilter}
	 {FilterEntryW tk(delete 0 'end')}
	 {FilterEntryW tk(insert 'end' GlobalDict.filter)}
	 {FilterPrinciples}
      end

      proc {RemoveUnusedConstraintFunctors}
	 {BeginLog 'Remove unused constraint functors'}
	 PrincipleDefs = {GetPrincipleDefs}
	 AllUsedConstraintFileAs =
	 for PrincipleDef in PrincipleDefs append:Append do
	    UsedConstraintAs = {Map PrincipleDef.constraints
				fun {$ ConstraintsIL}
				   ConstraintsIL.1.data
				end}
	 in
	    {Append UsedConstraintAs}
	 end
	 AllUsedConstraintFileAs1 = {Helpers.noDoubles AllUsedConstraintFileAs}
	 %%
	 Ss = {Helpers.getLines "Solver/Principles/Lib/makefile.oz"}
	 EditProc1 = fun {$ Ss}
			{Map Ss
			 fun {$ S}
			    S1 = {String1.strip S "'"}
			 in
			    {Helpers.removeSuffix S1 &.}
			 end}
		     end
	 _#Ss1#_ = {SplitLines Ss "% begin list 1" "% end list 1" "" EditProc1}
	 AllConstraintFileAs = {Map Ss1 S2A}
	 AllUnusedConstraintFileAs =
	 {Filter AllConstraintFileAs
	  fun {$ ConstraintFileA}
	     {Not {Member ConstraintFileA AllUsedConstraintFileAs1}}
	  end}
	 %%
	 {RemoveFromLibMakefile AllUnusedConstraintFileAs}
      in
	 if AllUnusedConstraintFileAs==nil then
	    {LogInfo 'No unused constraint functors found.'}
	 else
	    for ConstraintFileA in AllUnusedConstraintFileAs do
	       {LogInfo 'Moving "Solver/Principles/Lib'#ConstraintFileA#'.oz" to "Solver/Principles/Trash/Lib/'#ConstraintFileA#'.oz".'}
	       {Helpers.mv "Solver/Principles/Lib/"#ConstraintFileA#".oz" "Solver/Principles/Trash/Lib/"#ConstraintFileA#".oz"}
	    end
	 end
	 {EndLog 'Remove unused constraint functors'}
      end

      proc {EditConstraint}
	 FileNameS =
	 {ConstraintsEntryW tkReturnString(get $)}
      in
	 {EditOz FileNameS}
      end

      proc {EditOtherFile}
	 FileNameS =
	 {OtherFilesEntryW tkReturnString(get $)}
	 SuffixS = {Helpers.getSuffix FileNameS}
      in
	 case SuffixS
	 of "oz" then {EditOz FileNameS}
	 [] "xml" then {EditXML FileNameS}
	 end
      end

      proc {FilterPrinciples}
	 FilterS = {FilterEntryW tkReturnString(get $)}
	 PrincipleAs = {GetPrinciples FilterS}
      in
	 {SetPrinciples PrincipleAs}
	 {ListEntryW tk(configure state:normal)}
	 {ListEntryW tk(delete 0 'end')}
	 {ListEntryW tk(configure state:disabled)}
	 {ClearDefFile}
	 {ClearDefFunctor}
	 {ClearConstraints}
	 {ClearOtherFiles}
	 {BuildButtonW tk(configure state:disabled)}
      end

      proc {Build}
	 {BeginLog 'Build principle'}
	 BuildPrincipleB = {BuildPrinciple}
      in
	 if BuildPrincipleB then {PostBuildProc} end
	 {EndLog 'Build principle'}
      end

      fun {BuildPrinciple}
	 IDS = {ListEntryW tkReturnString(get $)}
	 BuildPrincipleB = 
	 if IDS=="" then
	    true
	 else
	    IDA = {S2A IDS}
	    BuildDefFileB = {BuildDefFileTkvar tkReturnInt($)} == 1
	    DefFilePathV = if BuildDefFileB then IDADefFilePathVDict.IDA else "" end
	    DefFunctorPathV = IDADefFunctorPathVDict.IDA
	    ConstraintPathVs = IDAConstraintPathVsDict.IDA
	    BuildDefFileB1 =
	    if {V2S DefFilePathV}=="" then
	       true
	    else
	       {BuildDefFile DefFilePathV DefFunctorPathV ConstraintPathVs.1}
	    end
	    BuildDefFunctorB = {BuildDefFunctor DefFunctorPathV}
	    BuildConstraintBs = {BuildConstraints ConstraintPathVs}
	    BuildPrinciplesB = {BuildPrinciples}
	    {ShowBuildResultsInLog
	     DefFilePathV BuildDefFileB1
	     DefFunctorPathV BuildDefFunctorB
	     ConstraintPathVs BuildConstraintBs
	     BuildPrinciplesB}
	    %%
	    BuildPrincipleB =
	    BuildDefFileB1 andthen
	    BuildDefFunctorB andthen
	    {All BuildConstraintBs fun {$ B} B end} andthen
	    BuildPrinciplesB
	 in
	    BuildPrincipleB
	 end
      in
	 BuildPrincipleB
      end

      proc {BuildAllPrinciplesInList}
	 {BeginLog 'Build all principles in list'}
	 %%
	 SizeS = {ListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    SizeI = {S2I SizeS}
	    %%
	    ClosedB
	    DialogW
	    thread
	       !DialogW = {New TkTools.dialog
			   tkInit(title: 'XDK: Principle Manager'
				  buttons: ['Cancel'#proc {$}
							ClosedB = true
						     end]
				  default: 1)}
	       FrameW = {New Tk.frame tkInit(parent: DialogW)}
	       TextLabelW = {New Tk.label tkInit(parent: FrameW
						 text: 'Building all principles in list...')}
	    in
	       {Tk.batch [pack(DialogW FrameW)
			  grid(TextLabelW row:0)]}
	    end
	    FailedIDSs =
	    for IndexI in 0..SizeI-1 break:Break collect:Collect do
	       if {IsDet ClosedB} andthen ClosedB then {Break} end
	       CurIndexS = {ListW tkReturn(curselection $)}
	       if {Not CurIndexS==nil} then {ListW tk(selection clear CurIndexS)} end
	       {ListW tk(selection set IndexI)}
	       {ListW tk(see IndexI)}
	       {SetPrinciple}
	       BuildPrincipleB = {BuildPrinciple}
	    in
	       if {Not BuildPrincipleB} then
		  IDS = {ListW tkReturn(get(IndexI) $)}
	       in
		  {Collect IDS}
	       end
	    end
	    if {IsDet ClosedB} andthen ClosedB then
	       {LogInfo 'Canceled.'}
	    end
	    if FailedIDSs==nil then
	       {LogInfo 'All principles built successfully.'}
	       {PostBuildProc}
	    else
	       {LogInfo 'Some principles could not be successfully built:'}
	       for IDS in FailedIDSs do
		  {LogInfo '  '#IDS}
	       end
	    end
	 in
	    {DialogW tkClose}
	 end
	 %%
	 {EndLog 'Build all principles in list'}
      end

      proc {SetConstraint}
	 SizeS = {ConstraintsListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    CurIndexS = {ConstraintsListW tkReturn(curselection $)}
	    FileNameS = {ConstraintsListW tkReturn(get(CurIndexS) $)}
	 in
	    {ConstraintsEntryW tk(configure state:normal)}
	    {ConstraintsEntryW tk(delete 0 'end')}
	    {ConstraintsEntryW tk(insert 'end' FileNameS)}
	    {ConstraintsEntryW tk(configure state:disabled)}
	 end
      end

      proc {SetOtherFile}
	 SizeS = {OtherFilesListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    CurIndexS = {OtherFilesListW tkReturn(curselection $)}
	    FileNameS = {OtherFilesListW tkReturn(get(CurIndexS) $)}
	 in
	    {OtherFilesEntryW tk(configure state:normal)}
	    {OtherFilesEntryW tk(delete 0 'end')}
	    {OtherFilesEntryW tk(insert 'end' FileNameS)}
	    {OtherFilesEntryW tk(configure state:disabled)}
	 end
      end

      proc {SetPrinciple}
	 SizeS = {ListW tkReturn(size $)}
      in
	 if {Not SizeS=="0"} then
	    CurIndexS = {ListW tkReturn(curselection $)}
	    CurIndexSs = {String.tokens CurIndexS & }
	    CurIndexS1 = CurIndexSs.1
	    PrincipleS = {ListW tkReturn(get(CurIndexS1) $)}
	 in
	    {ListEntryW tk(configure state:normal)}
	    {ListEntryW tk(delete 0 'end')}
	    {ListEntryW tk(insert 'end' PrincipleS)}
	    {ListEntryW tk(configure state:disabled)}
	    %%
 	    {SetDefFile PrincipleS}
 	    {SetDefFunctor PrincipleS}
 	    {SetConstraints PrincipleS}
 	    {SetOtherFiles}
 	    {BuildButtonW tk(configure state:normal)}
 	    {ListRemoveButtonW tk(configure state:normal)}
	 end
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      proc {Edit FileV EditorA}
	 {OS.pipe GlobalDict.EditorA [FileV] _ _#_}
      end

      proc {EditOz FileV} {Edit FileV ozEditor} end
      proc {EditUL FileV} {Edit FileV ulEditor} end
      proc {EditXML FileV} {Edit FileV xmlEditor} end

      IDADefFilePathVDict = {Dictionary.new}
      proc {SetDefFile IDS}
	 FileNameSs = {GetFileNames
		       "Solver/Principles/Source"
		       nil
		       "ul"
		       IDS}
	 IDA = {S2A IDS}
      in
	 if FileNameSs==nil then
	    {ClearDefFile}
	    IDADefFilePathVDict.IDA := ""
	 elseif {Length FileNameSs}==1 then
	    DefFilePathV = "Solver/Principles/Source/"#FileNameSs.1
	 in
	    {DefFileEntryW tk(configure state:normal)}
	    {DefFileEntryW tk(delete 0 'end')}
	    {DefFileEntryW tk(insert 'end' DefFilePathV)}
	    {DefFileEntryW tk(configure state:disabled)}
	    {DefFileEditButtonW tk(configure state:normal)}
	    IDADefFilePathVDict.IDA := DefFilePathV
	 end
      end
      proc {ClearDefFile}
	 {DefFileEntryW tk(configure state:normal)}
	 {DefFileEntryW tk(delete 0 'end')}
	 {DefFileEntryW tk(configure state:disabled)}
	 {DefFileEditButtonW tk(configure state:disabled)}
      end

      IDADefFunctorPathVDict = {Dictionary.new}
      proc {SetDefFunctor IDS}
	 FileNameSs = {GetFileNames
		       "Solver/Principles"
		       ["makefile.oz" "Helpers.oz" "Principles.oz"]
		       "oz"
		       IDS}
	 IDA = {S2A IDS}
      in
	 if FileNameSs==nil then
	    {ClearDefFunctor}
	    IDADefFunctorPathVDict.IDA := ""
	 elseif {Length FileNameSs}==1 then
	    DefFunctorPathV = "Solver/Principles/"#FileNameSs.1
	 in
	    {DefFunctorEntryW tk(configure state:normal)}
	    {DefFunctorEntryW tk(delete 0 'end')}
	    {DefFunctorEntryW tk(insert 'end' DefFunctorPathV)}
	    {DefFunctorEntryW tk(configure state:disabled)}
	    {DefFunctorEditButtonW tk(configure state:normal)}
	    IDADefFunctorPathVDict.IDA := DefFunctorPathV
	 end
      end
      proc {ClearDefFunctor}
	 {DefFunctorEntryW tk(configure state:normal)}
	 {DefFunctorEntryW tk(delete 0 'end')}
	 {DefFunctorEntryW tk(configure state:disabled)}
	 {DefFunctorEditButtonW tk(configure state:disabled)}
      end

      IDAConstraintPathVsDict = {Dictionary.new}
      proc {SetConstraints IDS}
	 {SetPrincipleDefs}
	 PrincipleDefs = {GetPrincipleDefs}
	 IDA = {S2A IDS}
	 ConstraintPathVs =
	 for PrincipleDef in PrincipleDefs append:Append break:Break do
	    if PrincipleDef.id.data==IDA then
	       ConstraintPathVs =
	       {Map PrincipleDef.constraints
		fun {$ ConstraintIL}
		   "Solver/Principles/Lib/"#ConstraintIL.1.data#".oz"
		end}
	    in
	       {Append ConstraintPathVs}
	       {Break}
	    end
	 end
	 ConstraintPathVRec = {ListToTuple o ConstraintPathVs}
	 SizeI = {ConstraintsListW tkReturnInt(size $)}
      in
	 {ConstraintsListW tk(delete 0 SizeI-1)}
	 if {Not ConstraintPathVs == nil} then
	    {ConstraintsListW tk(insert 'end' ConstraintPathVRec)}
	 end
	 {ConstraintsEntryW tk(configure state:normal)}
	 {ConstraintsEntryW tk(delete 0 'end')}
	 {ConstraintsEntryW tk(insert 'end' ConstraintPathVs.1)}
	 {ConstraintsEntryW tk(configure state:disabled)}
	 {ConstraintsEditButtonW tk(configure state:normal)}
	 IDAConstraintPathVsDict.IDA := ConstraintPathVs
      end
      proc {ClearConstraints}
	 SizeI = {ConstraintsListW tkReturnInt(size $)}
      in
	 {ConstraintsListW tk(delete 0 SizeI-1)}
	 {ConstraintsEntryW tk(configure state:normal)}
	 {ConstraintsEntryW tk(delete 0 'end')}
	 {ConstraintsEntryW tk(configure state:disabled)}
	 {ConstraintsEditButtonW tk(configure state:disabled)}
      end

      OtherFilesPathVs = [
			  'Solver/Principles/Principles.oz'
			  'Solver/Principles/principles.xml'
			  'Solver/Principles/makefile.oz'
			  'Solver/Principles/Lib/makefile.oz'
			  'Solver/Principles/Source/makefile.oz'
			 ]
      proc {SetOtherFiles}
	 OtherFilesPathVRec = {ListToTuple o OtherFilesPathVs}
	 SizeI = {OtherFilesListW tkReturnInt(size $)}
      in
	 {OtherFilesListW tk(delete 0 SizeI-1)}
	 {OtherFilesListW tk(insert 'end' OtherFilesPathVRec)}
	 {OtherFilesEntryW tk(configure state:normal)}
	 {OtherFilesEntryW tk(delete 0 'end')}
	 {OtherFilesEntryW tk(insert 'end' OtherFilesPathVs.1)}
	 {OtherFilesEntryW tk(configure state:disabled)}
	 {OtherFilesEditButtonW tk(configure state:normal)}
      end
      proc {ClearOtherFiles}
	 SizeI = {OtherFilesListW tkReturnInt(size $)}
      in
	 {OtherFilesListW tk(delete 0 SizeI-1)}
	 {OtherFilesEntryW tk(configure state:normal)}
	 {OtherFilesEntryW tk(delete 0 'end')}
	 {OtherFilesEntryW tk(configure state:disabled)}
	 {OtherFilesEditButtonW tk(configure state:disabled)}
      end

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %% filter
      FilterV = {CondSelect AXRec filter ""}
      %% grammar
      GrammarV = {CondSelect AXRec grammar ""}
      %% builddeffile
      BuildDefFileB = {CondSelect AXRec builddeffile true}
      %% ozeditor
      OzEditorV = {CondSelect AXRec ozeditor "oz"}
      GlobalDict.ozEditor := OzEditorV
      %% uleditor
      ULEditorV = {CondSelect AXRec uleditor "emacs"}
      GlobalDict.ulEditor := ULEditorV
      %% xmleditor
      XMLEditorV = {CondSelect AXRec xmleditor "emacs"}
      GlobalDict.xmlEditor := XMLEditorV
      %% pwoptimize
      PWOptimizeB = {CondSelect AXRec pwoptimize true}
      %% pwseon
      PWSeonB = {CondSelect AXRec pwseon false}
      %% pwadhoc
      PWAdhocB = {CondSelect AXRec pwadhoc true}
      %% log
      LogA = {CondSelect AXRec log inspect}
      %% debug
      DebugB = {CondSelect AXRec debug false}
      %%
      %% postbuildproc
      PostBuildProc = {CondSelect AXRec postbuild proc {$} skip end}
      
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      ToplevelW =
      {New Tk.toplevel tkInit(title: 'XDK: Principle Manager')}
      
      LeftFrameW = {New Tk.frame tkInit(parent:ToplevelW)}

      ListLabelW =
      {New Tk.label tkInit(parent: LeftFrameW
			   text: 'Principle list')}

      FilterFrameW =
      {New Tk.frame tkInit(parent: LeftFrameW)}
      FilterButtonW =
      {New Tk.button tkInit(parent: FilterFrameW
			    text: 'Filter'
			    action: proc {$} {Try FilterPrinciples} end)}
      FilterEntryW =
      {New Tk.entry tkInit(parent: FilterFrameW
			   background: white)}
      {FilterEntryW tkBind(event:'<Return>'
			   action: proc {$} {Try FilterPrinciples} end)}

      ListFrameW =
      {New Tk.frame tkInit(parent: LeftFrameW)}
      ListW =
      {New Tk.listbox tkInit(parent: ListFrameW
			     width: 35
			     height: 20
			     background: white
			     selectmode: extended)}
      {ListW
       tkBind(event:  '<1>' %% single click (left mouse button)
	      action: proc {$} {Try SetPrinciple} end)}
      ListScrollW =
      {New Tk.scrollbar tkInit(parent: ListFrameW)}
      {Tk.addYScrollbar ListW ListScrollW}

      ListEntryFrameW = {New Tk.frame tkInit(parent:LeftFrameW)}
      ListEntryW =
      {New Tk.entry tkInit(parent: ListEntryFrameW
			   background: white
			   state: disabled)}

      ListButtonsFrameW = {New Tk.frame tkInit(parent:LeftFrameW)}
      ListAddButtonW = {New Tk.button tkInit(parent:ListButtonsFrameW
					     text:'Add...'
					     action: proc {$}
							{Try AddPrinciples}
						     end)}
      {ToplevelW
       tkBind(event:  '<Control-a>' 
	      action: proc {$} {Try AddPrinciples} end)}
      ListRemoveButtonW = {New Tk.button tkInit(parent:ListButtonsFrameW
						text:'Remove'
						action: proc {$}
							   {Try RemovePrinciples}
							end)}
      {ToplevelW
       tkBind(event: '<Delete>' 
	      action: proc {$} {Try RemovePrinciples} end)}

      RightFrameW = {New Tk.frame tkInit(parent:ToplevelW)}

      DefFileFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      DefFileLabelW =
      {New Tk.label tkInit(parent: DefFileFrameW
			   text: 'Definition file (Principle Writer)')}
      DefFileEntryW =
      {New Tk.entry tkInit(parent: DefFileFrameW
			   background: white
			   state: disabled)}
      DefFileEditButtonW =
      {New Tk.button tkInit(parent: DefFileFrameW
			    text: 'Edit'
			    state: disabled
			    action: proc {$}
				       {Try
					proc {$}
					   FileNameS =
					   {DefFileEntryW tkReturnString(get $)}
					in
					   {EditUL FileNameS}
					end}
				    end)}


      DefFunctorFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      DefFunctorLabelW =
      {New Tk.label tkInit(parent: DefFunctorFrameW
			   text: 'Definition functor')}
      DefFunctorEditButtonW =
      {New Tk.button tkInit(parent: DefFunctorFrameW
			    text: 'Edit'
			    state: disabled
			    action: proc {$}
				       {Try
					proc {$}
					   FileNameS =
					   {DefFunctorEntryW tkReturnString(get $)}
					in
					   {EditOz FileNameS}
					end}
				    end)}
      DefFunctorEntryW =
      {New Tk.entry tkInit(parent: DefFunctorFrameW
			   background: white
			   state: disabled)}

      ConstraintsLabelW =
      {New Tk.label tkInit(parent: RightFrameW
			   text: 'Constraint functors')}

      ConstraintsListFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      ConstraintsListW =
      {New Tk.listbox tkInit(parent: ConstraintsListFrameW
			     width: 30
			     height: 4
			     background: white)}
      {ConstraintsListW
       tkBind(event:  '<1>' %% single click (left mouse button)
	      action: proc {$} {Try SetConstraint} end)}
      {ConstraintsListW
       tkBind(event:  '<Double-1>' %% double click (left mouse button)
	      action: proc {$}
			 {Try
			  proc {$}
			     {SetConstraint}
			     {EditConstraint}
			  end}
		      end)}
      ConstraintsListScrollW =
      {New Tk.scrollbar tkInit(parent: ConstraintsListFrameW)}
      {Tk.addYScrollbar ConstraintsListW ConstraintsListScrollW}

      ConstraintsEntryFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      ConstraintsEditButtonW =
      {New Tk.button tkInit(parent: ConstraintsEntryFrameW
			    text: 'Edit'
			    state: disabled
			    action: proc {$} {Try EditConstraint} end)}
      ConstraintsEntryW =
      {New Tk.entry tkInit(parent: ConstraintsEntryFrameW
			   background: white
			   state: disabled)}

      OtherFilesLabelW =
      {New Tk.label tkInit(parent: RightFrameW
			   text: 'Other control files')}

      OtherFilesListFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      OtherFilesListW =
      {New Tk.listbox tkInit(parent: OtherFilesListFrameW
			     width: 30
			     height: 5
			     background: white)}
      {OtherFilesListW
       tkBind(event:  '<1>' %% single click (left mouse button)
	      action: proc {$} {Try SetOtherFile} end)}
      {OtherFilesListW
       tkBind(event:  '<Double-1>' %% double click (left mouse button)
	      action: proc {$}
			 {Try
			  proc {$}
			     {SetOtherFile}
			     {EditOtherFile}
			  end}
		      end)}
      OtherFilesListScrollW =
      {New Tk.scrollbar tkInit(parent: OtherFilesListFrameW)}
      {Tk.addYScrollbar OtherFilesListW OtherFilesListScrollW}

      OtherFilesEntryFrameW =
      {New Tk.frame tkInit(parent: RightFrameW)}
      OtherFilesEditButtonW =
      {New Tk.button tkInit(parent: OtherFilesEntryFrameW
			    text: 'Edit'
			    state: disabled
			    action: proc {$} {Try EditOtherFile} end)}
      OtherFilesEntryW =
      {New Tk.entry tkInit(parent: OtherFilesEntryFrameW
			   background: white
			   state: disabled)}

      BuildFrameW = {New Tk.frame tkInit(parent:RightFrameW)}
      BuildButtonW = {New Tk.button tkInit(parent:BuildFrameW
					   text:'Build'
					   action: proc {$} {Try Build} end
					   state:disabled)}
      {ToplevelW
       tkBind(event: '<Control-b>' 
	      action: proc {$} {Try Build} end)}

      BuildDefFileTkvar = {New Tk.variable tkInit(BuildDefFileB)}
      %%
      PWOptimizeTkvar = {New Tk.variable tkInit(PWOptimizeB)}
      PWSeonTkvar = {New Tk.variable tkInit(PWSeonB)}
      PWAdhocTkvar = {New Tk.variable tkInit(PWAdhocB)}
      %%
      LogTkvar = {New Tk.variable tkInit(LogA)}
      DebugTkvar = {New Tk.variable tkInit(DebugB)}
      
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      MenuEntries =
      [menubutton(text: 'Project'
		  menu:
		[
		 command(label: 'About...'
			 action: proc {$} {Try About} end)
		 separator
		 command(label: 'Import filter from grammar...'
			 action: proc {$} {Try ImportFilterFromGrammars} end
			 key: ctrl(o))
		 command(label: 'Reset to last imported filter'
			 action: proc {$} {Try ResetToLastImportedFilter} end
			 key: ctrl(r))
		 separator
		 command(label: 'Remove unused constraint functors'
			 action: proc {$} {Try RemoveUnusedConstraintFunctors} end)
		 separator
		 command(label: 'Build all principles in list'
			 action: proc {$} {Try BuildAllPrinciplesInList} end)
		 separator
		 command(label: 'Quit'
			 action: proc {$} {Try Quit} end
			 key: ctrl(q))
		])
       menubutton(text: 'Options'
		  menu:
                 [
		  checkbutton(label: 'Build principle definition'
			      var: BuildDefFileTkvar)
		  separator
		  command(label: 'Set Oz editor...'
			  action: proc {$}
				     {Try
				      proc {$}
					 GlobalDict.ozEditor :=
					 {Helpers.tkGetS 'XDK: Principle Manager' 'Set Oz editor:' GlobalDict.ozEditor}
				      end}
				  end)
		  command(label: 'Set UL editor...'
			  action: proc {$}
				     {Try
				      proc {$}
					 GlobalDict.ulEditor :=
					 {Helpers.tkGetS 'XDK: Principle Manager' 'Set UL editor:' GlobalDict.ulEditor}
				      end}
				  end)
		  command(label: 'Set XML editor...'
			  action: proc {$}
				     {Try
				      proc {$}
					 GlobalDict.xmlEditor :=
					 {Helpers.tkGetS 'XDK: Principle Manager' 'Set XML editor:' GlobalDict.xmlEditor}
				      end}
				  end)
		 ])
       menubutton(text: 'PrincipleWriter'
		  menu:
                 [checkbutton(label: 'Optimize'
			      var: PWOptimizeTkvar)
		  checkbutton(label: 'Generate setExistsOneNodes'
			      var: PWSeonTkvar)
		  checkbutton(label: 'Apply ad hoc transforms'
			      var: PWAdhocTkvar)])
       menubutton(text: 'Extras'
		  menu:
                 [cascade(label: 'Log'
			  menu: [radiobutton(label: 'inspect'
					     var: LogTkvar
					     val: inspect)
				 radiobutton(label: 'browse'
					     var: LogTkvar
					     val: browse)
				 radiobutton(label: 'stdout'
					     var: LogTkvar
					     val: stdout)])
		  separator
		  checkbutton(label: 'Debug mode'
			      var: DebugTkvar
			      key: ctrl(d))
		 ])]
      MenuW = {TkTools.menubar ToplevelW ToplevelW MenuEntries nil}
   
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      {Tk.batch [
		 %% Main window.
		 grid(MenuW row:0 sticky:nw)
	   
		 grid(LeftFrameW row:1 column:0 sticky:nswe padx:6)
		 grid(RightFrameW row:1 column:1 sticky:nswe padx:6)
	   
		 grid(rowconfigure ToplevelW 1 weight:1)
		 grid(columnconfigure ToplevelW 0 weight:1)
		 grid(columnconfigure ToplevelW 1 weight:1)
	   
		 grid(rowconfigure LeftFrameW 2 weight:1)
		 grid(columnconfigure LeftFrameW 0 weight:1)
	   
		 grid(rowconfigure RightFrameW 3 weight:1)
		 grid(rowconfigure RightFrameW 6 weight:1)
		 grid(columnconfigure RightFrameW 0 weight:1)
		 
		 grid(ListLabelW row:0 column:0 sticky:we)
	   
		 %% Principle filter
		 grid(FilterFrameW row:1 column:0 sticky:nswe)
		 grid(FilterButtonW row:0 column:0 sticky:w padx:4)
		 grid(FilterEntryW row:0 column:1 sticky:we)
		 grid(rowconfigure FilterFrameW 0 weight:1)
		 grid(columnconfigure FilterFrameW 1 weight:1)
	   
		 %% Principle list
		 grid(ListFrameW row:2 column:0 sticky:nswe)
		 grid(ListW row:0 column:0 sticky:nswe)
		 grid(ListScrollW row:0 column:1 sticky:ns)
		 grid(rowconfigure ListFrameW 0 weight:1)
		 grid(columnconfigure ListFrameW 0 weight:1)
	   
		 grid(ListEntryFrameW row:3 column:0 sticky:nswe)
		 grid(ListEntryW row:0 column:0 sticky:we pady:4)
		 grid(rowconfigure ListEntryFrameW 0 weight:1)
		 grid(columnconfigure ListEntryFrameW 0 weight:1)
		 
		 grid(ListButtonsFrameW row:4 column:0 sticky:nswe)
		 grid(ListAddButtonW row:0 column:0 sticky:we padx:4)
		 grid(ListRemoveButtonW row:0 column:1 sticky:we padx:4)
		 grid(rowconfigure ListButtonsFrameW 0 weight:1)
		 grid(columnconfigure ListButtonsFrameW 0 weight:1)
		 grid(columnconfigure ListButtonsFrameW 1 weight:1)
	   
		 %% Principle definition file
		 grid(DefFileFrameW row:0 column:0 sticky:nswe pady:10)
		 grid(DefFileLabelW row:0 column:0 columnspan:2 sticky:we)
		 grid(DefFileEditButtonW row:1 column:0 sticky:w padx:4)
		 grid(DefFileEntryW row:1 column:1 sticky:we)
		 grid(rowconfigure DefFileFrameW 1 weight:1)
		 grid(columnconfigure DefFileFrameW 1 weight:1)
	   
		 %% Principle definition functor
		 grid(DefFunctorFrameW row:1 column:0 sticky:nswe pady:10)
		 grid(DefFunctorLabelW row:0 column:0 columnspan:2 sticky:we)
		 grid(DefFunctorEditButtonW row:1 column:0 sticky:w padx:4)
		 grid(DefFunctorEntryW row:1 column:1 sticky:we)
		 grid(rowconfigure DefFunctorFrameW 1 weight:1)
		 grid(columnconfigure DefFunctorFrameW 1 weight:1)
	   
		 %% Principle constraint functors
		 grid(ConstraintsLabelW row:2 column:0 sticky:we)
	   
		 grid(ConstraintsListFrameW row:3 column:0 sticky:nswe)
		 grid(ConstraintsListW row:0 column:0 sticky:nswe)
		 grid(ConstraintsListScrollW row:0 column:1 sticky:ns)
		 grid(rowconfigure ConstraintsListFrameW 0 weight:1)
		 grid(columnconfigure ConstraintsListFrameW 0 weight:1)
	   
		 grid(ConstraintsEntryFrameW row:4 column:0 sticky:nwse)
		 grid(ConstraintsEditButtonW row:0 column:0 sticky:w padx:4)
		 grid(ConstraintsEntryW row:0 column:1 sticky:we)
		 grid(rowconfigure ConstraintsListFrameW 0 weight:1)
		 grid(columnconfigure ConstraintsEntryFrameW 1 weight:1)
	   
		 %% Other files
		 grid(OtherFilesLabelW row:5 column:0 sticky:we)
	   
		 grid(OtherFilesListFrameW row:6 column:0 sticky:nswe)
		 grid(OtherFilesListW row:0 column:0 sticky:nswe)
		 grid(OtherFilesListScrollW row:0 column:1 sticky:ns)
		 grid(rowconfigure OtherFilesListFrameW 0 weight:1)
		 grid(columnconfigure OtherFilesListFrameW 0 weight:1)
	   
		 grid(OtherFilesEntryFrameW row:7 column:0 sticky:nwse)
		 grid(OtherFilesEditButtonW row:0 column:0 sticky:w padx:4)
		 grid(OtherFilesEntryW row:0 column:1 sticky:we)
		 grid(rowconfigure OtherFilesListFrameW 0 weight:1)
		 grid(columnconfigure OtherFilesEntryFrameW 1 weight:1)
	   
		 grid(BuildFrameW row:8 column:0 columnspan:2 sticky:nswe pady:10)
		 grid(BuildButtonW row:0 column:0 sticky:we)
		 grid(rowconfigure BuildFrameW 0 weight:1)
		 grid(columnconfigure BuildFrameW 0 weight:1)
	   
		 focus(FilterEntryW)
		]}

      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   in
      
      try
	 FilterV1 = if GrammarV=="" then
		       FilterV
		    else
		       FilterV#'|'#{PathV2FilterV GrammarV}
		    end
	 GlobalDict.filter := FilterV1
      in
	 {SetPrinciples {GetPrinciples FilterV1}}
	 {FilterEntryW tk(delete 0 'end')}
	 {FilterEntryW tk(insert 'end' FilterV1)}
      catch E then
	 {HandleException E}
      end
      
   end
end
