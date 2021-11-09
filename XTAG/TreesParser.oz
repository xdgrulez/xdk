%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)
   Inspector(inspect)

   Open(file text)
   Pickle(load saveCompressed)
   
   TokenizerGen(newTokenizer) at '../Compiler/UL/TokenizerGen.ozf'

   Helpers(fileExists) at 'Helpers.ozf'
export
   Parse
require
   LALRGen(makeLALR) at '../Compiler/UL/LALRGen.ozf'
   System(show)
prepare
   ListDrop = List.drop
   ListMapInd = List.mapInd
   S2A = String.toAtom
   %%
   {System.show 'generating XTAG Trees parser'}
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<int>'
		'(' ')' ':'
	       ]
      start  : 'Node'
      rules  :
	 [
	  rule(head:'Node' body:['(' 'Label' '*'('Node') ')']
	       action:node(2 3))
	  rule(head:'Node' body:['Label'] 
	       action:node(1))
	  
	  rule(head:'Label' body:['<id>' '*'('Feature')]
	       action:label(1 2))
	  
	  rule(head:'Feature' body:[':' '<id>']
	       action:feature(2))
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   {System.show 'generating XTAG Trees parser done'}
define
   A2S = Atom.toString
   %%
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 ['(' ')' ':']
      eolComments:
	 nil
      balancedComments:
	 nil
      includes:
	 nil
      keywords:
	 nil)}
   %%
   fun {Clean S}
      case S
      of nil then nil
      [] 6|S1 then &e|{Clean S1}
      [] Ch|S1 then Ch|{Clean S1}
      end
   end
   %%
   fun {Parsed2Tree Node Gorn}
      LabelS = {A2S Node.sem.1.sem.1.sem}
      LabelSs = {String.tokens LabelS &_}
      LabelA = {S2A LabelSs.1}
      IDA = if {Length LabelSs}==2 then
	       {S2A {Nth LabelSs 2}}
	    else
	       ''
	    end
      FeatureAs = {Map Node.sem.1.sem.2.sem
		   fun {$ Feature}
		      Feature.sem.1.sem
		   end}
      TypeA = if LabelA=='e' then
		 'empty'
	      elseif {Member LabelA ['by' 'for' 'of' 'to']} then
		 'terminal'
	      else
		 if {Member 'headp' FeatureAs} then
		    'anchor'
		 elseif {Member 'footp' FeatureAs} then
		    'foot'
		 elseif {Member 'substp' FeatureAs} then
		    'substitution'
		 elseif {Member 'NA' FeatureAs} then
		    'na'
		 else
		    'adjunction'
		 end
	      end
      Daughters = if {HasFeature Node.sem 2} then
		     Node.sem.2.sem
		  else
		     nil
		  end

      Node1 = o(label: LabelA
		id: IDA
		features: FeatureAs
		type: TypeA
		address: Gorn
		daughters: {ListMapInd Daughters
			    fun {$ I Node}
			       {Parsed2Tree Node {Append Gorn [I]}}
			    end})
      Node2 =
      case Node1
      of o(daughters: [o(label: LabelA1 ...)] ...) andthen
	 {Member LabelA1 ['by' 'for' 'of' 'to']} then
	 o(label: Node1.label
	   id: Node1.id
	   features: ['substp']
	   type: substitution
	   address: Node1.address
	   daughters: nil)
      else
	 Node1
      end
   in
      Node2
   end
   %%
   class TextFileK from Open.file Open.text end   
   %%
   fun {ParseTreenames TreenamesV}
      TextFileO = {New TextFileK init(url: TreenamesV)}
      TreenamesDict = {NewDictionary}
      proc {Read I}
	 S = {TextFileO getS($)}
      in
	 if {Not S==false} then
	    TreeA = {S2A S}
	 in
	    TreenamesDict.I := TreeA
	    {Read I+1}
	 end
      end
      {Read 1}
      TreenamesRec = {Dictionary.toRecord o TreenamesDict}
   in
      TreenamesRec
   end
   %%
   fun {ParseTrees TreesV TreenamesV}
      TreenamesRec = {ParseTreenames TreenamesV}
      %%
      TextFileO = {New TextFileK init(url: TreesV)}
      TreesDict = {NewDictionary}
      proc {Read I}
	 S = {TextFileO getS($)}
      in
	 if {Not S==false} then
	    S1 = {Clean S}
	    Tokenized = {Tokenizer.fromString S1}
	    Parsed = {Parser Tokenized}
	    Tree = {Parsed2Tree Parsed nil}
	    TreeA = TreenamesRec.I
	 in
	    TreesDict.TreeA := Tree
	    {Read I+1}
	 end
      end
      {Read 1}
   in
      TreesDict
   end
   %%
   fun {ParseTreefams TreefamsV}
      TextFileO = {New TextFileK init(url: TreefamsV)}
      FamiliesDict = {NewDictionary}
      proc {Read}
	 S = {TextFileO getS($)}
      in
	 if {Not S==false} then
	    Ss = {String.tokens S & }
	    FamilyS = Ss.1
	    FamilyA = {S2A FamilyS}
	    TreeSs = {ListDrop Ss 2}
	    TreeAs = {Map TreeSs S2A}
	 in
	    FamiliesDict.FamilyA := TreeAs
	    {Read}
	 end
      end
      {Read}
   in
      FamiliesDict
   end
   %%
   fun {Parse}
      TreesRec#FamiliesRec =
      if {Helpers.fileExists 'trees.ozp'} andthen
	 {Helpers.fileExists 'families.ozp'} then
	 TreesRec1 = {Pickle.load 'trees.ozp'}
	 FamiliesRec1 = {Pickle.load 'families.ozp'}
      in
	 TreesRec1#FamiliesRec1
      else
	 {System.show start#'trees'}
	 %%
	 FamiliesDict = {ParseTreefams 'Grammar/treefams.dat'}
	 TreesDict = {ParseTrees 'Grammar/xtag.trees.dat' 'Grammar/treenames.dat'}
	 %%
	 for PosA in ['Conj' 'D' 'PL' 'Punct' 'V'] do
	    TreeA = {VirtualString.toAtom alpha#PosA}
	 in
	    TreesDict.TreeA := o(label: PosA
				 id: ''
				 features: ['headp']
				 type: 'anchor'
				 address: nil
				 daughters: nil)
	 end
	 %%
	 TreesRec = {Dictionary.toRecord o TreesDict}
	 {Pickle.saveCompressed TreesRec 'trees.ozp' 9}
	 %%
	 FamiliesRec = {Dictionary.toRecord o FamiliesDict}
	 {Pickle.saveCompressed FamiliesRec 'families.ozp' 9}
	 {System.show done}
      in
	 TreesRec#FamiliesRec
      end
   in
      TreesRec#FamiliesRec
   end
end
