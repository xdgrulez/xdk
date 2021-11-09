makefile(
   subdirs: [
	     'QuadOptimizer'
	     
	     'Examples'
	    ]

   lib: [
	 'Helpers.ozf'

	 'LALRGen.ozf'
	 'TokenizerGen.ozf'

	 'Parser.ozf'
	 'Typer.ozf'
	 'Evaluator.ozf'

	 'ParserTest.oz'
	 'TyperTest.oz'
	 'EvaluatorTest.oz'
	 'QuadOptimizerTest.oz'
	 
	 'pw.ozf'
	]

   bin: [
	 'pw.exe'
	]
   
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
