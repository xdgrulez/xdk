%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Open(file text)
   OS(system)
   
   Helpers(toEntry fileV2TmpUrlV putV) at 'Helpers.ozf'

   TokenizerGen(newTokenizer) at '../Compiler/UL/TokenizerGen.ozf'
   LALRGen(makeLALR) at '../Compiler/UL/LALRGen.ozf'
export
   Compare
require
   System(show)
prepare
   ListTake = List.take
define
   A2S = Atom.toString
   %%
   S2A = String.toAtom
   %%
   V2A = VirtualString.toAtom
   %%
   BS2S = ByteString.toString
   %%
   fun {BS2A BS} {S2A {BS2S BS}} end
   %%
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 ['(' ')']
      eolComments:
	 nil
      balancedComments:
	 nil
      includes:
	 nil
      keywords:
	 nil)}
   %%
%   {System.show 'generating lem derivation tree parser'}
   GrammarRec =
   grammar(
      tokens : [
		'<dstring>'
		'(' ')'
	       ]
      start  : 'Tree'
      rules  :
	 [
	  rule(head:'Tree' body:['(' 'Node' '*'('Tree') ')']
	       action:tree(2 3))
	  rule(head:'Tree' body:['Node']
	       action:tree(1))
	  
	  rule(head:'Node' body:['<dstring>']
	       action:node(1))
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
%   {System.show 'generating lem derivation tree parser done'}
   %%
   class TextFileK from Open.file Open.text end   
   %%
   fun {CleanLemDerivationS S}
      case S
      of nil then nil
      [] &_|&0|S1 then {CleanLemDerivationS S1}
      [] &_|&1|S1 then {CleanLemDerivationS S1}
      [] &_|&2|S1 then {CleanLemDerivationS S1}
      [] &_|&q|S1 then {CleanLemDerivationS S1}
      [] &_|&r|S1 then {CleanLemDerivationS S1}
      [] &_|&w|S1 then {CleanLemDerivationS S1}
      [] Ch|S1 then Ch|{CleanLemDerivationS S1}
      end
   end
   %%
   fun {ReadLemDerivationSs UrlV}
      TextFileO = {New TextFileK init(url: UrlV)}
      fun {Read AccSs}
	 S = {TextFileO getS($)}
      in
	 if S==false then
	    AccSs
	 else
	    S1 = {CleanLemDerivationS S}
	 in
	    {Read {Append AccSs [S1]}}
	 end
      end
      Ss = {Read nil}
      {TextFileO close}
   in
      Ss
   end
   %%
   fun {ReadXDKDerivationSs UrlV}
      TextFileO = {New TextFileK init(url: UrlV)}
      fun {Read AccSs}
	 S = {TextFileO getS($)}
      in
	 if S==false then
	    AccSs
	 else
	    {Read {Append AccSs [S]}}
	 end
      end
      Ss = {Read nil}
      {TextFileO close}
   in
      Ss
   end
   %%
   fun {Parsed2Tree Parsed}
      Node = {BS2A Parsed.sem.1.sem.1.sem}
      Daughters = if {Not {HasFeature Parsed.sem 2}} then
		     nil
		  else
		     {Map Parsed.sem.2.sem Parsed2Tree}
		  end
   in
      o(node: Node
	daughters: Daughters)
   end
   fun {S2Tree S}
      Ss = {String.tokens S & }
      Ss1 = {Map Ss
	     fun {$ S}
		if S=="(" orelse S==")" then
		   S
		else
		   '"'#S#'"'
		end
	     end}
      S1 = {VirtualString.toString
	    {FoldL Ss1
	     fun {$ AccV S} AccV#S#' ' end ''}}
      Parsed = {Parser {Tokenizer.fromString S1}}
      Tree = {Parsed2Tree Parsed}
      A = {V2A S1}
   in
      A#Tree
   end
   %%
   fun {TreeEqual Tree1 Tree2}
      Node1 = Tree1.node
      Node2 = Tree2.node
      Daughters1 = {CondSelect Tree1 daughters nil}
      Daughters2 = {CondSelect Tree2 daughters nil}
   in
      Node1==Node2 andthen
      {All Daughters1
       fun {$ Daughter1}
	  DaughterNode1 = Daughter1.node
       in
	  {Length
	   {Filter Daughters2
	    fun {$ Daughter2}
	       DaughterNode2 = Daughter2.node
	    in
	       DaughterNode1==DaughterNode2 andthen
	       {TreeEqual Daughter1 Daughter2}
	    end}}==1
       end}
   end
   %%
   fun {NodeOLss2V NodeOLss}
      Vs =
      {Map NodeOLss
       fun {$ NodeOLs}
	  RootOL = {CondSelect
		    {Filter NodeOLs
		     fun {$ NodeOL} NodeOL.id.model.mothers==nil end} 1 noRoot}
	  fun {Traverse NodeOL}
	     LabelV = if NodeOL.id.model.labels==nil then
			 ''
		      else
			 LabelA = NodeOL.id.model.labels.1
			 LabelS = {A2S LabelA}
		      in
			 '<'#{ListTake LabelS {Length LabelS}-2}#'>'
		      end
	  in
	     if NodeOL.id.model.daughters\=nil then '( ' else '' end#
	     NodeOL.lex.entry.tree#'['#{Helpers.toEntry NodeOL.lex.entry.word}#']'#LabelV#
	     if NodeOL.id.model.daughters==nil then
		''
	     else
		{FoldL NodeOL.id.model.daughters
		 fun {$ AccV I}
		    NodeOL1 = {Nth NodeOLs I}
		 in
		    AccV#' '#{Traverse NodeOL1}
		 end ''}
	     end#if NodeOL.id.model.daughters\=nil then ' )' else '' end
	  end
	  V = {Traverse RootOL}
       in
	  V
       end}
      V = {FoldL Vs
	   fun {$ AccV V} AccV#V#'\n' end ''}
   in
      V
   end
   %%
   fun {Compare NodeOLss BaseAs FilterA}
      EntryAs = {Map BaseAs Helpers.toEntry}
      %%
      XDKV = {NodeOLss2V NodeOLss}
      XDKSolutionsUrlV = {Helpers.fileV2TmpUrlV 'XDKSolutions.txt'}
      XDKFileO = {New Open.file init(name: XDKSolutionsUrlV
				     flags: [create truncate write text])}

      {XDKFileO write(vs: XDKV)}
      {XDKFileO close}
      %%
      EntryV = {FoldL EntryAs
		fun {$ AccV EntryA} AccV#EntryA#' ' end ''}
      RunparserA =
      case FilterA
      of none then 'runparser'
      [] simple then 'runparser +n'
      [] tagger then 'runparser +n -df $LEM/bin/tagger_filter'
      end
      LemSolutionsUrlV = {Helpers.fileV2TmpUrlV 'LemSolutions.txt'}
      _ = {OS.system 'echo "'#EntryV#'" | '#RunparserA#' | print_deriv -d >'#LemSolutionsUrlV}
      %%
      LemSs = {ReadLemDerivationSs LemSolutionsUrlV}
      LemATreeTups = {Map LemSs S2Tree}
      XDKSs = {ReadXDKDerivationSs XDKSolutionsUrlV}
      XDKATreeTups = {Map XDKSs S2Tree}
      %%
      LemOnlyATreeTups =
      {Filter LemATreeTups
       fun {$ _#LemTree}
	  {All XDKATreeTups
	   fun {$ _#XDKTree}
	      {Not {TreeEqual LemTree XDKTree}}
	   end}
       end}
      XDKOnlyATreeTups =
      {Filter XDKATreeTups
       fun {$ _#XDKTree}
	  {All LemATreeTups
	   fun {$ _#LemTree}
	      {Not {TreeEqual XDKTree LemTree}}
	   end}
       end}
      %%
      ComparisonV =
      'Lem solutions '#{Length LemATreeTups}#'\n'#
      'XDK solutions '#{Length XDKATreeTups}#'\n'#
      '\nLem only\n'#
      {FoldL LemOnlyATreeTups
       fun {$ AccV A#_} AccV#A#'\n' end ''}#
      '\nXDK only\n'#
      {FoldL XDKOnlyATreeTups
       fun {$ AccV A#_} AccV#A#'\n' end ''}
      ComparisonUrlV = {Helpers.fileV2TmpUrlV 'Comparison.txt'}
      {Helpers.putV ComparisonV ComparisonUrlV}
      %%
      Rec = o(lemATreeTups: LemATreeTups
	      xDKATreeTups: XDKATreeTups
	      lemOnlyATreeTups: LemOnlyATreeTups
	      xDKOnlyATreeTups: XDKOnlyATreeTups)
   in
      Rec
   end
end
