makefile(
   subdirs:
      [
       'DaVinci'
      ]

   lib: [
	 'CLLS2Lits.ozf'
	 'Parser.ozf'
	 
	 'CLLS2LitsTest.oz'
	 'ParserTest.oz'
	]
		   	     
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
