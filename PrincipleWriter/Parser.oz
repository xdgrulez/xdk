%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   TokenizerGen(newTokenizer) at 'TokenizerGen.ozf'
export
   ParseUrl
   ParseV
require
   LALRGen(makeLALR) at 'LALRGen.ozf'
   System(show)
prepare
   {System.show 'generating PW parser'}
   %%
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<sstring>' '<dstring>' '<gstring>' '<int>'
		%%
		'{' '}' '(' ')' % Dom (operators)
		'label' 'node' 'dim' 'attr' % Dom (keywords)
		%%
		'set' 'tuple' 'dom' 'proj' 'eq' % Type (keywords)
		%%
		'[' ']' '::' '.' '$'#left(10) % Expr (operators)
		'entry' 'attrs' % Expr (keywords)
		%%
		'~'#left(10) '&'#left(9) '|'#left(8) '=>'#left(7) '<=>'#left(6) ':' '='#left(15) '~='#left(15) '<'#left(15) % Form (operators)
		'exists'#left(5) 'existsone'#left(5) 'forall'#left(5) 'in'#left(15) 'notin'#left(15) 'subseteq'#left(15) 'disjoint'#left(15) 'intersect'#left(15) 'union'#left(15) 'minus'#left(15) 'edge' 'domeq' 'word' % Form (keywords)
		%%
		'defprinciple' % Pri (keywords)
		'dims' % Dims (keywords)
		'constraints' % Constraints (keywords)
		'deftype'
	       ]
      start  : 'S'
      rules  :
	 [
	  rule(head:'S' body:['*'('DefType') '+'('DefPrinciple')]
	       action:s(1 2))
	  %%
	  rule(head:'DefType' body:['deftype' 'Constant' 'Type']
	       action:deftype(2 3))
	  %%
	  rule(head:'DefPrinciple' body:['defprinciple' 'Constant' '{' 'Dims' 'Constraints' '}']
	       action:fun {$ [_ Id _ Dims Constraints _]} 
			 TopDim
		      in
			 Constraints
			 = {FoldL Dims.sem.1.sem
			    proc {$ UpNest Dim DwnNest}
			       UpNest = {AdjoinAt Dim sem
					 letdim(Dim Dim DwnNest)}
			    end TopDim}
			 defprinciple(Id Dims TopDim)
		      end)
	  %%
	  rule(head:'Dims' body:['dims' '{' '*'('Constant') '}']
	       action:dims(3))
	  %%
	  rule(head:'Constraints' body:['constraints' '{' '+'('Form') '}']
	       action:constraints(3))
	  %%
	  rule(head:'Type' body:['Dom']
	       action:1)
	  rule(head:'Type' body:['set' '(' 'Dom' ')']
	       action:tset(3))
	  rule(head:'Type' body:['TupleType']
	       action:1)
	  rule(head:'Type' body:['set' '(' 'TupleType' ')']
	       action:tset(3))
	  rule(head:'Type' body:['dom' '(' 'Type' ')']
	       action:tdom(3))
	  rule(head:'Type' body:['proj' '(' 'Type' 'Integer' ')']
	       action:tproj(3 4))
	  rule(head:'Type' body:['entry' '(' 'Constant' 'Constant' ')']
	       action:tentry(3 4))
	  rule(head:'Type' body:['attrs' '(' 'Constant' 'Constant' ')']
	       action:tattrs(3 4))
	  rule(head:'Type' body:['eq' '(' 'Type' 'Type' ')']
	       action:teq(3 4))
	  rule(head:'Type' body:['(' 'Type' ')']
	       action:2)
	  %%
	  rule(head:'TupleType' body:['tuple' '(' '+'('Dom') ')']
	       action:ttuple(3))
	  %%
	  rule(head:'Dom' body:['{' '+'('Constant') '}']
	       action:dom(2))
	  rule(head:'Dom' body:['label' '(' 'Constant' ')']
	       action:edgelabels(3))
	  rule(head:'Dom' body:['node']
	       action:node)
	  rule(head:'Dom' body:['dim']
	       action:dim)
	  rule(head:'Dom' body:['attr']
	       action:'attr')
	  rule(head:'Dom' body:['word']
	       action:'word')
	  rule(head:'Dom' body:['Constant']
	       action:tref(1))
	  %%
	  rule(head:'Form' body:['~' 'Form']
	       action:neg(2))
	  rule(head:'Form' body:['Form' '&' 'Form']
	       action:conj(1 3))
	  rule(head:'Form' body:['Form' '|' 'Form']
	       action:disj(1 3))
	  rule(head:'Form' body:['Form' '=>' 'Form']
	       action:impl(1 3))
	  rule(head:'Form' body:['Form' '<=>' 'Form']
	       action:equi(1 3))
	  rule(head:'Form' body:['exists' 'Expr' ':' 'Form']
	       action:exists(2 4))
	  rule(head:'Form' body:['existsone' 'Expr' ':' 'Form']
	       action:existsone(2 4))
	  rule(head:'Form' body:['forall' 'Expr' ':' 'Form']
	       action:forall(2 4))
	  rule(head:'Form' body:['Expr' '=' 'Expr']
	       action:eq(1 3))
	  rule(head:'Form' body:['Expr' '~=' 'Expr']
	       action:neq(1 3))
	  %%
	  rule(head:'Form' body:['Expr' 'in' 'Expr']
	       action:'in'(1 3))
	  rule(head:'Form' body:['Expr' 'notin' 'Expr']
	       action:notin(1 3))
	  rule(head:'Form' body:['Expr' 'subseteq' 'Expr']
	       action:subseteq(1 3))
	  rule(head:'Form' body:['Expr' 'disjoint' 'Expr']
	       action:disjoint(1 3))
	  rule(head:'Form' body:['Expr' 'intersect' 'Expr' '=' 'Expr']
	       action:intersect(1 3 5))
	  rule(head:'Form' body:['Expr' 'union' 'Expr' '=' 'Expr']
	       action:union(1 3 5))
	  rule(head:'Form' body:['Expr' 'minus' 'Expr' '=' 'Expr']
	       action:minus(1 3 5))
	  %%
	  rule(head:'Form' body:['edge' '(' 'Expr' 'Expr' 'Expr' 'Expr' ')']
	       action:ledge(3 4 5 6))
	  rule(head:'Form' body:['edge' '(' 'Expr' 'Expr' 'Expr' ')']
	       action:edge(3 4 5))
	  rule(head:'Form' body:['dom' '(' 'Expr' 'Expr' 'Expr' 'Expr' ')']
	       action:ldom(3 4 5 6))
	  rule(head:'Form' body:['dom' '(' 'Expr' 'Expr' 'Expr' ')']
	       action:dom(3 4 5))
	  rule(head:'Form' body:['domeq' '(' 'Expr' 'Expr' 'Expr' ')']
	       action:domeq(3 4 5))
	  rule(head:'Form' body:['Term' '<' 'Term']
	       action:prec(1 3))
	  rule(head:'Form' body:['Term' '.' 'word' '=' 'Term']
	       action:word(1 5))
	  %%
	  rule(head:'Form' body:['(' 'Form' ')']
	       action:2)
	  %%
	  rule(head:'Tuple' body:['[' '+'('Term') ']']
	       action:tuple(2))
	  %%
	  rule(head:'Expr' body:['Term']
	       action:1)
	  rule(head:'Expr' body:['{' '*'('Term') '}']
	       action:set(2))
	  rule(head:'Expr' body:['Tuple']
	       action:1)
	  rule(head:'Expr' body:['{' '+'('Tuple') '}']
	       action:set(2))
	  rule(head:'Expr' body:['Expr' '::' 'Type']
	       action:anno(1 3))
	  rule(head:'Expr' body:['Term' '.' 'Term' '.' 'entry' '.' 'Constant']
	       action:entry(1 3 7))
	  rule(head:'Expr' body:['Term' '.' 'Term' '.' 'attrs' '.' 'Constant']
	       action:attrs(1 3 7))
	  rule(head:'Expr' body:['$' 'Setgen']
	       action:setgen(2))
	  rule(head:'Expr' body:['(' 'Expr' ')']
	       action:2)
	  %%
	  rule(head:'Setgen' body:['Constant']
	       action:1)
	  rule(head:'Setgen' body:['Setgen' '\&' 'Setgen']
	       action:conj(1 3))
	  rule(head:'Setgen' body:['Setgen' '|' 'Setgen']
	       action:disj(1 3))
	  rule(head:'Setgen' body:['(' 'Setgen' ')']
	       action:2)
	  %%
	  rule(head:'Constant' body:['<id>']
	       action:constant(1))
	  rule(head:'Constant' body:['<sstring>']
	       action:constant(1))
	  rule(head:'Constant' body:['<dstring>']
	       action:constant(1))
	  rule(head:'Constant' body:['<gstring>']
	       action:constant(1))
	  rule(head:'Integer' body:['<int>']
	       action:integer(1))
	  %%
	  rule(head:'Term' body:['Constant']
	       action:1)
	  rule(head:'Term' body:['Integer']
	       action:1)
	 ]
      )
   Parser = {LALRGen.makeLALR GrammarRec}
   %%
   {System.show 'generating PW parser done'}
