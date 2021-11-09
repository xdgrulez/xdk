makefile(
   subdirs: [
	     'Parsers'
	    ]
   lib: [
	 'Helpers.ozf'
	 'Propagators.ozf'
	 'ScriptMaker.ozf'
	 'Searcher.ozf'
	 'SolutionViewer.ozf'
	 
	 'explore.ozf'
	 'solve.ozf'
	 'view.ozf'

	 'test.csp'
	 'test.sol1'
	]
   bin: [
	 'explore.exe'
	 'solve.exe'
	 'view.exe'
	]

   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
