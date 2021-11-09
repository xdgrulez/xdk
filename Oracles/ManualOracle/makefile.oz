makefile(
   lib: [
	 'Helpers.ozf'
	 
	 'ManualOracle.ozf'
	 'Windows.ozf'
	 
	 'manualoracleserver.ozf'
	]

   bin: [
	 'manualoracleserver.exe'
	]
   
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
