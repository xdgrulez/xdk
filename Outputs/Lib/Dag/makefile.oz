makefile(
   subdirs: [
	     'NewTkDAG'
	    ]
   
   lib: [
	 'Helpers.ozf'

	 'Dag.ozf'
	]

   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
