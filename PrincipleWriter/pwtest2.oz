declare
{Inspector.configure widgetShowStrings true}
{Inspector.configure widgetTreeDepth 50}
%%
[TokenizerGen] = {Module.link ['TokenizerGen.ozf']}
[LALRGen] = {Module.link ['LALRGen.ozf']}
%%
Tokenizer =
{TokenizerGen.newTokenizer
 o(operators:
      [
       "{" "}" "(" ")"
       "[" "]" "::" "."
       "~" "&" "|" "=>" "<=>" ":" "=" "<"
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
       "set" "tuple"
       "entry" "attrs"
       "exists" "existsone" "forall" "in" "notin" "subseteq" "disjoint" "intersect" "union" "minus" "edge" "dom" "domeq" "word"
       "defprinciple"
       "dims"
       "constraints"
       "deftype"
      ]
  )}
%%
GrammarRec =
grammar(
   tokens : [
	     '<id>' '<sstring>' '<dstring>' '<gstring>' '<int>'
	     %%
	     '{' '}' '(' ')' % Dom (operators)
	     'label' 'node' 'dim' 'attr' % Dom (keywords)
	     %%
	     'set' 'tuple' % Type (keywords)
	     %%
	     '[' ']' '::' '.' % Expr (operators)
	     'entry' 'attrs' % Expr (keywords)
	     %%
	     '~'#left(10) '&'#left(9) '|'#left(8) '=>'#left(7) '<=>'#left(6) ':' '='#left(5) '<'#left(5) % Form (operators)
	     'exists'#left(5) 'existsone'#left(5) 'forall'#left(5) 'in'#left(5) 'notin'#left(5) 'subseteq'#left(5) 'disjoint'#left(5) 'intersect'#left(5) 'union'#left(5) 'minus'#left(5) 'edge' 'dom' 'domeq' 'word' % Form (keywords)
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
	    action:defprinciple(2 4 5))
       %%
       rule(head:'Dims' body:['dims' '{' '+'('Constant') '}']
	    action:dims(3))
       %%
       rule(head:'Constraints' body:['constraints' '{' '+'('Form') '}']
	    action:constraint(3))
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
       rule(head:'Form' body:['exists' 'Constant' '::' 'Dom' ':' 'Form']
	     action:exists(2 4 6))
       rule(head:'Form' body:['existsone' 'Constant' '::' 'Dom' ':' 'Form']
	     action:existsone(2 4 6))
       rule(head:'Form' body:['forall' 'Constant' '::' 'Dom' ':' 'Form']
	     action:forall(2 4 6))
       rule(head:'Form' body:['Expr' '=' 'Expr']
	    action:eq(1 3))
       %%
       rule(head:'Form' body:['Expr' 'in' 'Expr']
	    action:'in'(1 3))
       rule(head:'Form' body:['Expr' 'notin' 'Expr']
	    action:notin(1 3))
       rule(head:'Form' body:['Expr' 'subseteq' 'Expr']
	    action:subseteq(1 3))
       rule(head:'Form' body:['Expr' 'disjoint' 'Expr']
	    action:disjoint(1 3))
       rule(head:'Form' body:['Expr' 'intersect' 'Expr']
	    action:intersect(1 3))
       rule(head:'Form' body:['Expr' 'union' 'Expr']
	    action:union(1 3))
       rule(head:'Form' body:['Expr' 'minus' 'Expr']
	    action:minus(1 3))
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
       rule(head:'Expr' body:['{' '+'('Term') '}']
	    action:set(2))
       rule(head:'Expr' body:['Tuple']
	    action:1)
       rule(head:'Expr' body:['{' '+'('Tuple') '}']
	    action:set(2))
       rule(head:'Expr' body:['Expr' '::' 'Type']
	    action:anno(1 3))
       rule(head:'Expr' body:['Term' '.' 'Term' '.' 'entry' '.' 'Constant']
	    action:entry(1 3 5 7))
        rule(head:'Expr' body:['Term' '.' 'Term' '.' 'attrs' '.' 'Constant']
 	    action:attrs(1 3 5 7))
       rule(head:'Expr' body:['(' 'Expr' ')']
	    action:2)
       %%
       rule(head:'Constant' body:['<id>']
	    action:1)
       rule(head:'Constant' body:['<sstring>']
	    action:1)
       rule(head:'Constant' body:['<dstring>']
	    action:1)
       rule(head:'Constant' body:['<gstring>']
	    action:1)
       rule(head:'Integer' body:['<int>']
	    action:1)
       %%
       rule(head:'Term' body:['Constant']
	    action:1)
       rule(head:'Term' body:['Integer']
	    action:1)
       %%
       rule(head:'Type' body:['Dom']
	    action:1)
       rule(head:'Type' body:['set' '(' 'Dom' ')']
	    action:tset(1))
       rule(head:'Type' body:['tuple' '(' '+'('Dom') ')']
	    action:ttuple(1))
       rule(head:'Type' body:['set' '(' 'tuple' '(' '+'('Dom') ')' ')']
	    action:tset(1))
       rule(head:'Type' body:['(' 'Type' ')']
	    action:2)
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
      ]
   )
%
{Inspect 'generating parser...'}
Parser = {LALRGen.makeLALR GrammarRec}
{Inspect 'done.'}

declare
{Inspector.configure widgetShowStrings true}
{Inspector.configure widgetTreeDepth 50}
%%
Teststring = "defprinciple 'testprinciple' {dims{D} constraints {~('V1' = 'V2')}}"
Tokenized = {Tokenizer.fromString Teststring}
%Tokenized = {Tokenizer.fromURL 'Examples/subgraphsPW.ul'}
{Inspect Tokenized}
Parsed = {Parser Tokenized}
{Inspect Parsed}

declare
{Inspector.configure widgetShowStrings true}

%% Semantic
fun {EvaluateTree Tree V Mode Type}
   Coord1 = Tree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Tree.file
   File = if File1==unit then noFile else File1 end
   Sem = Tree.sem
in
   case Sem
   of s(List1 List2) then
      {List.foldL 
%       {List.map List2.sem fun{$ X} {EvaluateTree X V Mode Type} end}
       {List.map List2.sem
	fun {$ X}
	   {EvaluateTree X V Mode Type}
	  % X.sem
	end
       }
       fun {$ X Y} ''#Y#X#'' end
       ""
      }
%   [] defprinciple(Constant Tree1 Tree2) then
%      {EvaluateTree Tree2.sem V Mode Type}
%   [] constraint(FormsList) then
%      {List.forAll FormsList fun{$ X} {EvaluateTree X.sem V Mode Type} end}
%   [] eq(Expr1 Expr2) then
%      "test"
   else
      'No Match'
   end
end

{Inspect "Evaluation"}
Eval = {EvaluateTree Parsed "" "" ""}
{Inspect Eval}
{Inspect "Done"}