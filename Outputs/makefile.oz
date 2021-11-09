makefile(
   subdirs: [
	     'Lib'
	    ]

   lib: [
	 'Helpers.ozf'
	 
	 'Decode.ozf'
	 'Pretty.ozf'
	 'Edges.ozf'
	 'Index2Pos.ozf'
	 
	 'Outputs.ozf'

	 'outputs.xml'
	]

   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
