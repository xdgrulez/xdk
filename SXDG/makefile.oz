makefile(
   lib: [
	 'BruteForceSearch.ozf'
	 'Externaliser.ozf'
	 'GlobalOracle.ozf'
	 'Helpers.ozf'
	 'KMExternaliser.ozf'
	 'LocalOracle.ozf'
	 'Log.ozf'
	 'MessageParser.ozf'
	 'Oracle.ozf'
	 'OracleProtocol.ozf'
	 'OracleSocket.ozf'
	 'SXDG.ozf'
	 'SXDGExternaliser.ozf'
	 'SXDGGrammarServer.ozf'
	 'XDGExternaliser.ozf'
	 'XDGOracle.ozf'
	]
   bin: ['SXDG.exe']

   clean: ["*~" "#*#" "*.ozf" "*.exe"]

   author: ['mogul:/kuhlmann/marco']
   blurb: 'SXDG'
   mogul: 'mogul:/kuhlmann/sxdg'
   uri: 'x-ozlib://kuhlmann/sxdg'
   version: '0.0.6'
   info_html: '<p>No info yet.</p>'
   )
