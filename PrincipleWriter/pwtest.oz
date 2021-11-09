declare
[TokenizerGen] = {Module.link ['TokenizerGen.ozf']}
[LALRGen] = {Module.link ['LALRGen.ozf']}
%%
Tokenizer =
{TokenizerGen.newTokenizer
 o(operators:
      [
       "(" ")" "{" "}" "[" "]" "::" ":" "." "|" "~" "&" "=>" "<=>" "=" "<"
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
       "label" "attr" "node" "dim" "set" "tuple" "entry" "attrs" "exists" "existsone" "forall" "in" "notin" "subseteq" "disjoint" "intersect" "union" "minus" "edge" "word" "dom" "domeq"
      ]
  )}
%%
GrammarRec =
grammar(
   tokens : [
	     'label' 'attr' 'node' 'dim' 'set' 'tuple' 'entry' 'attrs'
	     'exists'#left(40) 'existsone'#left(40) 'forall'#left(40)
	     'in'#left(20) 'notin'#left(20) 'subseteq'#left(20)
	     'disjoint'#left(20) 'intersect'#left(20) 'union'#left(20)
	     'minus'#left(20)
	      'word'
	      'edge'  'dom' 'domeq'
	      '<sstring>' '<dstring>' '<gstring>' '<int>'
	     '(' ')' '{' '}' '[' ']'
	     '::'#left(30) ':'#left(30) '.'#left(30)
	     '|'#left(30) '~'#left(30) '&'#left(30) '=>'#left(30) '<=>'#left(30)
	     '='#left(29) '<'#left(30)      
%TreePW2 = "( ~exists V1::node : edge(V1 V D))"

	    ]
   start  : 'Form'
   rules  :
      [
       %DOM
       rule(head:'Dom' body:['{' '+'('Constant') '}']
	    action:dom_Domain(2))
       rule(head:'Dom' body:[ '(' 'Dom' '|' 'Dom' ')']
	    action:dom_Union(2 4))
       rule(head:'Dom' body:['label' '(' 'Constant' ')']
	    action:dom_Constant(3))
       rule(head:'Dom' body:['node']
	    action:dom_Nodes(1))
       rule(head:'Dom' body:['dim']
	    action:dom_Dimensions(1))
       rule(head:'Dom' body:['attr']
	    action:dom_Attributes(1))
       %TYPE
       rule(head:'Type' body:['Dom']
	    action:type_Domain(1))
       rule(head:'Type' body:['set' '(' 'Dom' ')']
	    action:type_Set(3))
       rule(head:'Type' body:['tuple' '(' '+'('Dom') ')']
	    action:type_Tuple(3))
       rule(head:'Type' body:['set' '(' 'tuple' '(' '+'('Dom') ')' ')' ]
	    action:type_SetOfTuples(5))
       rule(head:'Type' body:['Constant']
	    action:type_Reference(1))
       rule(head:'Type' body:['(' 'Type' ')']
	    action:type_Bracketing(2))
       %TERM
       rule(head:'Term' body:['Constant']
	    action:term_Constant(1))
%       rule(head:'Term' body:['Integer']
%	    action:term_Integer(1))
%       rule(head:'Term' body:['Variable']
%	    action:term_Variable(1))
       %EXPR
       rule(head:'Expr' body:['(' 'Term' ')']
	    action:term_Term(2))
       rule(head:'Expr' body:['(' '{' '+'('Term') '}' ')']
	    action:term_Set(3))
       rule(head:'Expr' body:['(' '[' '+'('Term') ']' ')']
	    action:term_Tuple(3))
       rule(head:'Expr' body:['(' '{' '+'('TermSetTuples') '}' ')']
	    action:term_SetTuples(3))
       rule(head:'Expr' body:['(' 'Expr' ')' '::' '(' 'Term' ')']
	    action:term_Type_Annotation(2 6))
       rule(head:'Expr' body:['(' 'Term' ')' '.' '(' 'Term' ')' '.' 'entry' '.' '(' 'Constant' ')']
	    action:term_LexicalAttributes(2 6 12))
       rule(head:'Expr' body:['(' 'Term' ')' '.' '(' 'Term' ')' '.' 'attrs' '.' '(' 'Constant' ')']
	    action:term_NonLexicalAttributes(2 6 12))
       rule(head:'Expr' body:['(' 'Expr' ')']
	    action:term_Bracketing(2))
       %Temporal Rule for Term_SetTuples
       rule(head:'TermSetTuples' body:['[' '+'('Term') ']']
	    action:termSetTuples(2))
       %FORM
       rule(head:'Form' body:['(' '~' 'Form' ')']
	    action:form_Negation(3))
       rule(head:'Form' body:['(' 'Form' '&' 'Form' ')']
	    action:form_Conjunction(2 4))
       rule(head:'Form' body:['(' 'Form' '|' 'Form' ')' ]
	    action:form_Disjunction(2 4))
       rule(head:'Form' body:['(' 'Form' '=>' 'Form' ')']
	    action:form_Implication(2 4))
       rule(head:'Form' body:['(' 'Form' '<=>' 'Form' ')']
	    action:form_Equivalence(2 4))
       rule(head:'Form' body:['(' 'exists' 'Variable' '::' 'Dom' ':'  'Form' ')']
	    action:form_Exists(3 5 7))
       rule(head:'Form' body:['(' 'existsone' 'Variable' '::' 'Dom' ':' 'Form' ')']
	    action:form_Existsone(3 5 7))
       rule(head:'Form' body:['(' 'forall' 'Variable' '::' 'Dom' ':' 'Form' ')']
	    action:form_Forall(3 5 7))
       rule(head:'Form' body:[ '(' 'Expr' '=' 'Expr' ')' ]
	    action:form_Equality(2 4))
       rule(head:'Form' body:['(' 'Expr' 'in' 'Expr'')' ]
	    action:form_Element(2 4))
       rule(head:'Form' body:['(' 'Expr' 'notin' 'Expr' ')']
	    action:form_NotElement(2 4))
       rule(head:'Form' body:['(' 'Expr' 'subseteq' 'Expr' ')']
	    action:form_Subset(2 4))
       rule(head:'Form' body:['(' 'Expr' 'disjoint' 'Expr' ')']
	    action:form_Disjointness(2 4))
       rule(head:'Form' body:['(' 'Expr' 'intersect' 'Expr' ')']
	    action:form_Intersect(2 4))
       rule(head:'Form' body:['(' 'Expr' 'union' 'Expr' ')']
	    action:form_Union(2 4))
       rule(head:'Form' body:['(' 'Expr' 'minus' 'Expr' ')']
	    action:form_Minus(2 4))
       rule(head:'Form' body:['edge' '(' 'Expr' 'Expr' 'Expr' 'Expr' ')']
	    action:form_LabeledEdge(3 4 5 6))
       rule(head:'Form' body:['edge' '(' 'Expr' 'Expr' 'Expr' ')']
	    action:form_Edge(3 4 5))
       rule(head:'Form' body:['dom' '(' 'Expr' 'Expr' 'Expr' 'Expr' ')']
	    action:form_LabeldStrictDominance(3 4 5 6))
       rule(head:'Form' body:['dom' '(' 'Expr' 'Expr' 'Expr' ')']
	    action:form_StrictDominance(3 4 5))
       rule(head:'Form' body:['domeq' '(' 'Expr' 'Expr' 'Expr' ')']
	    action:form_Dominance(3 4 5))
       rule(head:'Form' body:['(' 'Expr' '<' 'Expr' ')']
	    action:form_Precedence(2 4))
       rule(head:'Form' body:['(' 'Expr' ')' '.' 'word' '=' '(' 'Expr' ')']
	    action:form_Word(2 8))
       rule(head:'Form' body:['(' 'Form' ')' ]
	    action:form_Bracketing(2))
%ATOMS
       rule(head:'Constant' body:['<sstring>']
	    action:1)
%       rule(head:'Constant' body:['<dstring>']
%	    action:1)
       rule(head:'Variable' body:['<sstring>']
	    action:1)
%       rule(head:'Variable' body:['<dstring>']
%	    action:1)
       rule(head:'Integer' body:['<int>']
	    action:1)
      ]
   )
