makefile(
   subdirs: [
	     'Principles'
	    ]

   lib: [
	 'Helpers.ozf'

	 'Solver.ozf'
	]
   
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
