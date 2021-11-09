makefile(
   version: '1.9'
   lib: [
	 'Select.ozf'
	 'SelectFD.so'
	 'SelectFS.so'
	 'SelectUnion.so'
	 'SelectInter.so'
	 'SeqUnion.so'
	 'SelectThe.so'
	 'SeqSelect.so'
	]
   depends :
      local L=['mozart_cpi_extra.hh'] in
	 o(
	    'SelectFD.so'    : L
	    'SelectFS.so'    : L
	    'SelectUnion.so' : L
	    'SelectInter.so' : L
	    'SeqUnion.so'    : L
	    'SelectThe.so'   : L
	    'SeqSelect.so'   : L)
      end
   doc     : [ 'index.html' ]
   author  : ['mogul:/duchier/denys' 'mogul:/debusmann/ralph']
   blurb   : "implements the selection constraint e.g. S={Select.fs [S1 ... Sn] I}"
   categories : [cp]
   
   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
