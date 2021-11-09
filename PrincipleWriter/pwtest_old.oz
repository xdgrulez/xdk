declare
[TokenizerGen] = {Module.link ['TokenizerGen.ozf']}
[LALRGen] = {Module.link ['LALRGen.ozf']}
%%
Tokenizer =
{TokenizerGen.newTokenizer
 o(operators:
      [
       "=" "=>" "<=>" "&" "|" "<" ":" "(" ")" "{" "}" "[" "]" "+" "*" 
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
       "exists" "existsone" "forall" "not" "edge" "dom"
      ]
  )}
%%
GrammarRec =
grammar(
   tokens : [
	     '<id>' '<sstring>' '<dstring>' '<gstring>' '<int>'
	     '=' '=>'#left(40) '<=>'#left(40) '&'#left(40) '|'#left(40) '<' ':'#left(30) '(' ')' '{' '}' '[' ']' '+' '*'
	     'exists' 'existsone' 'forall'#right(40) 'not'#left(30) 'edge' 'dom'
	    ]
   start  : 'Sentence'
   rules  :
      [
       rule(head:'Sentence' body:['AtomicSentence']
	    action:sentence_AtomicSentence(1))
       rule(head:'Sentence' body:['Sentence' '=>' 'Sentence']
	    action:sentence_ImpSentence(1 3))
       rule(head:'Sentence' body:['Sentence' '<=>' 'Sentence']
	    action:sentence_IffSentence(1 3))
       rule(head:'Sentence' body:['Sentence' '&' 'Sentence']
	    action:sentence_AndSentence(1 3))
       rule(head:'Sentence' body:['Sentence' '|' 'Sentence']
	    action:sentence_OrSentence(1 3))
       rule(head:'Sentence' body:['Quantifier' 'Variable' ':' 'Sentence']
	    action:sentence_qvsentence(1 2 4))
       rule(head:'Sentence' body:['(' 'Quantifier' 'Variable' ':' 'Sentence' ')']
	    action:sentence_qvsentence(2 3 5))
%       rule(head:'Sentence' body:['Quantifier' 'Node' ':' 'Sentence']
%	    action:sentence_qnsentence(1 2 4))
       rule(head:'Sentence' body:['not' 'Sentence']
	    action:sentence_nsentence(2))
       rule(head:'Sentence' body:['(' 'not' 'Sentence' ')']
	    action:sentence_nsentence(3))
       %%
       rule(head:'Quantifier' body:['exists']
	    action:quantifier_exists(1))
       rule(head:'Quantifier' body:['existsone']
	    action:quantifier_existsone(1))
       rule(head:'Quantifier' body:['forall']
	    action:quantifier_forall(1))
       %%
       rule(head:'AtomicSentence' body:['Term' '=' 'Term']
	    action:atomicsentence_eq(1 3))
       rule(head:'AtomicSentence' body:['MTerm']
	    action:atomicsentence_mterm(1))
       %%
       rule(head:'MTerm' body:['Term']
	    action:mterm_node(1))
       rule(head:'MTerm' body:['(' 'Term' 'Term' 'Term' 'Term' ')']
	    action:mterm_dimlabel(2 3 4 5))
       rule(head:'MTerm' body:['(' 'Term' 'Term' 'Term' ')']
	    action:mterm_dim(2 3 4 ))
       rule(head:'MTerm' body:['(' 'Term' 'Term' '+' 'Term' ')']
	    action:mterm_dimplus(2 3 4 5))
       rule(head:'MTerm' body:['(' 'Term' 'Term' '*' 'Term' ')']
	    action:mterm_dimstar(2 3 4 5))
       rule(head:'MTerm' body:['Term' '<' 'Term']
	    action:mterm_nodeless(1 3))
       %%
%       rule(head:'Term' body:['Variable']
%	    action:term_var(1))
       rule(head:'Term' body:['Constant']
	    action:term_con(1))
       %%
       rule(head:'Constant' body:['Atom']
	   action:con_atom(1))
       rule(head:'Constant' body:['{' '+'('constant_temp1') '}']
	   action:con_rec(2))
       rule(head:'Constant' body:['[' '+'('Atom') ']']
	   action:con_tup(2))
       rule(head:'Constant' body:['{' '+'('constant_temp2') '}']
	   action:con_set(2))
       %%
       rule(head:'constant_temp1' body:['Atom' ':' 'Term']
	   action:constant_temp1(1 3))
       %%
       rule(head:'constant_temp2' body:['[' '+'('Atom') ']']
	   action:constant_temp2(2))       
       %%
       rule(head:'Variable' body:['Atom']
	    action:var_atom(1))
       %%
%       rule(head:'Node' body:['Atom']
%	    action:var_node(1))
       %%
%       rule(head:'Dim' body:['Atom']
%	    action:var_atom(1))
       %% 
%       rule(head:'Label' body:['Atom']
%	    action:var_atom(1))
       %%
       rule(head:'Atom' body:['<id>']
	    action:1)
       rule(head:'Atom' body:['<sstring>']
	    action:1)
       rule(head:'Atom' body:['<dstring>']
	    action:1)
      ]
   )
