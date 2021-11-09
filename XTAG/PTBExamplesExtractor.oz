%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(showError)
%   Inspector(inspect)

   Helpers(getLines) at 'Helpers.ozf'
   SyntaxParser(parse) at 'SyntaxParser.ozf'
export
   Extract
prepare
   ListDrop = List.drop
   ListLast = List.last
   ListTake = List.take
   %%
   S2A = String.toAtom
define
   POSASRec =
   o('CC': "and"         % coordinating conjunction
     'CD': "three"       % cardinal number
     'DT': "the"         % determiner
     'EX': "there"       % existential there
     'FW': "Iraq"        % foreign word
     'IN': "of"          % preposition or subordinating conjunction
     'JJ': "political"   % adjective
     'JJR': "more"       % adjective, comparative
     'JJS': "most"       % adjective, superlative
     'LS': ","           % list item marker
     'MD': "can"         % modal
     'NN': "marketer"    % noun, singular or mass
     'NNS': "dolphins"   % noun, plural
     'NNP': "Iraqi"      % proper noun, singular
     'NNPS': "Iraqis"    % proper noun, plural
     'PDT': "such"       % predeterminer
     'POS': "'s"         % possessive ending
     'PRP': "she"        % personal pronoun
     'PRP$': "her"       % possessive pronoun
     'RB': "early"       % adverb
     'RBR': "earlier"    % adverb, comparative
     'RBS': "earliest"   % adverb, superlative
     'RP': "down"        % particle
     'TO': "to"          % to
     'UH': "no"          % interjection
     'VB': "eat"         % verb, base form
     'VBD': "ate"        % verb, past tense
     'VBG': "eating"     % verb, gerund/present particle
     'VBN': "eaten"      % verb, past participle
     'VBP': "eat"        % verb, sing. present, non-3d
     'VBZ': "eats"       % verb, 3rd person sing. present
     'WDT': "that"       % wh-determiner
     'WP': "who"         % wh-pronoun
     'WP$': "whose"      % possessive wh-pronoun
     'WRB': "when"       % wh-adverb
     %%
     'SYM': "equals"     % symbol
     %%
     ',': ","
     '.': "."
     '$': "$"
     '``': "``"
     '\'\'': "''"
     ':': ":"
     ')': ")"
     '(': "("
     '#': "#")
   %%
   %% Extract: UrlV SubstitutionB -> Ss
   fun {Extract UrlV SubstitutionB}
      %% Sub1: Ss AccSs -> SITups
      %% Extracts sentences (and their length) from the lists of
      %% strings that represent the lines of a *.pos file.
      fun {Sub1 Ss AccSs}
	 case Ss
	 of S|Ss1 then
	    case S
	    of nil then
	       %% skip empty lines
	       {Sub1 Ss1 AccSs}
	    [] &=|_ then
	       %% skip lines beginning with =
	       {Sub1 Ss1 AccSs}
	    else
	       %% if the line is neither empty nor begins with =, we are at
	       %% the beginning of a sentence, so enter Sub2
	       Ss2#S = {Sub2 Ss nil 0}
	       %% drop the space character in front of the sentence
	       S1 = {ListDrop S 1}
	       S1s = {String.tokens S1 & }
	       S1I = {Length S1s}
	       I = {Length Ss2}
	    in
	       if I mod 100==0 then {System.showError I} end
	       if {Member "<unknown>" S1s} then
		  {Sub1 Ss2 AccSs}
	       else
		  {Sub1 Ss2 {Append AccSs [(S1#S1I)]}}
	       end
	    end
	 else
	    AccSs
	 end
      end
      %% Sub2: Ss AccSs OBI -> SsSTup
      %% Extracts a sentence S from the list of strings that represent
      %% the lines of a *.pos file. Ss is the updated pointer to the
      %% list of strings after sentence extraction.
      fun {Sub2 Ss AccSs OBI}
	 case Ss
	 of S|Ss1 then
	    case S
	    of nil then
	       %% skip empty lines inbetween
	       {Sub2 Ss1 AccSs OBI}
	    [] " " then
	       %% skip lines with only a space inbetween
	       {Sub2 Ss1 AccSs OBI}
	    [] &=|_ then
	       S1 = {FoldL AccSs
		     fun {$ AccS S} {Append S AccS} end nil}
	    in
	       Ss1#S1
	    else
	       %% tokenize
	       Ss2 = {String.tokens S & }
	       SSTups =
	       for S in Ss2 collect:Collect do
		  case S
		  of nil then
		     %% remove spaces
		     skip
		  [] "[" then
		     %% remove opening [
		     skip
		  [] "]" then
		     %% remove closing ]
		     skip
		  else
		     %% tokenize word/POS pairs
		     Ss4 = {String.tokens S &/}
		     S1 = {FoldL {ListTake Ss4 {Length Ss4}-1}
			   fun {$ AccS S2} {Append AccS S2} end ""}
		     POSS = {ListLast Ss4}
		     POSSs = {String.tokens POSS &|}
		     POSS1 = POSSs.1
		  in
		     {Collect S1#POSS1}
		  end
	       end
	       %% S1: POS of the last word in this line
	       _#S1 = {ListLast SSTups}
	       %% adapt words to the actual XTAG grammar
	       S2 = {FoldL SSTups
		     fun {$ AccS S#POSS}
			%% make all words which are not NNPs lower case
			S1 =
			case POSS
			of "NNP" then
			   S
			else
			   S2 = {ListDrop S 1}
			in
			   {Char.toLower S.1}|S2
			end
			%%
			A = {S2A S1}
			POSA = {S2A POSS}
			%%
			S2 =
			case A
			of '%' then "percent"
			[] 'n\'t' then "not"
			elseif {Not {Member A SyntaxAs}} then
 			   if {HasFeature POSASRec POSA} then
			      if SubstitutionB then
				 POSASRec.POSA
			      else
				 "<unknown>"
			      end
			   else
			      raise A#POSA end
			   end
			else
			   S1
			end
		     in
			case POSA
			of '$' then
			   %% skip dollar signs
			   AccS
			[] '``' then
			   %% skip opening quotes
			   AccS
			[] '\'\'' then
			   %% skip closing quotes
			   AccS
			[] '(' then
			   %% skip opening quotes
			   AccS
			[] ')' then
			   %% skip closing quotes
			   AccS
			else
			   %% collect S2
			   {Append AccS & |S2}
			end
		     end nil}
	       %%
	       OBI1 = {FoldL SSTups
		       fun {$ AccI S1#_}
			  case S1
			  of "(" then AccI+1
			  [] ")" then AccI-1
			  else AccI
			  end
		       end OBI}
	    in
	       if S1=="." andthen OBI1==0 then
		  %% when we find a full stop and the number of open
		  %% brackets is 0, we have reached the end of the
		  %% sentence, so we return it as string S3 (and we
		  %% return a pointer Ss1 into the list of strings
		  %% that represent the *.pos file).
		  S3 = {FoldL S2|AccSs
			fun {$ AccS S} {Append S AccS} end nil}
	       in
		  Ss1#S3
	       else
		  %% else go on collecting the sentence
		  {Sub2 Ss1 S2|AccSs OBI1}
	       end
	    end
	 end
      end
      %%
      Ss = {Helpers.getLines UrlV}
      SyntaxRec = {SyntaxParser.parse}
      SyntaxAs = {Arity SyntaxRec}
      Ss1 = {Sub1 Ss nil}
   in
      Ss1
   end
end
