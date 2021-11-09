%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)

   TokenizerGen(newTokenizer) at '../../../Compiler/UL/TokenizerGen.ozf'
export
   ParseUrl
   ParseV
require
   LALRGen(makeLALR) at '../../../Compiler/UL/LALRGen.ozf'
   System(show)
prepare
   {System.show 'generating clls parser'}
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<sstring>' '<dstring>' '<gstring>' '<int>'
		'(' ')'
		'dom' 'label' 'lam' 'anchor'
	       ]
      start  : 'S'
      rules  :
	 [
	  rule(head:'S' body:['*'('Literal')]
	       action:1)
	  
	  %% Literal
	  rule(head:'Literal' body:['dom' '(' 'Const' 'Const' ')']
	       action:dom(3 4))
	  rule(head:'Literal' body:['label' '(' 'Const' 'Const' '(' '+'('Const' ) ')' ')']
	       action:label(3 4 6))
	  rule(head:'Literal' body:['label' '(' 'Const' 'Const' ')']
	       action:label(3 4))
	  rule(head:'Literal' body:['lam' '(' 'Const' 'Const' ')']
	       action:lam(3 4))
	  
	  %% Const
	  rule(head:'Const' body:['<id>']
	       action:const(1))
	  rule(head:'Const' body:['<sstring>']
	       action:const(1))
	  rule(head:'Const' body:['<dstring>']
	       action:const(1))
	  rule(head:'Const' body:['<gstring>']
	       action:const(1))
	  rule(head:'Const' body:['anchor']
	       action:anchor)
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   {System.show 'generating clls parser done'}
define
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 ["(" ")"]
      eolComments:
	 nil
      balancedComments:
	 nil
      includes:
	 nil
      keywords: ["dom" "label" "lam" "anchor"]
     )}
   %% ParseUrl: V -> CLLS
   %% Parses the file at URL V and return the parsed CLLS literals
   %% CLLS.
   fun {ParseUrl V}
%      {Inspect 'parsing'}
      Tokenized = {Tokenizer.fromURL V}
      
      CLLS = {Parser Tokenized}
%      {Inspect 'parsing done'}
   in
      CLLS
   end
   %%
   V2S = VirtualString.toString
   %% ParseV: V -> PLits
   %% Parse the virtual string V and return its the parsed CLLS
   %% literals CLLS.
   fun {ParseV V}
%      {Inspect 'parsing'}
      S = {V2S V}
      Tokenized = {Tokenizer.fromString S}

      CLLS = {Parser Tokenized}
%      {Inspect 'parsing done'}
   in
      CLLS
   end
end
