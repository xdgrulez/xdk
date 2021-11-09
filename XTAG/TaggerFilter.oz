%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Inspector(inspect)

   Open(file text)
   OS(system)
   
   Regex at 'x-oz://contrib/regex'

   Helpers(fileV2TmpUrlV getSuffix toEntry) at 'Helpers.ozf'
export
   Make
prepare
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
define
   S2A = String.toAtom
   %%
   PTBPOSAXTAGPOSAsRec =
   o('CC': ['Conj']   % coordinating conjunction
     'CD': ['D']      % cardinal number
     'DT': ['D']      % determiner
     'EX': ['N']      % existential there
     'FW': ['N']      % foreign word
     'IN': ['P']      % preposition or subordinating conjunction
     'JJ': ['A']      % adjective
     'JJR': ['A']     % adjective, comparative
     'JJS': ['A']     % adjective, superlative
     'LS': ['Punct']  % list item marker
     'MD': ['V']      % modal
     'NN': ['N']      % noun, singular or mass
     'NNS': ['N']     % noun, plural
     'NNP': ['N']     % proper noun, singular
     'NNPS': ['N']    % proper noun, plural
     'PDT': ['D']     % predeterminer
     'POS': ['G']     % possessive ending
     'PRP': ['N']     % personal pronoun
     'PRP$': ['D']    % possessive pronoun
     'RB': ['Ad']     % adverb
     'RBR': ['Adv']   % adverb, comparative
     'RBS': ['Adv']   % adverb, superlative
     'RP': ['PL']     % particle
     'TO': ['V' 'P' ] % to
     'UH': ['I']      % interjection
     'VB': ['V']      % verb, base form
     'VBD': ['V']     % verb, past tense
     'VBG': ['V']     % verb, gerund/present particle
     'VBN': ['V']     % verb, past participle
     'VBP': ['V']     % verb, sing. present, non-3d
     'VBZ': ['V']     % verb, 3rd person sing. present
     'WDT': ['N']     % wh-determiner
     'WP': ['N']      % wh-pronoun
     'WP$': ['D' 'N'] % possessive wh-pronoun
     'WRB': ['Ad']    % wh-adverb
     %%
     ',': ['Punct']
     '.': ['Punct']
     '$': ['Punct']
     '``': ['Punct']
     '\'\'': ['Punct']
     ':': ['Punct']
     ')': ['Punct']
     '(': ['Punct']
     '#': ['Punct']
     '-RRB-': ['Punct']
     '-LRB-': ['Punct'])
   %%
   DefaultPosATreeATups =
   ['N'#'alphaNXN'
    'N'#'alphaN'
    'N'#'betaNn']
   %%
   TaggerOutputUrlV = {Helpers.fileV2TmpUrlV 'taggerOutput.txt'}
   %%
   class TextFileK from Open.file Open.text end   
   %%
   fun {RegexMatch V RE}
      {Not {Regex.search RE V}==false}
   end
   %%
   fun {Make BaseAs}
      EntryAs = {Map BaseAs Helpers.toEntry}
      %%
      WhpatRE = {Regex.make 'wh[a-z]*'}
      HasWhBCe = {NewCell false}
      IHasWhBTups =
      {ListMapInd EntryAs
       fun {$ I EntryA}
	  if {RegexMatch EntryA WhpatRE} then
	     HasWhBCe := true
	  end
	  HasWhB = {Access HasWhBCe}
       in
	  I#HasWhB
       end}
      IHasWhBRec = {ListToRecord o IHasWhBTups}
      %%
      EntryV =
      {FoldL EntryAs
       fun {$ AccV EntryA} AccV#' '#EntryA end ''}
      _ = {OS.system 'echo "'#EntryV#'" | '#'$MXPOST/mxpost $MXPOST/tagger.project/ >'#TaggerOutputUrlV}
      TextFileO = {New TextFileK init(url: TaggerOutputUrlV)}
      TaggedS = {TextFileO getS($)}
      {TextFileO close}
      TaggedSs = {String.tokens TaggedS & }
      IXTAGPOSAsTups =
      {ListMapInd TaggedSs
       fun {$ I TaggedS}
	  PTBPOSS = {Helpers.getSuffix TaggedS &_}
	  PTBPOSA = {S2A PTBPOSS}
	  XTAGPOSAs = PTBPOSAXTAGPOSAsRec.PTBPOSA
       in
	  I#XTAGPOSAs
       end}
      IXTAGPOSAsRec = {ListToRecord o IXTAGPOSAsTups}
      %%
      FilterProc =
      fun {$ BaseA BaseAs I TreeAAnchorsTups}
	 WhtreepatRE = {Regex.make 'alphaW'}
	 DeletePatsRE = {Regex.make
			 'alphaG'#'|'#
			 'alphaWA'#'|'#
			 'nx0nx1ARB'#'|'#
			 'nx0ARB'#'|'#
			 'nx0A1'#'|'#
			 's0Pnx1'#'|'#
			 'alphaI'#'|'#
			 'betaI'#'|'#
			 'betaNc'#'|'#
			 'Vtransn'#'|'#
			 'Vintransn'#'|'#
			 'alphaInv'}
	 TreeAAnchorsTups1 =
	 {Filter TreeAAnchorsTups
	  fun {$ TreeA#_}
	     HasWhB = IHasWhBRec.I
	  in
	     if {Not HasWhB} andthen {RegexMatch TreeA WhtreepatRE} then
		false
	     else
		if {RegexMatch TreeA DeletePatsRE} then
		   false
		else
		   true
		end
	     end
	  end}
	 %%
	 XTAGPosAs = IXTAGPOSAsRec.I
	 TreeAAnchorsTups2 =
	 {Filter TreeAAnchorsTups1
	  fun {$ _#Anchors}
	     XTAGPosA = Anchors.1.1
	  in
	     {Member XTAGPosA XTAGPosAs}
	  end}
	 %%
	 TreeAAnchorsTups3 =
	 if TreeAAnchorsTups2==nil then
	    for DefaultPosA#TreeA in DefaultPosATreeATups collect:Collect do
	       Anchors = [DefaultPosA#BaseA]
	    in
	       {Collect TreeA#Anchors}
	    end
	 else
	    TreeAAnchorsTups2
	 end
      in      
	 TreeAAnchorsTups3
      end
   in
      FilterProc
   end
end
