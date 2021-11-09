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

   Pickle(load saveCompressed)

   TreesParser(parse) at 'TreesParser.ozf'

   Helpers(gorn2A isInitial noDoubles getNodesOfTypes
	   fileExists) at 'Helpers.ozf'
export
   Convert
prepare
   ListToRecord = List.toRecord
   RecordToListInd = Record.toListInd
define
   V2A = VirtualString.toAtom
   %%
   fun {Convert}
      TreeAPosAsClassRecTupRec =
      if {Helpers.fileExists 'classes.ozp'} then
	 {Pickle.load 'classes.ozp'}
      else
	 {System.show start#classes}
	 TreesRec#_ = {TreesParser.parse}
	 %%
	 TreeATreeTups = {RecordToListInd TreesRec}
	 TreeAPosAsClassRecTupTups =
	 {Map TreeATreeTups
	  fun {$ TreeA#Tree}
	     Nodes = {Helpers.getNodesOfTypes Tree ['anchor']}
	     PosAs = {Map Nodes
		      fun {$ Node} {V2A Node.label#Node.id} end}
	     PosAClassTups =
	     for I in 1..{Length PosAs} collect:Collect do
		PosA = {Nth PosAs I}
		Tree1 = {InstantiateAnchors Tree PosA PosAs}
		TreePosAs = {GetPosAs Tree1 nil}
		TreeGorns = {GetGorns Tree1 nil}
		ClassNameA#ClassA = {Tree2XDG PosA TreeA Tree1 I PosAs}
		Class = TreePosAs#TreeGorns#ClassNameA#ClassA
	     in
		{Collect PosA#Class}
	     end
	     PosAClassRec = {ListToRecord o PosAClassTups}
	  in
	     TreeA#(PosAs#PosAClassRec)
	  end}
	 TreeAPosAsClassRecTupRec1 =
	 {ListToRecord o TreeAPosAsClassRecTupTups}
      in
	 {Pickle.saveCompressed TreeAPosAsClassRecTupRec1 'classes.ozp' 9}
	 {System.show done}
	 TreeAPosAsClassRecTupRec1
      end
   in
      TreeAPosAsClassRecTupRec
   end
   %%
   fun {InstantiateAnchors Node PosA PosAs}
      case Node
      of o(type: anchor
	   label: PosA1
	   id: IdA ...) then
	 PosA2 = {V2A PosA1#IdA}
      in
	 if PosA2==PosA then
	    o(label: PosA
	      id: IdA
	      features: nil
	      type: adjunction
	      address: Node.address
	      daughters: [o(label: PosA
			    id: ''
			    features: ['headp']
			    type: anchor
			    address: {Append Node.address [1]}
			    daughters: nil)])
	 else
	    o(label: PosA1
	      id: IdA
	      features: ['substp']
	      type: substitution
	      address: Node.address
	      daughters: nil
	      secondary: PosA2)
	 end
      else
	 o(label: Node.label
	   id: Node.id
	   features: Node.features
	   type: Node.type
	   address: Node.address
	   daughters: {Map Node.daughters
		       fun {$ Node}
			  {InstantiateAnchors Node PosA PosAs}
		       end})
      end
   end
   %%
   fun {GetPosAs Node AccPosAs}
      case Node
      of o(label: PosA
	   type: substitution ...) then
	 {Append AccPosAs [PosA]}
      [] o(label: PosA
	   type: foot ...) then
	 {Append AccPosAs [PosA]}
      [] o(label: PosA
	   type: adjunction ...) then
	 AccPosAs1 = {Append AccPosAs [PosA]}
	 PosAs = for Node in Node.daughters append:Append do
		    PosAs1 = {GetPosAs Node AccPosAs1}
		 in
		    {Append PosAs1}
		 end
      in
	 {Append AccPosAs1 PosAs}
      else
	 PosAs = for Node in Node.daughters append:Append do
		    PosAs1 = {GetPosAs Node AccPosAs}
		 in
		    {Append PosAs1}
		 end
      in
	 {Append AccPosAs PosAs}
      end
   end
   %%
   fun {GetGorns Node AccGorns}
      case Node
      of o(address: Gorn
	   type: substitution ...) then
	 {Append AccGorns [Gorn]}
      [] o(address: Gorn
	   type: anchor ...) then
	 {Append AccGorns [Gorn]}
      [] o(address: Gorn
	   type: foot ...) then
	 {Append AccGorns [Gorn]}
      [] o(address: Gorn
	   type: adjunction ...) then
	 AccGorns1 = {Append AccGorns [Gorn]}
	 Gorns = for Node in Node.daughters append:Append do
		    Gorns1 = {GetGorns Node AccGorns1}
		 in
		    {Append Gorns1}
		 end
      in
	 {Append AccGorns1 Gorns}
      else
	 Gorns = for Node in Node.daughters append:Append do
		    Gorns1 = {GetGorns Node AccGorns}
		 in
		    {Append Gorns1}
		 end
      in
	 {Append AccGorns Gorns}
      end
   end
   %%
   fun {GetDeps Tree}
      Nodes = {Helpers.getNodesOfTypes Tree [anchor adjunction substitution foot]}
      Deps = {Map Nodes
	      fun {$ Node}
		 Node.address#Node.type#Node.label#{CondSelect Node secondary noSecondary}
	      end}
   in
      Deps
   end
   %%
   fun {Tree2XDG BaseA TreeA Tree I PosAs1}
      RootNode = Tree
      AnchorNode = {Helpers.getNodesOfTypes Tree [anchor]}.1
      AdjunctionNodes = {Helpers.getNodesOfTypes Tree [adjunction]}   
      %% create mapping from POS PosA to adjunction nodes labeled with
      %% PosA
      AdjunctionPosAIDict = {NewDictionary}
      for Node in AdjunctionNodes do
	 PosA = Node.label
	 I = {CondSelect AdjunctionPosAIDict PosA 0}
      in
	 AdjunctionPosAIDict.PosA := I+1
      end
      AdjunctionPosAIRec = {Dictionary.toRecord o AdjunctionPosAIDict}
      %% create mapping from POS PosA to substitution nodes labeled with
      %% PosA
      SubstitutionNodes = {Helpers.getNodesOfTypes Tree [substitution]}
      SubstitutionPosAIDict = {NewDictionary}
      for Node in SubstitutionNodes do
	 PosA = Node.label
	 I = {CondSelect SubstitutionPosAIDict PosA 0}
      in
	 SubstitutionPosAIDict.PosA := I+1
      end
      SubstitutionPosAIRec = {Dictionary.toRecord o SubstitutionPosAIDict}
      %% get all POSs of the tree
      PosAs = {Helpers.noDoubles {Append
				  {Arity AdjunctionPosAIRec}
				  {Arity SubstitutionPosAIRec}}}
      %% get all nodes of the tree which play a role in the dependency
      %% analysis, i.e. all nodes of type anchor, substitution,
      %% adjunction and foot
      Deps = {GetDeps Tree}
      %% get anchor Dep
      AnchorDep = {Filter Deps
		   fun {$ _#TypeA#_#_} TypeA=='anchor' end}.1
      %% get foot Deps
      FootDeps = {Filter Deps
		  fun {$ _#TypeA#_#_} TypeA=='foot' end}
      %% id dimension
      IDTypeA = if {Helpers.isInitial TreeA} then 's' else 'a' end
      IDInA = {V2A
	       '{"'#RootNode.label#'_'#IDTypeA#'"}'}
      IDOutA = {V2A
		'{'#{FoldL PosAs
		     fun {$ AccV PosA}
			AdjunctionI = {CondSelect AdjunctionPosAIRec PosA 0}
			AdjunctionV = if AdjunctionI==0 then
					 ''
				      else
					 '"'#PosA#'_a"'#
					 if AdjunctionI==1 then
					    '?'
					 else
					    '#[0 '#AdjunctionI#']'
					 end
				      end
			SubstitutionI = {CondSelect SubstitutionPosAIRec PosA 0}
			SubstitutionV = if SubstitutionI==0 then
					   ''
					else
					   '"'#PosA#'_s"'#
					   if SubstitutionI==1 then
					      '!'
					   else
					      '#{'#SubstitutionI#'}'
					   end
					end
		     in
			AccV#AdjunctionV#' '#SubstitutionV#' '
		     end ''}#'}'}
      IDA = {V2A
	     'dim id {in: '#IDInA#'\n'#
	     'out: '#IDOutA#'}\n'}
      %% lp dimension
      LPInA = 'top'
      LPOutA = {V2A
		'{'#
		{FoldL Deps
		 fun {$ AccV Gorn#TypeA#_#_}
		    GornA = {Helpers.gorn2A Gorn}
		 in
		    if {Member TypeA ['substitution' 'adjunction']} then
		       AccV#'"'#GornA#'"'#
		       case TypeA
		       of 'substitution' then '!'
		       [] 'adjunction' then '?'
		       end#' '
		    else
		       AccV
		    end
		 end ''}#'}'}
      LPAnchorA = {V2A
		   '"'#{Helpers.gorn2A AnchorDep.1}#'"'}
      LPFootA = {V2A
		 '{'#
		 {FoldL FootDeps
		  fun {$ AccV Gorn#_#_#_}
		     GornA = {Helpers.gorn2A Gorn}
		  in
		     AccV#'"'#GornA#'" '
		  end ''}#'}'}
      LPWord1A = BaseA
      LPGovern1Dict = {NewDictionary}
      for Gorn#_#_#EntryA in Deps do
	 if {Not EntryA==noSecondary} then
	    GornA = {Helpers.gorn2A Gorn}
	 in
	    LPGovern1Dict.GornA := EntryA
	 end
      end
      LPGovern1AATups = {Dictionary.entries LPGovern1Dict}
      LPGovern1A =
      {V2A
       '{'#{FoldL LPGovern1AATups
	    fun {$ AccV GornA#EntryA}
	       AccV#
	       '"'#GornA#'": {'#EntryA#'} '
	    end ''}#'}'}
      LPA = {V2A
	     'dim lp {in: '#LPInA#'\n'#
	     'out: '#LPOutA#'\n'#
	     'anchor: '#LPAnchorA#'\n'#
	     'foot: '#LPFootA#'\n'#
	     'word1: '#LPWord1A#'\n'#
	     'govern1: '#LPGovern1A#'}\n'}
      %% idlp dimension
      IDLPLinkDict = {NewDictionary}
      for Gorn#TypeA#PosA#_ in Deps do
	 if {Member TypeA ['substitution' 'adjunction']} then
	    GornA = {Helpers.gorn2A Gorn}
	    PosA1 = {V2A
		     PosA#'_'#if TypeA=='substitution' then 's' else 'a' end}
	    PosAs = {CondSelect IDLPLinkDict GornA nil}
	 in
	    IDLPLinkDict.GornA := {Append PosAs [PosA1]}
	 end
      end
      IDLPLinkAAsTups = {Dictionary.entries IDLPLinkDict}
      IDLPLinkA =
      {V2A
       '{'#{FoldL IDLPLinkAAsTups
	    fun {$ AccV GornA#PosAs}
	       AccV#
	       '"'#GornA#'":'#'{'#{FoldL PosAs
				   fun {$ AccV PosA}
				      AccV#'"'#PosA#'" '
				   end ''}#'}'#' '
	    end ''}#'}'}
      IDLPA = {V2A
	       'dim idlp {link: '#IDLPLinkA#'}\n'}
      %% lex dimension
      LexWordA = AnchorNode.label
      LexA = {V2A
	      'dim lex {word: '#LexWordA#'\n'#
	      'tree: "'#TreeA#'"}\n'}
      %%
      ClassArgsA = {V2A
		    {FoldL PosAs1
		     fun {$ AccV PosA}
			AccV#PosA#' '
		     end ''}}
      XDGClassNameA = {V2A '"'#TreeA#'-'#I#'"'}
      XDGClassA = {V2A
		   'defclass '#XDGClassNameA#' '#ClassArgsA#'{\n'#LexA#IDA#LPA#IDLPA#'}\n'}
   in
      XDGClassNameA#XDGClassA
   end
end
