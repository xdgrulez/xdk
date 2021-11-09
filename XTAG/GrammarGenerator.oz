%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   Property(put)
   
   Open(file)
   
   Helpers(a2Gorn collect fileV2TmpUrlV gorn2A multiply noDoubles   
	   putV toEntry) at 'Helpers.ozf'

   SyntaxParser(parse) at 'SyntaxParser.ozf'
   TreesParser(parse) at 'TreesParser.ozf'
   ClassesConverter(convert) at 'ClassesConverter.ozf'

   SimpleFilter(make) at 'SimpleFilter.ozf'
   TaggerFilter(make) at 'TaggerFilter.ozf'
   SuperTaggerFilter(make) at 'SuperTaggerFilter.ozf'
export
   Generate
prepare
   RecordMap = Record.map
define
   A2S = Atom.toString
   V2A = VirtualString.toAtom
   %%
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%
   %%
   fun {BaseA2TreeAAnchorsTups BaseA BaseAs I EntryA EntryAs EntryABaseAsRec SyntaxRec FamiliesRec PruneB FilterProc}
      EntryRecs = {CondSelect SyntaxRec EntryA nil}
      TreeAAnchorsTups =
      for EntryRec in EntryRecs append:AppendFor do
	 if PruneB andthen
	    {Not {All EntryRec.anchors
		  fun {$ _#EntryA1} {Member EntryA1 EntryAs} end}} then
	    skip
	 else
	    FamilyAs TreesAs
	    {List.partition EntryRec.trees
	     fun {$ TreeA}
		TreeS = {A2S TreeA}
	     in
		TreeS.1==&T
	     end FamilyAs TreesAs}
	    FamilyTreeAs = for FamilyA in FamilyAs append:AppendFor do
			      TreeAs = FamiliesRec.FamilyA
			   in
			      {AppendFor TreeAs}
			   end
	    TreeAs = {Append FamilyTreeAs TreesAs}
	    Anchors = EntryRec.anchors
	    PosABaseATupss = {Map Anchors
			      fun {$ PosA#EntryA1}
				 BaseAs1 = EntryABaseAsRec.EntryA1
				 PosABaseATups = {Map BaseAs1
						  fun {$ BaseA} PosA#BaseA end}
			      in
				 PosABaseATups
			      end}
	    PosABaseATupss1 = {Helpers.multiply PosABaseATupss}
	    TreeAAnchorsTups =
	    for TreeA in TreeAs collect:Collect do
	       for PosABaseATups in PosABaseATupss1 do
		  {Collect TreeA#PosABaseATups}
	       end
	    end
	 in
	    {AppendFor TreeAAnchorsTups}
	 end
      end
      TreeAAnchorsTups1 = {Helpers.noDoubles TreeAAnchorsTups}
      TreeAAnchorsTups2 = {FilterProc BaseA BaseAs I TreeAAnchorsTups1}
   in
      TreeAAnchorsTups2
   end
   %%
   fun {Generate BaseAs PruneB FilterA}
      SyntaxRec = {SyntaxParser.parse}
      _#FamiliesRec = {TreesParser.parse}
      TreeAPosAsClassRecTupRec = {ClassesConverter.convert}
      FilterProc = case FilterA
		   of none then
		      fun {$ _ _ _ TreeAAnchorsTups}
			 TreeAAnchorsTups
		      end
		   [] simple then
		      {SimpleFilter.make BaseAs}
		   [] tagger then
		      {TaggerFilter.make BaseAs}
		   [] supertagger then
		      TreeAPosARec =
		      {RecordMap TreeAPosAsClassRecTupRec
		       fun {$ PosAs#_} PosAs.1 end}
		   in
		      {SuperTaggerFilter.make BaseAs TreeAPosARec}
		   end
      %%
      EntryABaseAsDict = {NewDictionary}
      EntryAs =
      for BaseA in BaseAs collect:Collect do
	 EntryA = {Helpers.toEntry BaseA}
      in
	 EntryABaseAsDict.EntryA := {Append 
				     {CondSelect EntryABaseAsDict EntryA nil}
				     [BaseA]}
	 {Collect EntryA}
      end
      EntryABaseAsRec = {Dictionary.toRecord o EntryABaseAsDict}
      %%
      Tups =
      for BaseA in BaseAs EntryA in EntryAs I in 1..{Length BaseAs} append:Append do
	 TreeAAnchorsTups = {BaseA2TreeAAnchorsTups BaseA BaseAs I EntryA EntryAs EntryABaseAsRec SyntaxRec FamiliesRec PruneB FilterProc}
	 Tups =
	 for TreeA#Anchors in TreeAAnchorsTups collect:Collect do
	    AnchorPosA = Anchors.1.1
	    _#PosAClassRec = TreeAPosAsClassRecTupRec.TreeA
	    AnchorPosA1 = if {HasFeature PosAClassRec AnchorPosA} then
			     AnchorPosA
			  else
			     'P'
			  end
	    UseClassA = {V2A
			 'defentry {\n'#(PosAClassRec.AnchorPosA1).3#' {'#
			 {FoldL Anchors
			  fun {$ AccV PosA#EntryA}
			     AccV#PosA#': "'#EntryA#'" '
			  end ''}#'}}\n'}
	    ClassA = (PosAClassRec.AnchorPosA1).4
	    EntryAs = {Map Anchors
		       fun {$ _#EntryA} EntryA end}
	    PosAs = (PosAClassRec.AnchorPosA1).1
	    Gorns = (PosAClassRec.AnchorPosA1).2
	 in
	    {Collect PosAs#Gorns#EntryAs#UseClassA#ClassA}
	 end
      in
	 {Append Tups}
      end
      %%
      UseClassAs = {Map Tups
		    fun {$ _#_#_#UseClassA#_} UseClassA end}
      UseClassAs1 = {Helpers.noDoubles UseClassAs}
      ClassAs = {Helpers.collect
		 Tups
		 fun {$ X} [X.5] end
		 fun {$ A} A end}
      SecondaryAs = {Helpers.collect
		     Tups
		     fun {$ X} X.3 end
		     fun {$ A} A end}
      AllPosAs = {Helpers.collect
		  Tups
		  fun {$ X} X.1 end
		  fun {$ A} A end}
      AllGorns = {Helpers.collect
		  Tups
		  fun {$ X} {Map X.2 Helpers.gorn2A} end
		  fun {$ A} {Helpers.a2Gorn A} end}
      %%
      HeaderV =  'usedim id\n'#
      'usedim lp\n'#
      'usedim idlp\n'#
      'usedim lex\n'#
      '%%\n'#
      'defdim id {\n'#
      'deftype "id.label" {'#{FoldL AllPosAs
			      fun {$ AccV PosA}
				 AccV#
				 '"'#PosA#'_a"'#' '#
				 '"'#PosA#'_s"'#' '
			      end ''}#'}\n'#
      'deflabeltype "id.label"\n'#
      'defentrytype {in: iset("id.label")\n'#
      'out: valency("id.label")}\n'#
      'useprinciple "principle.graph1Constraints" {dims {D: id}}\n'#
      'useprinciple "principle.graph1Dist" {dims {D: id}}\n'#
      'useprinciple "principle.tree" {dims {D: id}}\n'#
      'useprinciple "principle.in" {dims {D: id}}\n'#
      'useprinciple "principle.out" {dims {D: id}}\n'#
      'useprinciple "principle.xTAGRoot" {dims {D: id}}\n'#
      'output "output.latex1"\n'#
      'output "output.pretty1"\n'#
      '}\n'#
      '%%\n'#
      'defdim lp {\n'#
      'deftype "lp.label" {'#{FoldL AllGorns
			      fun {$ AccV Gorn}
				 GornA = {Helpers.gorn2A Gorn}
			      in
				 AccV#'"'#GornA#'"'#' '
			      end ''}#'}\n'#
      'deftype "lp.word" {'#{FoldL SecondaryAs
			     fun {$ AccV SecondaryA}
				AccV#'"'#SecondaryA#'" '
			     end ''}#'}\n'#
      'deflabeltype "lp.label"\n'#
      'defentrytype {in: iset("lp.label")\n'#
      'out: valency("lp.label")\n'#
      'word1: "lp.word"\n'#
      'govern1: vec("lp.label" iset("lp.word"))\n'#
      'anchor: "lp.label"\n'#
      'foot: set("lp.label")}\n'#
      'useprinciple "principle.graph1Constraints" {dims {D: lp}}\n'#
      'useprinciple "principle.graph1Dist" {dims {D: lp}}\n'#
      'useprinciple "principle.tree" {dims {D: lp}}\n'#
      'useprinciple "principle.in" {dims {D: lp}}\n'#
      'useprinciple "principle.out" {dims {D: lp}}\n'#
      'useprinciple "principle.government" {dims {D: lp}\n'#
      'args {Agr2: _.D.entry.word1\n'#
      'Govern: ^.D.entry.govern1}}\n'#
      'useprinciple "principle.xTAG" {dims {D: lp}\n'#
      'args {Anchor: _.D.entry.anchor\n'#
      'Foot: _.D.entry.foot}}\n'#
      'output "output.latex1"\n'#
      'output "output.pretty1"\n'#
      '}\n'#
      '%%\n'#
      'defdim idlp {\n'#
      'defentrytype {link: vec("lp.label" set("id.label"))}\n'#
      'useprinciple "principle.xTAGLinking" {dims {D1: id D2: lp D3: idlp}\n'#
      'args {Link: ^.D3.entry.link}}\n'#
      'useprinciple "principle.xTAGRedundant" {dims {D1: id D2: lp}\n'#
      'args {Anchor: _.D2.entry.anchor\n'#
      'Foot: _.D2.entry.foot}}\n'#
      'output "output.latex1"\n'#
      'output "output.pretty1"\n'#
      '}\n'#
      '%%\n'#
      'defdim lex {\n'#
      'defentrytype {word: string\n'#
      'tree: string}\n'#
      'useprinciple "principle.entries" {}\n'#
      'output "output.allDags1"\n'#
      'output "output.allLatexs1"\n'#
      'output "output.xTAGDerivation"\n'#
      'useoutput "output.allDags1"\n'#
      'useoutput "output.xTAGDerivation"\n'#
      '}\n'
      ClassV = {FoldL ClassAs
		fun {$ AccV ClassA}
		   AccV#ClassA#'\n'
		end ''}
      UseClassV = {FoldL UseClassAs1
		   fun {$ AccV UseClassA}
		      AccV#UseClassA#'\n'
		   end ''}
      GrammarV = HeaderV#ClassV#UseClassV
      %%
      GrammarUrlV = {Helpers.fileV2TmpUrlV 'xtag.ul'}
      {Helpers.putV GrammarV GrammarUrlV}
   in
      GrammarV
   end
end
