makefile(
   lib: [
	 'Helpers.ozf'

	 'IL2UL.ozf'
	 'LALRGen.ozf'
	 'Parser.ozf'
	 'TokenizerGen.ozf'
	 'UL2IL.ozf'

	 'IL2ULTest.oz'
	 'UL2ILTest.oz'
	 'ParserTest.oz'
	]
		   	     
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
