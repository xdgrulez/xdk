makefile(
   lib: [
	 'AdhocTransforms.ozf'
	 'BottomUpMatch.ozf'
	 'ContextTransform.ozf'
	 'FindVar.ozf'
	 'GornUtils.ozf'
	 'Helpers.ozf'
	 'LazyList.ozf'
	 'LetTransform.ozf'
	 'LiftBoolDotSetTransform.ozf'
	 'MatchHelpers.ozf'
	 'MkTransform.ozf'
	 'PWTreeAccess.ozf'
	 'QDeepener.ozf'
	 'QuadOptimizer.ozf'
	 'QuadTransform.ozf'
	 'RenameTransform.ozf'
	 'TopDownMatch.ozf'
	 'ToSemTreeTransform.ozf'
	 'TrivialTransforms.ozf'
	 'ZeroOrOneTransform.ozf'
	]

   clean: [".#*" "*~" "#*#" "*.ozf" "*.exe" "*.o" "*.so-*" "*.slp*"]
   )
