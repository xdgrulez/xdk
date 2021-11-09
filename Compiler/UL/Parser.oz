%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)

   TokenizerGen(newTokenizer) at 'TokenizerGen.ozf'
export
   ParseUrl
   ParseV
require
   LALRGen(makeLALR) at 'LALRGen.ozf'
   System(show)
prepare
   {System.show 'generating user language parser'}
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<sstring>' '<dstring>' '<gstring>' '<int>'
		'defgrammar' '{' '}'
		'defdim'
		'dims' 'args'
		'defattrstype' 'defentrytype' 'deflabeltype' 'deftype' 'useprinciple' 'usedim' 'output' 'useoutput'
		'defclass'
		'useclass'
		'defentry'
		'set' 'iset' 'tuple' '(' ')' '*' 'list' 'valency' 'card' 'vec' 'int' 'ints' 'string' 'bool' 'ref' 'label' 'tv'
		'dim'#left(40) '\&'#left(30) '|'#left(20) '@'#left(30) '/'#left(30)
		'[' ']' '<' '>' '$'#left(10) '.' '::'#left(40)
		'_' '^' 'attrs' 'entry'
		'!' '?' '+' '#'
		'top' 'bot' 'infty'
		':'#left(20)]
      start  : 'S'
      rules  :
	 [
	  rule(head:'S' body:['*'('Defgrammar')]
	       action:defgrammar(1))

	  rule(head:'S' body:['{' '*'('Term') '}']
	       action:set(2))
	  
	  %% Defgrammar
	  rule(head:'Defgrammar' body:['defdim' 'Constant' '{' '*'('Defdim') '}']
	       action:defdim(2 4))
	  rule(head:'Defgrammar' body:['defclass' 'Constant' '*'('Constant') '{' '*'('Class') '}']
	       action:defclass(2 3 5))
	  rule(head:'Defgrammar' body:['defentry' '{' '*'('Class') '}']
	       action:defentry(3))
	  rule(head:'Defgrammar' body:['usedim' 'Constant']
	       action:usedim(2))

	  %% Defdim
	  rule(head:'Defdim' body:['defattrstype' 'Type']
	       action:defattrstype(2))
	  rule(head:'Defdim' body:['defentrytype' 'Type']
	       action:defentrytype(2))
	  rule(head:'Defdim' body:['deflabeltype' 'Type']
	       action:deflabeltype(2))
	  rule(head:'Defdim' body:['deftype' 'Constant' 'Type']
	       action:deftype(2 3))
	  rule(head:'Defdim' body:['useprinciple' 'Constant' '{' '*'('Useprinciple') '}']
	       action:useprinciple(2 4))
	  rule(head:'Defdim' body:['output' 'Constant']
	       action:output(2))
	  rule(head:'Defdim' body:['useoutput' 'Constant']
	       action:useoutput(2))

	  rule(head:'Useprinciple' body:['dims' '{' '*'('VarTermFeat') '}']
	       action:dims(3))
	  rule(head:'Useprinciple' body:['args' '{' '*'('VarTermFeat') '}']
	       action:args(3))

	  %% Type
	  rule(head:'Type' body:['{' '*'('Constant') '}']
	       action:'type.domain'(2))
	  rule(head:'Type' body:['set' '(' 'Type' ')']
	       action:'type.set'(3))
	  rule(head:'Type' body:['iset' '(' 'Type' ')']
	       action:'type.iset'(3))
	  rule(head:'Type' body:['tuple' '(' '*'('Type') ')']
	       action:'type.tuple'(3))
	  rule(head:'Type' body:['list' '(' 'Type' ')']
	       action:'type.list'(3))
	  rule(head:'Type' body:['valency' '(' 'Type' ')']
	       action:'type.valency'(3))
	  rule(head:'Type' body:['card']
	       action:'type.card')
	  rule(head:'Type' body:['{' '+'('TypeFeat') '}']
	       action:'type.record'(2))
	  rule(head:'Type' body:['{' ':' '}']
	       action:'type.emptyrecord')
	  rule(head:'Type' body:['vec' '(' 'Type' 'Type' ')']
	       action:'type.vec'(3 4))
	  rule(head:'Type' body:['int']
	       action:'type.int')
	  rule(head:'Type' body:['ints']
	       action:'type.ints')
	  rule(head:'Type' body:['string']
	       action:'type.string')
	  rule(head:'Type' body:['bool']
	       action:'type.bool')
	  rule(head:'Type' body:['ref' '(' 'Constant' ')']
	       action:'type.ref'(3))
	  rule(head:'Type' body:['Constant']
	       action:'type.ref'(1))
	  rule(head:'Type' body:['label' '(' 'Constant' ')']
	       action:'type.labelref'(3))
	  rule(head:'Type' body:['tv' '(' 'Constant' ')']
	       action:'type.variable'(3))
	  rule(head:'Type' body:['(' 'Type' ')']
	       action:2)
	      
	  %% Class
	  rule(head:'Class' body:['dim' 'Constant' 'Term']
	       action:'class.dim'(2 3))
	  rule(head:'Class' body:['useclass' 'Constant']
	       action:'class.ref'(2))
	  rule(head:'Class' body:['useclass' 'Constant' '{' '*'('VarTermFeat') '}']
	       action:'class.ref'(2 4))
	  rule(head:'Class' body:['Constant']
	       action:'class.ref'(1))
	  rule(head:'Class' body:['Constant' '{' '*'('VarTermFeat') '}']
	       action:'class.ref'(1 3))
	  rule(head:'Class' body:['Class' '\&' 'Class']
	       action:'conj'(1 3))
	  rule(head:'Class' body:['Class' '|' 'Class']
	       action:'disj'(1 3))
	  rule(head:'Class' body:['(' 'Class' ')']
	       action:2)
	      
	  %% Term
	  rule(head:'Term' body:['Constant']
	       action:1)
	  rule(head:'Term' body:['Integer']
	       action:1)
	  rule(head:'Term' body:['top']
	       action:top)
	  rule(head:'Term' body:['bot']
	       action:bot)

	  rule(head:'Term' body:['Featurepath']
	       action:1)
	  rule(head:'Term' body:['CardFeat']
	       action:1)
	  rule(head:'Term' body:['{' '*'('Term') '}']
	       action:set(2))
	  rule(head:'Term' body:['[' '*'('Term') ']']
	       action:list(2))
	  rule(head:'Term' body:['{' '+'('Recspec') '}']
	       action:record(2))
	  rule(head:'Term' body:['{' ':' '}']
	       action:emptyrecord)
	  rule(head:'Term' body:['$' 'Setgen']
	       action:setgen(2))
	  rule(head:'Term' body:['$' '(' ')']
	       action:emptysetgen)
	  rule(head:'Term' body:['Term' '::' 'Type']
	       action:annotation(1 3))
	  rule(head:'Term' body:['Term' '\&' 'Term']
	       action:conj(1 3))
	  rule(head:'Term' body:['Term' '|' 'Term']
	       action:disj(1 3))
	  rule(head:'Term' body:['Term' '@' 'Term']
	       action:concat(1 3))
	  rule(head:'Term' body:['<' '*'('Term') '>']
	       action:order(2))
	  rule(head:'Term' body:['Term' '/' 'Term']
	       action:bounds(1 3))
	  rule(head:'Term' body:['(' 'Term' ')']
	       action:2)
	      
	  %% Featurepath
	  rule(head:'Featurepath' body:['Root' '.' 'Constant' '.' 'Aspect' '.' '++'('Constant' '.')]
	       action:featurepath(1 3 5 7))
	  rule(head:'Root' body:['_']
	       action:1)
	  rule(head:'Root' body:['^']
	       action:1)
	  rule(head:'Aspect' body:['attrs']
	       action:1)
	  rule(head:'Aspect' body:['entry']
	       action:1)
	      
	  %% Recspec
	  rule(head:'Recspec' body:['TermFeat']
	       action:1)
	  rule(head:'Recspec' body:['Recspec' '\&' 'Recspec']
	       action:conj(1 3))
	  rule(head:'Recspec' body:['Recspec' '|' 'Recspec']
	       action:disj(1 3))
	  rule(head:'Recspec' body:['(' 'Recspec' ')']
	       action:2)
	      
	  %% Setgen
	  rule(head:'Setgen' body:['Constant']
	       action:1)
	  rule(head:'Setgen' body:['Setgen' '\&' 'Setgen']
	       action:conj(1 3))
	  rule(head:'Setgen' body:['Setgen' '|' 'Setgen']
	       action:disj(1 3))
	  rule(head:'Setgen' body:['(' 'Setgen' ')']
	       action:2)
	      
	  %% Constant
	  rule(head:'Constant' body:['<id>']
	       action:constantOrVariable(1))
	  rule(head:'Constant' body:['<sstring>']
	       action:constant(1))
	  rule(head:'Constant' body:['<dstring>']
	       action:constant(1))
	  rule(head:'Constant' body:['<gstring>']
	       action:constant(1))

	  %% Integer
	  rule(head:'Integer' body:['<int>']
	       action:integer(1))
	  rule(head:'Integer' body:['infty']
	       action:integer(1))

	  %% Features
	  rule(head:'ConstantFeat' body:['Constant' ':' 'Constant']
	       action:constantFeat(1 3))
	  rule(head:'TermFeat' body:['Constant' ':' 'Term']
	       action:termFeat(1 3))
	  rule(head:'VarTermFeat' body:['Constant' ':' 'Term']
	       action:varTermFeat(1 3))
	  rule(head:'TypeFeat' body:['Constant' ':' 'Type']
	       action:typeFeat(1 3))
	  rule(head:'CardFeat' body:['Constant' 'Card']
	       action:cardFeat(1 2))

	  %% Cardinality sets
	  rule(head:'Card' body:['!']
	       action:'!')
	  rule(head:'Card' body:['?']
	       action:'?')
	  rule(head:'Card' body:['*']
	       action:'*')
	  rule(head:'Card' body:['+']
	       action:'+')
	  rule(head:'Card' body:['#' '{' '*'('Integer') '}']
	       action:cardSet(3))
	  rule(head:'Card' body:['#' '[' 'Integer' 'Integer' ']']
	       action:cardInterval(3 4))
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   {System.show 'generating user language parser done'}
define
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 ["{" "}" "(" ")" "*" "\&" "|" "@" "/" "[" "]" "<" ">" "$" "." "::" "_" "^" "!" "?" "+" "#" ":"]
      eolComments:
	 ["%"]
      balancedComments:
	 ["/*"#"*/"]
      includes:
	 ["\\input"]
      keywords: ["defgrammar" "defdim" "dims" "args"
		 "defattrstype" "defentrytype" "deflabeltype" "deftype" "useprinciple" "usedim" "output" "useoutput"
		 "defclass" "useclass" "defentry" "set" "iset" "tuple" "list" "valency" "card" "vec" "int" "ints" "string" "bool" "ref" "label" "tv"
		 "dim" "attrs" "entry"
		 "top" "bot" "infty"]
     )}
   %% ParseUrl: V -> UL
   %% Parse the file at URL V and return its corresponding UL
   %% expression UL.
   fun {ParseUrl V}
%      {Inspect 'parsing'}
      Tokenized = {Tokenizer.fromURL V}
      
      UL = {Parser Tokenized}
%      {Inspect 'parsing done'}
   in
      UL
   end
   %%
   V2S = VirtualString.toString
   %% ParseV: V -> UL
   %% Parse the virtual string V and return its corresponding UL
   %% expression UL.
   fun {ParseV V}
%      {Inspect 'parsing'}
      S = {V2S V}
      Tokenized = {Tokenizer.fromString S}
      
      UL = {Parser Tokenized}
%      {Inspect 'parsing done'}
   in
      UL
   end
end