define
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 [
	  "{" "}" "(" ")"
	  "[" "]" "::" "." "$"
	  "~" "&" "|" "=>" "<=>" ":" "=" "~=" "<"
	 ]
      eolComments:
	 [
	  "%" "#" "//"
	 ]
      balancedComments:
	 [
	  "/*"#"*/"
	 ]
      includes:
	 [
	  "\\input"
	 ]
      keywords:
	 [
	  "label" "node" "dim" "attr"
	  "set" "tuple" "dom" "proj" "eq"
	  "entry" "attrs"
	  "exists" "existsone" "forall" "in" "notin" "subseteq" "disjoint" "intersect" "union" "minus" "edge" "domeq" "word"
	  "defprinciple"
	  "dims"
	  "constraints"
	  "deftype"
	 ]
     )}
   %% ParseUrl: V -> UL
   %% Parses the file at URL V and returns the Tree representation
   %% Tree of it.
   fun {ParseUrl V}
      Tokenized = {Tokenizer.fromURL V}
      Tree = {Parser Tokenized}
   in
      Tree
   end
   %% ParseUrl: V -> UL
   %% Parses the virtual string V and returns the Tree representation
   %% Tree of it.
   fun {ParseV V}
      Tokenized = {Tokenizer.fromString V}
      Tree = {Parser Tokenized}
   in
      Tree
   end
end