Parser = {LALRGen.makeLALR GrammarRec}
%
S = "not exists v: (v d * v)"
T = "forall v: (v d * v) & (v d * v)"
OneRoot = "forall v: (existsone v2: (v2 d v)) | (not exists v1: (v1 d v)) "
%%
OneRoot2 = "existsone v: not exists v2: (v2 d v)"
NoCycles = "forall v: not (v d + v)"
AtMostOneMother = "forall v: (not exists v1: (v1 d v)) | (existsone v1: (v1 d v))"
%%
Testy_Tuple = "[v1 v2 v3]"
Testy_Record = "{v1:var1 v2:var2 v3:var3 }"
Testy_Set = "{[v1 v2 v3] [b1 b2] [k1 k2 k3 k4]}"
%
%Tokenized = {Tokenizer.fromString OneRoot}
Tokenized = {Tokenizer.fromString AtMostOneMother}
{Inspect Tokenized}
Parsed = {Parser Tokenized}
{Inspect Parsed}

declare
{Inspector.configure widgetShowStrings true}
%%%%%%%
% Parsetree weiterverarbeiten
fun {SimplifyTree Parsetree}
   Coord1 = Parsetree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Parsetree.file
   File = if File1==unit then noFile else File1 end
   Sem = Parsetree.sem
in
   case Sem
   %% sentence ->
   of sentence_nsentence(Subtree1) then
      S = {SimplifyTree Subtree1}
   in
      'Not'(S)
   [] sentence_AtomicSentence(Subtree1) then
      {SimplifyTree Subtree1}
