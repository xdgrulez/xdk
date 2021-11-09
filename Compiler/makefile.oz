makefile(
   subdirs: [
	     'Lattices'
	     'UL'
	     'XML'
	    ]

   lib: [
	 'Helpers.ozf'
	 
	 'Compiler.ozf'
	 'Converter.ozf'
	 'Encoder.ozf'
	 'ILSyntax.ozf'
	 'LatticeMaker.ozf'
	 'Merger.ozf'
	 'NodesCompiler.ozf'
	 'SyntaxChecker.ozf'
	 'TypeChecker.ozf'
	 'TypeCollector.ozf'

	 'CompilerTest.oz'
	 'EncoderTest.oz'
	 'SyntaxCheckerTest.oz'
	 'TypeCheckerTest.oz'
	 'TypeCollectorTest.oz'
	]
		   	     
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
