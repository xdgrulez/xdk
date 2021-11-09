makefile(
   subdirs: [
	     'Grammar'
	    ]

   lib: [
	 'Helpers.ozf'
	 
	 'ClassesConverter.ozf'
	 'GrammarGenerator.ozf'
	 'SocketProvider.ozf'
	 'SyntaxParser.ozf'
	 'TreesParser.ozf'

	 'SimpleFilter.ozf'
	 'TaggerFilter.ozf'
	 'SuperTaggerFilter.ozf'

	 'xtagserver.ozf'

	 'ClassesConverterTest.oz'
	 'GrammarGeneratorTest.oz'
	 'SocketProviderTest.oz'
	 'SyntaxParserTest.oz'
	 'TreesParserTest.oz'

	 'xtag.prefs'

	 'PTBExamplesExtractor.ozf'
	 'ptbextract.ozf'

	 'PTBExamplesExtractorTest.oz'

	 'lem_evaluation_subset.ozf'
	 'XDK_evaluation_subset.ozf'

	 'lem_evaluation_subset.sh'
	 'XDK_evaluation_subset.sh'
	]

   bin: [
	 'xtagserver.exe'
	 'ptbextract.exe'
	 'lem_evaluation_subset.exe'
	 'XDK_evaluation_subset.exe'
	]
   
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*" "*.ozp"]
   )