%%   in
  %%    sentence_AtomicSentence(S)
   [] sentence_ImpSentence(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'Imp'(S1 S2) 
   [] sentence_IffSentence(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'Iff'(S1 S2)
   [] sentence_AndSentence(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'And'(S1 S2)
   [] sentence_OrSentence(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'Or'(S1 S2)
   [] sentence_qvsentence(Subtree1 Subtree2 Subtree3) then
%      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
      S3 = {SimplifyTree Subtree3}
      E
      case Subtree1.sem
      of quantifier_exists(...) then
	 E = 'exists'(S2 S3)
      [] quantifier_forall(...) then
	 E = 'forall'(S2 S3)
      [] 'quantifier_existsone'(...) then
	 E = 'existsone'(S2 S3)
      end
   in
     E
   %% Quantifier ->
%%   [] quantifier_exists(...) then
%%     'Exists'
%%   [] quantifier_existsone(...) then
%%      'ExistsOne'
%%   [] quantifier_forall(...) then
%%      'ForAll'
   %% AtomicSentence ->
   [] atomicsentence_eq(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'Eq'(S1 S2)
   [] atomicsentence_mterm(Subtree1) then
      {SimplifyTree Subtree1}
      %% Mterm ->
   [] mterm_node(Subtree1) then
     {SimplifyTree Subtree1}
   [] mterm_dimlabel(Subtree1 Subtree2 Subtree3 Subtree4) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
      S3 = {SimplifyTree Subtree3}
      S4 = {SimplifyTree Subtree4}
   in
      'DimLabel'(S1 S2 S3 S4)
   [] mterm_dim(Subtree1 Subtree2 Subtree3) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
      S3 = {SimplifyTree Subtree3}
   in
      'Dim'(S1 S2 S3)
   [] mterm_dimplus(Subtree1 Subtree2 _ Subtree3) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
      S3 = {SimplifyTree Subtree3}
   in
      'DimPlus'(S1 S2 S3)
   [] mterm_dimstar(Subtree1 Subtree2 _ Subtree3) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
      S3 = {SimplifyTree Subtree3}
   in
      'DimStar'(S1 S2 S3)
   [] mterm_nodeless(Subtree1 Subtree2) then
      S1 = {SimplifyTree Subtree1}
      S2 = {SimplifyTree Subtree2}
   in
      'NodeLess'(S1 S2)
      %% Term ->
   [] term_con(Subtree1) then
      {SimplifyTree Subtree1}
      %% Constant ->
   [] con_atom(Subtree1) then
      Subtree1.sem
   [] con_rec(List1) then
      {List.toTuple
       'Record'
       {List.map List1.sem SimplifyTree}
      }
   [] con_tup(List1) then
      S1 = List1.sem
   in
      {List.toTuple 'Tuple'
       {List.map
	S1
	fun {$ X} X.sem end} 
      }
   [] con_set(Subtree1) then
      {List.toTuple
       'Set'
       {List.map Subtree1.sem SimplifyTree}
      }
   [] constant_temp1(Subtree1 Subtree2) then
      S1 = Subtree1.sem
      S2 = {SimplifyTree Subtree2}
   in
      '#'(S1 S2)
   [] constant_temp2(Subtree1) then
      {List.map
       Subtree1.sem
       fun {$ X} X.sem end
      }
   [] var_atom(Subtree1) then
      Subtree1.sem
   else
      'No Match'
   end
end
{Inspect "Simplify Tree Aufruf"}
CleanedTree = {SimplifyTree Parsed}
{Inspect "Simplify Tree Ausgabe"}
{Inspect CleanedTree}

declare
{Inspector.configure widgetShowStrings true}
%%%%%%%
% Parsetree weiterverarbeiten
fun {BuildPrinciple CleanTree}
   case CleanTree
   of forall(Node Subtree1) then
      "ForAllNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end "
   [] exists(Node Subtree1) then
      "ExistsNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end"
   [] existsone(Node Subtree1) then
      "ExistsOneNodes NodeRecs fun {$ "#Node#"} {"#{BuildPrinciple Subtree1}#"} end"
   [] 'Or'(Subtree1 Subtree2) then
      "Disj {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} "
   [] 'And'(Subtree1 Subtree2) then
      "Conj {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
   [] 'Imp'(Subtree1 Subtree2) then
      "Impl {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
   [] 'Iff'(Subtree1 Subtree2) then
      "Equi {"#{BuildPrinciple Subtree1}#"} {"#{BuildPrinciple Subtree2}#"} " 
   [] 'Not'(Subtree1) then
      "Nega {"#{BuildPrinciple Subtree1}#"} "
   [] 'Dim'(Node1 Dim Node2) then
      "Edge "#Node1#" "#Node2#" "#Dim
   [] 'DimLabel'(Node1 Dim Label Node2) then
      "LabeledEdge "#Node1#" "#Node2#" "#Dim#" "#Label
   [] 'DimPlus'(Node1 Dim Node2) then
      "StrictDominance "#Node1#" "#Node2#" "#Dim
   else
      'No Match'
   end
end
{Inspect "CleanTree Aufruf"}
Principle = "proc {myPrinciple NodeRecs} {"#{BuildPrinciple CleanedTree}#" 1} end"
{Inspect {VirtualString.toAtom Principle}}
{Browse {VirtualString.toAtom Principle}}
{Show {VirtualString.toAtom Principle}}
declare
S1 = "hallo"
S2 = "welt"
S3 = {Append S1 S2}
{Inspect S3}