Parser = {LALRGen.makeLALR GrammarRec}
%

TreePW = "( forall V::node : ~dom(V V D) ) & ( existsone V::node : ~exists V1::node : edge(V1 V D)) & ( forall V::node : (~exists V1::node : edge(V1 V D)) | ( existsone V1::node : edge(V1 V D)))"
TreePW2 = "( (~ (exists 'V1' :: node : edge(('V1') ('V') ('D')))))"
TreePW3 = "(~ ( ('v1') in ('v2') ))"
Test = "V & V"

%%
%
%Tokenized = {Tokenizer.fromString OneRoot}
Tokenized = {Tokenizer.fromString TreePW2}
{Inspect Tokenized}
Parsed = {Parser Tokenized}
{Inspect Parsed}

% declare
% {Inspector.configure widgetShowStrings true}
% %%%%%%%
% % Parsetree weiterverarbeiten
% fun {SimplifyTree Parsetree}
%    Coord1 = Parsetree.coord
%    Coord = if Coord1==unit then noCoord else Coord1 end
%    File1 = Parsetree.file
%    File = if File1==unit then noFile else File1 end
%    Sem = Parsetree.sem
% in
%    case Sem
%    %% sentence ->
%    of sentence_nsentence(Subtree1) then
%       S = {SimplifyTree Subtree1}
%    in
%       'Not'(S)
%    [] sentence_AtomicSentence(Subtree1) then
%       {SimplifyTree Subtree1}
% %%   in
%   %%    sentence_AtomicSentence(S)
%    [] sentence_ImpSentence(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'Imp'(S1 S2) 
%    [] sentence_IffSentence(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'Iff'(S1 S2)
%    [] sentence_AndSentence(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'And'(S1 S2)
%    [] sentence_OrSentence(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'Or'(S1 S2)
%    [] sentence_qvsentence(Subtree1 Subtree2 Subtree3) then
% %      S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%       S3 = {SimplifyTree Subtree3}
%       E
%       case Subtree1.sem
%       of quantifier_exists(...) then
% 	 E = 'exists'(S2 S3)
%       [] quantifier_forall(...) then
% 	 E = 'forall'(S2 S3)
%       [] 'quantifier_existsone'(...) then
% 	 E = 'existsone'(S2 S3)
%       end
%    in
%      E
%    %% Quantifier ->
% %%   [] quantifier_exists(...) then
% %%     'Exists'
% %%   [] quantifier_existsone(...) then
% %%      'ExistsOne'
% %%   [] quantifier_forall(...) then
% %%      'ForAll'
%    %% AtomicSentence ->
%    [] atomicsentence_eq(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'Eq'(S1 S2)
%    [] atomicsentence_mterm(Subtree1) then
%       {SimplifyTree Subtree1}
%       %% Mterm ->
%    [] mterm_node(Subtree1) then
%      {SimplifyTree Subtree1}
%    [] mterm_dimlabel(Subtree1 Subtree2 Subtree3 Subtree4) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%       S3 = {SimplifyTree Subtree3}
%       S4 = {SimplifyTree Subtree4}
%    in
%       'DimLabel'(S1 S2 S3 S4)
%    [] mterm_dim(Subtree1 Subtree2 Subtree3) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%       S3 = {SimplifyTree Subtree3}
%    in
%       'Dim'(S1 S2 S3)
%    [] mterm_dimplus(Subtree1 Subtree2 _ Subtree3) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%       S3 = {SimplifyTree Subtree3}
%    in
%       'DimPlus'(S1 S2 S3)
%    [] mterm_dimstar(Subtree1 Subtree2 _ Subtree3) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%       S3 = {SimplifyTree Subtree3}
%    in
%       'DimStar'(S1 S2 S3)
%    [] mterm_nodeless(Subtree1 Subtree2) then
%       S1 = {SimplifyTree Subtree1}
%       S2 = {SimplifyTree Subtree2}
%    in
%       'NodeLess'(S1 S2)
%       %% Term ->
%    [] term_con(Subtree1) then
%       {SimplifyTree Subtree1}
%       %% Constant ->
%    [] con_atom(Subtree1) then
%       Subtree1.sem
%    [] con_rec(List1) then
%       {List.toTuple
%        'Record'
%        {List.map List1.sem SimplifyTree}
%       }
%    [] con_tup(List1) then
%       S1 = List1.sem
%    in
%       {List.toTuple 'Tuple'
%        {List.map
% 	S1
% 	fun {$ X} X.sem end} 
%       }
%    [] con_set(Subtree1) then
%       {List.toTuple
%        'Set'
%        {List.map Subtree1.sem SimplifyTree}
%       }
%    [] constant_temp1(Subtree1 Subtree2) then
%       S1 = Subtree1.sem
%       S2 = {SimplifyTree Subtree2}
%    in
%       '#'(S1 S2)
%    [] constant_temp2(Subtree1) then
%       {List.map
%        Subtree1.sem
%        fun {$ X} X.sem end
%       }
%    [] var_atom(Subtree1) then
%       Subtree1.sem
%    else
%       'No Match'
%    end
% end
% {Inspect "Simplify Tree Aufruf"}
% CleanedTree = {SimplifyTree Parsed}
% {Inspect "Simplify Tree Ausgabe"}
% {Inspect CleanedTree}

% declare
% {Inspector.configure widgetShowStrings true}
% %%%%%%%
% % Parsetree weiterverarbeiten
% fun {BuildPrinciple CleanTree}
%    case CleanTree
%    of forall(Node Subtree1) then
%       "ForAllNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end "
%    [] exists(Node Subtree1) then
%       "ExistsNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end"
%    [] existsone(Node Subtree1) then
%       "ExistsOneNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end"
%    [] 'Or'(Subtree1 Subtree2) then
%       "Disj {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} "
%    [] 'And'(Subtree1 Subtree2) then
%       "Conj {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
%    [] 'Imp'(Subtree1 Subtree2) then
%       "Impl {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
%    [] 'Iff'(Subtree1 Subtree2) then
%       "Equi {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
%    [] 'Not'(Subtree1) then
%       "Nega {"#{BuildPrinciple Subtree1}#"} "
%    [] 'Dim'(Node1 Dim Node2) then
%       "Edge "#Node1#" "#Node2#" "#Dim
%    [] 'DimLabel'(Node1 Dim Label Node2) then
%       "LabeledEdge "#Node1#" "#Node2#" "#Dim#" "#Label
%    [] 'DimPlus'(Node1 Dim Node2) then
%       "StrictDominance "#Node1#" "#Node2#" "#Dim
%    else
%       'No Match'
%    end
% end
% {Inspect "CleanTree Aufruf"}
% Principle = "proc {myPrinciple NodeRecs} {"#{BuildPrinciple CleanedTree}#" 1} end"
% {Inspect {VirtualString.toAtom Principle}}
% {Browse {VirtualString.toAtom Principle}}
% {Show {VirtualString.toAtom Principle}}
% declare
% S1 = "hallo"
% S2 = "welt"
% S3 = {Append S1 S2}
% {Inspect S3}
