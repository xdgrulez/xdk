makefile(
   lib: [
	 'Helpers.ozf'

	 'IL2XML.ozf'
	 'Parser.ozf'
	 'XML2IL.ozf'

	 'IL2XMLTest.oz'
	 'ParserTest.oz'
	 'XML2ILTest.oz'
	 'xdk.dtd'
	]
		   	     
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
