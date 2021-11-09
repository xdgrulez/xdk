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
       rule(head:'Type' body:['tuple' '(' '+'('Dom') ')']
	    action:ttuple(3))
       rule(head:'Type' body:['set' '(' 'tuple' '(' '+'('Dom') ')' ')']
	    action:tset(5))
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
       rule(head:'Form' body:['Expr' 'intersect' 'Expr' = 'Expr']
	    action:intersect(1 3 5))
       rule(head:'Form' body:['Expr' 'union' 'Expr' = 'Expr']
	    action:union(1 3 5))
       rule(head:'Form' body:['Expr' 'minus' 'Expr' = 'Expr']
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
       rule(head:'Expr' body:['{' '+'('Term') '}']
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
       rule(head:'Expr' body:['(' 'Expr' ')']
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
%
{Inspect 'generating parser...'}
Parser = {LALRGen.makeLALR GrammarRec}
{Inspect 'done.'}

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
{Inspector.configure widgetShowStrings true}
{Inspector.configure widgetTreeDepth 50}
%%
S2A = String.toAtom
V2A = VirtualString.toAtom
V2S = VirtualString.toString
A2S = Atom.toString
S2I = String.toInt
%%
ListMapInd = List.mapInd
ListToRecord = List.toRecord
%%
proc {PutV V UrlV}
   FileO = {New Open.file init(name: UrlV
			       flags: [create truncate write text])}
in
   {FileO write(vs: V)}
   {FileO close}
end
%%
fun {Vs2ListV Vs}
   if Vs==nil then
      nil
   else
      V1|Vs1 = Vs
   in
      '['#{FoldL Vs1 fun {$ AccV V} AccV#' '#V end V1}#']'
   end
end
%%
fun {ConstantTree2A ConstantTree}
   {V2A ConstantTree.sem.1.sem}
end
%%
fun {TermTree2AI TermTree}
   case TermTree
   of value(sem:constant(token(sem:Sem ...)) ...) then
      {V2A Sem}
   [] value(sem:integer(token(sem:Sem ...)) ...) then
      {S2I {V2S Sem}}
   end
end
%%
fun {T2V T}
   case T
   of dom(As) then
      Vs = {Map As
	    fun {$ A} '\''#A#'\'' end}
      V = {Vs2ListV Vs}
   in
      'dom('#V#')'
   [] label(A) then
      'label(\''#A#'\')'
   [] node then
      'node'
   [] dim then
      'dim'
   [] 'attr' then
      'attr'
   [] word then
      'word'
   [] set(Dom) then
      V = {T2V Dom}
   in
      'set('#V#')'
   [] tuple(Doms) then
      Vs = {Map Doms T2V}
      V = {Vs2ListV Vs}
   in
      'tuple('#V#')'
   end
end
%%
fun {Tree2T Tree ConstantATypeTreeRec}
   Coord1 = Tree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Tree.file
   File = if File1==unit then noFile else File1 end
   Sem = Tree.sem
in   
   case Sem
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% domain
   of dom(ConstantTreeList) then
      ConstantAs = {Map ConstantTreeList.sem ConstantTree2A}
   in
      dom(ConstantAs)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% edge labels
   [] edgelabels(ConstantTree) then
      ConstantA = {ConstantTree2A ConstantTree}
   in
      label(ConstantA)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% nodes
   [] node(...) then
      node
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% dimensions
   [] dim(...) then
      dim
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% attributes
   [] 'attr'(...) then
      'attr'
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% word
   [] word(...) then
      word
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% type reference
   [] tref(ConstantTree) then
      ConstantA = {ConstantTree2A ConstantTree}
      TypeTree = ConstantATypeTreeRec.ConstantA
      T = {Tree2T TypeTree ConstantATypeTreeRec}
   in
      T
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% set
   [] tset(ConstantTree) then
      ConstantA = {ConstantTree2A ConstantTree}
   in
      set(ConstantA)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% tuple
   [] ttuple(ConstantTreeList) then
      ConstantAs = {Map ConstantTreeList.sem
		    fun {$ ConstantTree}
		       {Tree2T ConstantTree ConstantATypeTreeRec}
		    end}
   in
      tuple(ConstantAs)
   end
end
%%
fun {IsOptimizableImpl Tree}
   Coord1 = Tree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Tree.file
   File = if File1==unit then noFile else File1 end
   Sem = Tree.sem
in
   case Sem
%       %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% negation
%    of neg(FormTree) then
%       {IsOptimizableImpl FormTree}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% conjunction
   of conj(FormTree1 FormTree2) then
      {IsOptimizableImpl FormTree1} andthen {IsOptimizableImpl FormTree2}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% disjunction
   [] disj(FormTree1 FormTree2) then
      {IsOptimizableImpl FormTree1} andthen {IsOptimizableImpl FormTree2}
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% element
   [] 'in'(_ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% not element
   [] notin(_ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled edge
   [] ledge(_ _ _ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% edge
   [] edge(_ _ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled strict dominance
   [] ldom(_ _ _ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% strict dominance
   [] dom(_ _ _) then
      true
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% dominance
   [] domeq(_ _ _) then
      true
   else
      false
   end
end
%%
fun {Tree2OptiTree Tree}
   Coord1 = Tree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Tree.file
   File = if File1==unit then noFile else File1 end
   Sem = Tree.sem
   Sem1 =
   case Sem
%       %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %% negation
%    of neg(FormTree) then
%       FormTree1 = {Tree2OptiTree FormTree}
%    in
%       optiNeg(FormTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% conjunction
   of conj(FormTree1 FormTree2) then
      FormTree11 = {Tree2OptiTree FormTree1}
      FormTree21 = {Tree2OptiTree FormTree2}
   in
      optiConj(FormTree11 FormTree21)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% disjunction
   [] disj(FormTree1 FormTree2) then
      FormTree11 = {Tree2OptiTree FormTree1}
      FormTree21 = {Tree2OptiTree FormTree2}
   in
      optiDisj(FormTree11 FormTree21)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% element
   [] 'in'(ExprTree1 ExprTree2) then
      optiIn(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% not element
   [] notin(ExprTree1 ExprTree2) then
      optiNotin(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled edge
   [] ledge(TermTree1 TermTree2 TermTree3 TermTree4) then
      optiLedge(TermTree1 TermTree2 TermTree3 TermTree4)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% edge
   [] edge(TermTree1 TermTree2 TermTree3) then
      optiEdge(TermTree1 TermTree2 TermTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled strict dominance
   [] ldom(TermTree1 TermTree2 TermTree3 TermTree4) then
      optiLdom(TermTree1 TermTree2 TermTree3 TermTree4)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% strict dominance
   [] dom(TermTree1 TermTree2 TermTree3) then
      optiDom(TermTree1 TermTree2 TermTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% dominance
   [] domeq(TermTree1 TermTree2 TermTree3) then
      optiDomeq(TermTree1 TermTree2 TermTree3)
   end
in
   value(coord: Tree.coord
	 file: Tree.file
	 sem: Sem1)
end
%%
fun {Optimize Tree}
   Coord1 = Tree.coord
   Coord = if Coord1==unit then noCoord else Coord1 end
   File1 = Tree.file
   File = if File1==unit then noFile else File1 end
   Sem = Tree.sem
   Sem1 =
   case Sem
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% S
   of s(DefTypeTreeList DefPrincipleTreeList) then
      DefPrincipleTreeList1 =
      value(coord: DefPrincipleTreeList.coord
	    file: DefPrincipleTreeList.file
	    sem: {Map DefPrincipleTreeList.sem Optimize})
   in
      s(DefTypeTreeList DefPrincipleTreeList1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% principle definition
   [] defprinciple(ConstantTree DimsTree ConstraintsTree) then
      ConstraintsTree1 = {Optimize ConstraintsTree}
   in
      defprinciple(ConstantTree DimsTree ConstraintsTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% constraints
   [] constraints(FormTreeList) then
      FormTreeList1 =
      value(coord: FormTreeList.coord
	    file: FormTreeList.file
	    sem: {Map FormTreeList.sem Optimize})
   in
      constraints(FormTreeList1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiDisjointSubtreesL
   [] forall(ConstantTree1
	     DomTree1
	     value(sem:forall(ConstantTree2
			      _
			      value(sem:forall(ConstantTree3
					       _
					       value(sem:impl(value(sem:conj(value(sem:ldom(TermTree1
											    TermTree2
											    TermTree3
											    TermTree4) ...)
									     value(sem:ldom(TermTree5
											    TermTree6
											    TermTree7
											    TermTree8) ...)) ...)
							      value(sem:eq(TermTree9
									   TermTree10) ...)) ...)) ...)) ...)) then
      ConstantA1 = {ConstantTree2A ConstantTree1}
      ConstantA2 = {ConstantTree2A ConstantTree2}
      ConstantA3 = {ConstantTree2A ConstantTree3}
      %%
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI4 = {TermTree2AI TermTree4}
      TermAI5 = {TermTree2AI TermTree5}
      TermAI6 = {TermTree2AI TermTree6}
      TermAI7 = {TermTree2AI TermTree7}
      TermAI8 = {TermTree2AI TermTree8}
      TermAI9 = {TermTree2AI TermTree9}
      TermAI10 = {TermTree2AI TermTree10}
   in
      if TermAI1==TermAI5 andthen % V
	 ConstantA1==TermAI2 andthen % V1
	 TermAI2==TermAI6 andthen
	 ConstantA2==TermAI3 andthen % L
	 TermAI3==TermAI9 andthen
	 ConstantA3==TermAI7 andthen % L1
	 TermAI7==TermAI10 andthen
	 TermAI4==TermAI8 andthen % D
	 {Not TermAI1==ConstantA1} andthen
	 {Not ConstantA1==ConstantA2} then
	 optiDisjointSubtreesL(TermTree1 TermTree4)
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 forall(ConstantTree1 DomTree1 FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiEqPrecDaughtersL/optiDaughtersLPrecEq
   [] forall(ConstantTree
	     DomTree
	     value(sem:impl(value(sem:ledge(TermTree1
					    TermTree2
					    TermTree3
					    TermTree4) ...)
			    value(sem:prec(TermTree5
					   TermTree6) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      %%
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI5 = {TermTree2AI TermTree5}
      TermAI6 = {TermTree2AI TermTree6}
   in
      if ConstantA==TermAI2 andthen
	 {Not TermAI1==ConstantA} then
	 if TermAI1==TermAI5 andthen
	    TermAI2==TermAI6 then
	    optiEqPrecDaughtersL(TermTree1 TermTree3 TermTree4)
	 elseif TermAI1==TermAI6 andthen
	    TermAI2==TermAI5 then
	    optiDaughtersLPrecEq(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree = Sem.3
	    FormTree1 = {Optimize FormTree}
	 in
	    forall(ConstantTree DomTree FormTree1)
	 end
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 forall(ConstantTree DomTree FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiDaughtersLPrecDaughtersL
   [] forall(ConstantTree1
	     DomTree1
	     value(sem:forall(ConstantTree2
			      _
			      value(sem:impl(value(sem:conj(value(sem:ledge(TermTree1
									    TermTree2
									    TermTree3
									    TermTree4) ...)
							    value(sem:ledge(TermTree5
									    TermTree6
									    TermTree7
									    TermTree8) ...)) ...)
					     value(sem:prec(TermTree9
							    TermTree10) ...)) ...)) ...)) then
      ConstantA1 = {ConstantTree2A ConstantTree1}
      ConstantA2 = {ConstantTree2A ConstantTree2}
      %%
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI4 = {TermTree2AI TermTree4}
      TermAI5 = {TermTree2AI TermTree5}
      TermAI6 = {TermTree2AI TermTree6}
      TermAI8 = {TermTree2AI TermTree8}
      TermAI9 = {TermTree2AI TermTree9}
      TermAI10 = {TermTree2AI TermTree10}
   in
      if TermAI1==TermAI5 andthen % V
	 ConstantA1==TermAI2 andthen % V1
	 TermAI2==TermAI9 andthen
	 ConstantA2==TermAI6 andthen % V2
	 TermAI6==TermAI10 andthen
	 TermAI4==TermAI8 andthen % D
	 {Not TermAI1==ConstantA1} andthen
	 {Not ConstantA1==ConstantA2} then
	 optiDaughtersLPrecDaughtersL(TermTree1 TermTree3 TermTree7 TermTree4)
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 forall(ConstantTree1 DomTree1 FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiProjective
   [] forall(ConstantTree1
	     DomTree1
	     value(sem:forall(ConstantTree2
			      _
			      value(sem:conj(value(sem:impl(value(sem:conj(value(sem:edge(TermTree1
											  TermTree2
											  TermTree3) ...)
									   value(sem:prec(TermTree4
											  TermTree5) ...)) ...)
							    value(sem:forall(ConstantTree3
									     _
									     value(sem:impl(value(sem:conj(value(sem:prec(TermTree6
															  TermTree7) ...)
													   value(sem:prec(TermTree8
															  TermTree9) ...)) ...)
											    value(sem:dom(TermTree10
													  TermTree11
													  TermTree12) ...)) ...)) ...)) ...)
					     value(sem:impl(value(sem:conj(value(sem:edge(TermTree13
											  TermTree14
											  TermTree15) ...)
									   value(sem:prec(TermTree16
											  TermTree17) ...)) ...)
							    value(sem:forall(ConstantTree4
									     _
									     value(sem:impl(value(sem:conj(value(sem:prec(TermTree18
															  TermTree19) ...)
													   value(sem:prec(TermTree20
															  TermTree21) ...)) ...)
											    value(sem:dom(TermTree22
													  TermTree23
													  TermTree24) ...)) ...)) ...)) ...)) ...)) ...)) then
      ConstantA1 = {ConstantTree2A ConstantTree1}
      ConstantA2 = {ConstantTree2A ConstantTree2}
      ConstantA3 = {ConstantTree2A ConstantTree3}
      ConstantA4 = {ConstantTree2A ConstantTree4}
      %%
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI4 = {TermTree2AI TermTree4}
      TermAI5 = {TermTree2AI TermTree5}
      TermAI6 = {TermTree2AI TermTree6}
      TermAI7 = {TermTree2AI TermTree7}
      TermAI8 = {TermTree2AI TermTree8}
      TermAI9 = {TermTree2AI TermTree9}
      TermAI10 = {TermTree2AI TermTree10}
      TermAI11 = {TermTree2AI TermTree11}
      TermAI12 = {TermTree2AI TermTree12}
      TermAI13 = {TermTree2AI TermTree13}
      TermAI14 = {TermTree2AI TermTree14}
      TermAI15 = {TermTree2AI TermTree15}
      TermAI16 = {TermTree2AI TermTree16}
      TermAI17 = {TermTree2AI TermTree17}
      TermAI18 = {TermTree2AI TermTree18}
      TermAI19 = {TermTree2AI TermTree19}
      TermAI20 = {TermTree2AI TermTree20}
      TermAI21 = {TermTree2AI TermTree21}
      TermAI22 = {TermTree2AI TermTree22}
      TermAI23 = {TermTree2AI TermTree23}
      TermAI24 = {TermTree2AI TermTree24}
   in
      if ConstantA1==TermAI1 andthen % V
	 TermAI1==TermAI4 andthen
	 TermAI4==TermAI6 andthen
	 TermAI6==TermAI10 andthen
	 TermAI10==TermAI13 andthen
	 TermAI13==TermAI17 andthen
	 TermAI17==TermAI21 andthen
	 TermAI21==TermAI22 andthen
	 %%
	 ConstantA2==TermAI2 andthen % V1
	 TermAI2==TermAI5 andthen
	 TermAI5==TermAI9 andthen
	 TermAI9==TermAI11 andthen
	 TermAI11==TermAI14 andthen
	 TermAI14==TermAI16 andthen
	 TermAI16==TermAI18 andthen
	 TermAI18==TermAI23 andthen
	 %%
	 ConstantA3==TermAI7 andthen % V2
	 TermAI7==TermAI8 andthen
	 TermAI8==ConstantA4 andthen
	 ConstantA4==TermAI19 andthen
	 TermAI19==TermAI20 andthen
	 %%
	 TermAI3==TermAI12 andthen % D
	 TermAI12==TermAI15 andthen
	 TermAI15==TermAI24 andthen
	 %%
	 {Not ConstantA1==ConstantA2} andthen
	 {Not ConstantA2==ConstantA3} then
	 optiProjective(TermTree3)
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 forall(ConstantTree1 DomTree1 FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiZeroOrOneMothersL/optiZeroOrOneDaughtersL
   [] disj(value(sem:neg(value(sem:exists(ConstantTree
					  _
					  value(sem:ledge(TermTree1
							  TermTree2
							  TermTree3
							  TermTree4) ...)) ...)) ...)
	   value(existsone(ConstantTree1
			   _
			   value(sem:ledge(TermTree11
					   TermTree21
					   TermTree31
					   TermTree41) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      ConstantA1 = {ConstantTree2A ConstantTree1}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI11 = {TermTree2AI TermTree11}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI21 = {TermTree2AI TermTree21}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI31 = {TermTree2AI TermTree31}
      TermAI4 = {TermTree2AI TermTree4}
      TermAI41 = {TermTree2AI TermTree41}
   in
      if ConstantA==ConstantA1 andthen
	 TermAI1==TermAI11 andthen
	 TermAI2==TermAI21 andthen
	 TermAI3==TermAI31 andthen
	 TermAI4==TermAI41 andthen
	 {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroOrOneMothersL(TermTree2 TermTree3 TermTree4)
	 elseif ConstantA==TermAI2 then
	    optiZeroOrOneDaughtersL(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree1 = Sem.1
	    FormTree2 = Sem.2
	    FormTree11 = {Optimize FormTree1}
	    FormTree21 = {Optimize FormTree2}
	 in
	    disj(FormTree11 FormTree21)
	 end
      else
	 FormTree1 = Sem.1
	 FormTree2 = Sem.2
	 FormTree11 = {Optimize FormTree1}
	 FormTree21 = {Optimize FormTree2}
      in
	 disj(FormTree11 FormTree21)
      end
   [] disj(value(sem:existsone(ConstantTree1
			       _
			       value(sem:ledge(TermTree11
					       TermTree21
					       TermTree31
					       TermTree41) ...)) ...)
	   value(sem:neg(value(sem:exists(ConstantTree
					  _
					  value(sem:ledge(TermTree1
							  TermTree2
							  TermTree3
							  TermTree4) ...)) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      ConstantA1 = {ConstantTree2A ConstantTree1}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI11 = {TermTree2AI TermTree11}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI21 = {TermTree2AI TermTree21}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI31 = {TermTree2AI TermTree31}
      TermAI4 = {TermTree2AI TermTree4}
      TermAI41 = {TermTree2AI TermTree41}
   in
      if ConstantA==ConstantA1 andthen
	 TermAI1==TermAI11 andthen
	 TermAI2==TermAI21 andthen
	 TermAI3==TermAI31 andthen
	 TermAI4==TermAI41 andthen
	 {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroOrOneMothersL(TermTree2 TermTree3 TermTree4)
	 elseif ConstantA==TermAI2 then
	    optiZeroOrOneDaughtersL(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree1 = Sem.1
	    FormTree2 = Sem.2
	    FormTree11 = {Optimize FormTree1}
	    FormTree21 = {Optimize FormTree2}
	 in
	    disj(FormTree11 FormTree21)
	 end
      else
	 FormTree1 = Sem.1
	 FormTree2 = Sem.2
	 FormTree11 = {Optimize FormTree1}
	 FormTree21 = {Optimize FormTree2}
      in
	 disj(FormTree11 FormTree21)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiZeroOrOneMothers/optiZeroOrOneDaughters
   [] disj(value(sem:neg(value(sem:exists(ConstantTree
					  _
					  value(sem:edge(TermTree1
							 TermTree2
							 TermTree3) ...)) ...)) ...)
	   value(sem:existsone(ConstantTree1
			       _
			       value(sem:edge(TermTree11
					      TermTree21
					      TermTree31) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      ConstantA1 = {ConstantTree2A ConstantTree1}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI11 = {TermTree2AI TermTree11}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI21 = {TermTree2AI TermTree21}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI31 = {TermTree2AI TermTree31}
   in
      if ConstantA==ConstantA1 andthen
	 TermAI1==TermAI11 andthen
	 TermAI2==TermAI21 andthen
	 TermAI3==TermAI31 andthen
	 {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroOrOneMothers(TermTree2 TermTree3)
	 elseif ConstantA==TermAI2 then
	    optiZeroOrOneDaughters(TermTree1 TermTree3)
	 else
	    FormTree1 = Sem.1
	    FormTree2 = Sem.2
	    FormTree11 = {Optimize FormTree1}
	    FormTree21 = {Optimize FormTree2}
	 in
	    disj(FormTree11 FormTree21)
	 end
      else
	 FormTree1 = Sem.1
	 FormTree2 = Sem.2
	 FormTree11 = {Optimize FormTree1}
	 FormTree21 = {Optimize FormTree2}
      in
	 disj(FormTree11 FormTree21)
      end
   [] disj(value(sem:existsone(ConstantTree1
			       _
			       value(sem:edge(TermTree11
					      TermTree21
					      TermTree31) ...)) ...)
	   value(sem:neg(value(sem:exists(ConstantTree
					  _
					  value(sem:edge(TermTree1
							 TermTree2
							 TermTree3) ...)) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      ConstantA1 = {ConstantTree2A ConstantTree1}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI11 = {TermTree2AI TermTree11}
      TermAI2 = {TermTree2AI TermTree2}
      TermAI21 = {TermTree2AI TermTree21}
      TermAI3 = {TermTree2AI TermTree3}
      TermAI31 = {TermTree2AI TermTree31}
   in
      if ConstantA==ConstantA1 andthen
	 TermAI1==TermAI11 andthen
	 TermAI2==TermAI21 andthen
	 TermAI3==TermAI31 andthen
	 {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroOrOneMothers(TermTree2 TermTree3)
	 elseif ConstantA==TermAI2 then
	    optiZeroOrOneDaughters(TermTree1 TermTree3)
	 else
	    FormTree1 = Sem.1
	    FormTree2 = Sem.2
	    FormTree11 = {Optimize FormTree1}
	    FormTree21 = {Optimize FormTree2}
	 in
	    disj(FormTree11 FormTree21)
	 end
      else
	 FormTree1 = Sem.1
	 FormTree2 = Sem.2
	 FormTree11 = {Optimize FormTree1}
	 FormTree21 = {Optimize FormTree2}
      in
	 disj(FormTree11 FormTree21)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiZeroMothersL/optiZeroDaughtersL
   [] neg(value(sem:exists(ConstantTree
			   _
			   value(sem:ledge(TermTree1
					   TermTree2
					   TermTree3
					   TermTree4) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroMothersL(TermTree2 TermTree3 TermTree4)
	 elseif ConstantA==TermAI2 then
	    optiZeroDaughtersL(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree = Sem.1
	    FormTree1 = {Optimize FormTree}
	 in
	    neg(FormTree1)
	 end
      else
	 FormTree = Sem.1
	 FormTree1 = {Optimize FormTree}
      in
	 neg(FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiZeroMothers/optiZeroDaughters
   [] neg(value(sem:exists(ConstantTree
			   _
			   value(sem:edge(TermTree1
					  TermTree2
					  TermTree3) ...)) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiZeroMothers(TermTree2 TermTree3)
	 elseif ConstantA==TermAI2 then
	    optiZeroDaughters(TermTree1 TermTree3)
	 else
	    FormTree = Sem.1
	    FormTree1 = {Optimize FormTree}
	 in
	    neg(FormTree1)
	 end
      else
	 FormTree = Sem.1
	 FormTree1 = {Optimize FormTree}
      in
	 neg(FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiOneOrMoreMothersL/optiOneOrMoreDaughtersL
   [] exists(ConstantTree
	     DomTree
	     value(sem:ledge(TermTree1
			     TermTree2
			     TermTree3
			     TermTree4) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiOneOrMoreMothersL(TermTree2 TermTree3 TermTree4)
	 elseif ConstantA==TermAI2 then
	    optiOneOrMoreDaughtersL(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree = Sem.3
	    FormTree1 = {Optimize FormTree}
	 in
	    exists(ConstantTree DomTree FormTree1)
	 end
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 exists(ConstantTree DomTree FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiOneOrMoreMothers/optiOneOrMoreDaughters
   [] exists(ConstantTree
	     DomTree
	     value(sem:edge(TermTree1
			    TermTree2
			    TermTree3) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiOneOrMoreMothers(TermTree2 TermTree3)
	 elseif ConstantA==TermAI2 then
	    optiOneOrMoreDaughters(TermTree1 TermTree3)
	 else
	    FormTree = Sem.3
	    FormTree1 = {Optimize FormTree}
	 in
	    exists(ConstantTree DomTree FormTree1)
	 end
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 exists(ConstantTree DomTree FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiOneMotherL/optiOneDaughterL
   [] existsone(ConstantTree
		DomTree
		value(sem:ledge(TermTree1
				TermTree2
				TermTree3
				TermTree4) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiOneMotherL(TermTree2 TermTree3 TermTree4)
	 elseif ConstantA==TermAI2 then
	    optiOneDaughterL(TermTree1 TermTree3 TermTree4)
	 else
	    FormTree = Sem.3
	    FormTree1 = {Optimize FormTree}
	 in
	    existsone(ConstantTree DomTree FormTree1)
	 end
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 existsone(ConstantTree DomTree FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% optiOneMother/optiOneDaughter
   [] existsone(ConstantTree
		DomTree
		value(sem:edge(TermTree1
			       TermTree2
			       TermTree3) ...)) then
      ConstantA = {ConstantTree2A ConstantTree}
      TermAI1 = {TermTree2AI TermTree1}
      TermAI2 = {TermTree2AI TermTree2}
   in
      if {Not TermAI1==TermAI2} then
	 if ConstantA==TermAI1 then
	    optiOneMother(TermTree2 TermTree3)
	 elseif ConstantA==TermAI2 then
	    optiOneDaughter(TermTree1 TermTree3)
	 else
	    FormTree = Sem.3
	    FormTree1 = {Optimize FormTree}
	 in
	    existsone(ConstantTree DomTree FormTree1)
	 end
      else
	 FormTree = Sem.3
	 FormTree1 = {Optimize FormTree}
      in
	 existsone(ConstantTree DomTree FormTree1)
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% constant
   [] constant(Token) then
      constant(Token)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% integer
   [] integer(Token) then
      integer(Token)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% set
   [] set(TermTreeList) then
      set(TermTreeList)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% tuple
   [] tuple(TermTreeList) then
      tuple(TermTreeList)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% type annotation
   [] anno(ExprTree TypeTree) then
      anno(ExprTree TypeTree)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% lexical attributes access
   [] entry(TermTree1 TermTree2 ConstantTree) then
      entry(TermTree1 TermTree2 ConstantTree)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% non-lexical attributes access
   [] attrs(TermTree1 TermTree2 ConstantTree) then
      attrs(TermTree1 TermTree2 ConstantTree)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% negation
   [] neg(FormTree) then
      FormTree1 = {Optimize FormTree}
   in
      neg(FormTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% conjunction
   [] conj(FormTree1 FormTree2) then
      FormTree11 = {Optimize FormTree1}
      FormTree21 = {Optimize FormTree2}
   in
      conj(FormTree11 FormTree21)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% disjunction
   [] disj(FormTree1 FormTree2) then
      FormTree11 = {Optimize FormTree1}
      FormTree21 = {Optimize FormTree2}
   in
      disj(FormTree11 FormTree21)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% implication
   [] impl(FormTree1 FormTree2) then
      FormTree11 = {Optimize FormTree1}
      FormTree21 = {Optimize FormTree2}
      Sem1 = impl(FormTree11 FormTree21)
   in
      if {IsOptimizableImpl FormTree1} then
	 FormOptiTree1 = {Tree2OptiTree FormTree1}
      in
	 optiImpl(FormOptiTree1
		  value(coord: Tree.coord
			file: Tree.file
			sem: Sem1))
      else
	 Sem1
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% equivalence
   [] equi(FormTree1 FormTree2) then
      FormTree11 = {Optimize FormTree1}
      FormTree21 = {Optimize FormTree2}
   in
      equi(FormTree11 FormTree21)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% existential quantification
   [] exists(ConstantTree DomTree FormTree) then
      FormTree1 = {Optimize FormTree}
   in
      exists(ConstantTree DomTree FormTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% one-existential quantification
   [] existsone(ConstantTree DomTree FormTree) then
      FormTree1 = {Optimize FormTree}
   in
      existsone(ConstantTree DomTree FormTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% universal quantification
   [] forall(ConstantTree DomTree FormTree) then
      FormTree1 = {Optimize FormTree}
   in
      forall(ConstantTree DomTree FormTree1)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% equality
   [] eq(ExprTree1 ExprTree2) then
      eq(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% element
   [] 'in'(ExprTree1 ExprTree2) then
      'in'(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% not element
   [] notin(ExprTree1 ExprTree2) then
      notin(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% subset
   [] subseteq(ExprTree1 ExprTree2) then
      subseteq(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% disjointness
   [] disjoint(ExprTree1 ExprTree2) then
      disjoint(ExprTree1 ExprTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% intersection
   [] intersect(ExprTree1 ExprTree2 ExprTree3) then
      intersect(ExprTree1 ExprTree2 ExprTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% union
   [] union(ExprTree1 ExprTree2 ExprTree3) then
      union(ExprTree1 ExprTree2 ExprTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% minus
   [] minus(ExprTree1 ExprTree2 ExprTree3) then
      minus(ExprTree1 ExprTree2 ExprTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled edge
   [] ledge(TermTree1 TermTree2 TermTree3 TermTree4) then
      ledge(TermTree1 TermTree2 TermTree3 TermTree4)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% edge
   [] edge(TermTree1 TermTree2 TermTree3) then
      edge(TermTree1 TermTree2 TermTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% labeled strict dominance
   [] ldom(TermTree1 TermTree2 TermTree3 TermTree4) then
      ldom(TermTree1 TermTree2 TermTree3 TermTree4)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% strict dominance
   [] dom(TermTree1 TermTree2 TermTree3) then
      dom(TermTree1 TermTree2 TermTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% dominance
   [] domeq(TermTree1 TermTree2 TermTree3) then
      domeq(TermTree1 TermTree2 TermTree3)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% precedence
   [] prec(TermTree1 TermTree2) then
      prec(TermTree1 TermTree2)
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% word
   [] word(TermTree1 TermTree2) then
      word(TermTree1 TermTree2)
   else
      Sem
   end
in
   value(coord: Tree.coord
	 file: Tree.file
	 sem: Sem1)
end
%%
fun {Indent I}
   S =
   for I1 in 1..I collect:Collect do
      {Collect & }
   end
   A = {S2A S}
in
   A
end
%%
fun {Eval Tree}
   fun {Eval1 Tree V M T ATreeRec IndentI}
      Coord1 = Tree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = Tree.file
      File = if File1==unit then noFile else File1 end
      Sem = Tree.sem
%      {Inspect Tree#V#M#T}
   in
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% S
      of s(DefTypeTreeList DefPrincipleTreeList) then
	 ConstantATypeTreeTups =
	 {Map DefTypeTreeList.sem
	  fun {$ DefTypeTree}
	     {Eval1 DefTypeTree V M T ATreeRec IndentI}
	  end}
	 ConstantATypeTreeRec =
	 {ListToRecord o ConstantATypeTreeTups}
	 %%
	 DefPrinciples = {Map DefPrincipleTreeList.sem
			  fun {$ DefPrincipleTree}
			     {Eval1 DefPrincipleTree V M T ConstantATypeTreeRec IndentI}
			  end}
      in
	 DefPrinciples
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% DefType
      [] deftype(ConstantTree TypeTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
      in
	 ConstantA#TypeTree
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% principle definition
      [] defprinciple(ConstantTree DimsTree ConstraintsTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
	 ConstantAConstantVRec = {Eval1 DimsTree V M T ATreeRec IndentI}
	 V1 = o(a:ConstantAConstantVRec
		i:o
		n:o)
	 ConstraintsV = {Eval1 ConstraintsTree V1 M T ATreeRec IndentI}
      in
	 ConstantA#ConstantAConstantVRec#ConstraintsV
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dimensions
      [] dims(ConstantTreeList) then
	 ConstantAConstantVTups =
	 {Map ConstantTreeList.sem
	  fun {$ ConstantTree}
	     ConstantA = {ConstantTree2A ConstantTree}
	  in
	     ConstantA#('{Principle.dVA2DIDA \''#ConstantA#'\'}')
	  end}
	 ConstantAConstantVRec = {ListToRecord o ConstantAConstantVTups}
      in
	 ConstantAConstantVRec
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constraints
      [] constraints(FormTreeList) then
	 FormVs = {Map FormTreeList.sem
		   fun {$ FormTree}
		      {Eval1 FormTree V M T ATreeRec IndentI}
		   end}
	 FormV =
	 if FormVs==nil then
	    ''
	 else
	    FormV1|FormVs1 = FormVs
	 in
	    FormV = {FoldL FormVs1
		     fun {$ AccV FormV2} AccV#'\n'#FormV2#{Indent IndentI}#'= 1\n' end FormV1#{Indent IndentI}#'= 1\n'}
	 end
      in
	 FormV
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% constant
      [] constant(Token) then
	 ConstantV = Token.sem
	 ConstantA = {V2A ConstantV}
	 ConstantS = {A2S ConstantA}
      in
	 if {Char.isAlpha ConstantS.1} andthen
	    {Char.isUpper ConstantS.1} andthen
	    {All ConstantS
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end} then
	    if M==i then
	       if T==node then
		  V.n.ConstantA#'.'#'index'
	       else
		  V.i.ConstantA
	       end
	    elseif M==a then
	       V.a.ConstantA
	    else
	       V.n.ConstantA
	    end
	 else
	    if M==i then
	       TV = {T2V T}
	    in
	       '{{PW.t2Lat '#TV#' NodeRecs G Principle}.aI2I \''#ConstantA#'\'}'
	    else
	       '\''#ConstantA#'\''
	    end
	 end
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% integer
      [] integer(Token) then
	 IntegerI = Token.sem
      in
	 if M==i then
	    IntegerI
	 else
	    '{Nth NodesRecs '#IntegerI#'}'
	 end
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% set
      [] set(TermTreeList) then
	 set(Dom) = T
	 TermVs = {Map TermTreeList.sem
		   fun {$ TermTree}
		      {Eval1 TermTree V i Dom ATreeRec IndentI}
		   end}
	 TermV = {Vs2ListV TermVs}
      in
	 '{FS.value.make '#TermV#'}'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tuple
      [] tuple(TermTreeList) then
	 tuple(Doms) = T
	 TermVs = {ListMapInd TermTreeList.sem
		   fun {$ I TermTree}
		      Dom = {Nth Doms I}
		   in
		      {Eval1 TermTree V a Dom ATreeRec IndentI}
		   end}
	 TermV = {Vs2ListV TermVs}
	 TV = {T2V T}
      in
	 '{{PW.t2Lat '#TV#' NodeRecs G Principle}.aIs2I '#TermV#'}'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type annotation
      [] anno(ExprTree TypeTree) then
	 T1 = {Tree2T TypeTree ATreeRec}
      in
	 {Eval1 ExprTree V M T1 ATreeRec IndentI}
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% lexical attributes access
      [] entry(TermTree1 TermTree2 ConstantTree) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI}
	 ConstantV = {Eval1 ConstantTree V a 'attr' ATreeRec IndentI}
      in
	 TermV1#'.'#TermV2#'.'#entry#'.'#ConstantV
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% non-lexical attributes access
      [] attrs(TermTree1 TermTree2 ConstantTree) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI}
	 ConstantV = {Eval1 ConstantTree V a 'attr' ATreeRec IndentI}
      in
	 TermV1#'.'#TermV2#'.'#attrs#'.'#ConstantV
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% negation
      [] neg(FormTree) then
	 FormV = {Eval1 FormTree V M T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.nega \n'#FormV#{Indent IndentI}#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% conjunction
      [] conj(FormTree1 FormTree2) then
	 FormV1 = {Eval1 FormTree1 V M T ATreeRec IndentI+1}
	 FormV2 = {Eval1 FormTree2 V M T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.conj \n'#FormV1#FormV2#{Indent IndentI}#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% disjunction
      [] disj(FormTree1 FormTree2) then
	 FormV1 = {Eval1 FormTree1 V M T ATreeRec IndentI+1}
	 FormV2 = {Eval1 FormTree2 V M T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.disj \n'#FormV1#FormV2#{Indent IndentI}#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% implication
      [] impl(FormTree1 FormTree2) then
	 FormV1 = {Eval1 FormTree1 V M T ATreeRec IndentI+1}
	 FormV2 = {Eval1 FormTree2 V M T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.impl \n'#FormV1#FormV2#{Indent IndentI}#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% equivalence
      [] equi(FormTree1 FormTree2) then
	 FormV1 = {Eval1 FormTree1 V M T ATreeRec IndentI+1}
	 FormV2 = {Eval1 FormTree2 V M T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.equi \n'#FormV1#FormV2#{Indent IndentI}#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% existential quantification
      [] exists(ConstantTree DomTree FormTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
	 Dom = {Tree2T DomTree ATreeRec}
      in
	 if Dom==node then
	    NodeRecV = ConstantA#'NodeRec'
	    V1 = o(a: V.a
		   i: V.i
		   n: {AdjoinList V.n [ConstantA#NodeRecV]})
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.existsNodes NodeRecs\n'#{Indent IndentI}#' fun {$ '#NodeRecV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 else
	    AV = ConstantA#'A'
	    IV = ConstantA#'I'
	    %%
	    DomV = {T2V Dom}
	    V1 = o(a: {AdjoinList V.a [ConstantA#AV]}
		   i: {AdjoinList V.i [ConstantA#IV]}
		   n: V.n)
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.existsDom {PW.t2Lat '#DomV#' NodeRecs G Principle}\n'#{Indent IndentI}#' fun {$ '#AV#' '#IV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 end
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% one-existential quantification
      [] existsone(ConstantTree DomTree FormTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
	 Dom = {Tree2T DomTree ATreeRec}
      in
	 if Dom==node then
	    NodeRecV = ConstantA#'NodeRec'
	    V1 = o(a: V.a
		   i: V.i
		   n: {AdjoinList V.n [ConstantA#NodeRecV]})
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.existsOneNodes NodeRecs\n'#{Indent IndentI}#' fun {$ '#NodeRecV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 else
	    AV = ConstantA#'A'
	    IV = ConstantA#'I'
	    %%
	    DomV = {T2V Dom}
	    V1 = o(a: {AdjoinList V.a [ConstantA#AV]}
		   i: {AdjoinList V.i [ConstantA#IV]}
		   n: V.n)
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.existsOneDom {PW.t2Lat '#DomV#' NodeRecs G Principle}\n'#{Indent IndentI}#' fun {$ '#AV#' '#IV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 end
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% universal quantification
      [] forall(ConstantTree DomTree FormTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
	 Dom = {Tree2T DomTree ATreeRec}
      in
	 if Dom==node then
	    NodeRecV = ConstantA#'NodeRec'
	    V1 = o(a: V.a
		   i: V.i
		   n: {AdjoinList V.n [ConstantA#NodeRecV]})
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.forallNodes NodeRecs\n'#{Indent IndentI}#' fun {$ '#NodeRecV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 else
	    AV = ConstantA#'A'
	    IV = ConstantA#'I'
	    %%
	    DomV = {T2V Dom}
	    V1 = o(a: {AdjoinList V.a [ConstantA#AV]}
		   i: {AdjoinList V.i [ConstantA#IV]}
		   n: V.n)
	    FormV = {Eval1 FormTree V1 M T ATreeRec IndentI+4}
	 in
	    {Indent IndentI}#'{PW.forallDom {PW.t2Lat '#DomV#' NodeRecs G Principle}\n'#{Indent IndentI}#' fun {$ '#AV#' '#IV#'}\n'#FormV#{Indent IndentI}#' end}\n'
	 end
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% equality
      [] eq(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.eq\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% element
      [] 'in'(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.\'in\'\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% not element
      [] notin(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.notin\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% subset
      [] subseteq(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.subseteq\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% disjointness
      [] disjoint(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.disjoint\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% intersection
      [] intersect(ExprTree1 ExprTree2 ExprTree3) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
	 ExprV3 = {Eval1 ExprTree3 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.intersect\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#' '#ExprV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% union
      [] union(ExprTree1 ExprTree2 ExprTree3) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
	 ExprV3 = {Eval1 ExprTree3 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.union\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#' '#ExprV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% minus
      [] minus(ExprTree1 ExprTree2 ExprTree3) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
	 ExprV3 = {Eval1 ExprTree3 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.minus\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#' '#ExprV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% labeled edge
      [] ledge(TermTree1 TermTree2 TermTree3 TermTree4) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a label(TermV4) ATreeRec IndentI+1}
	 TermV4 = {Eval1 TermTree4 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.ledge\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% edge
      [] edge(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.edge\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% labeled strict dominance
      [] ldom(TermTree1 TermTree2 TermTree3 TermTree4) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a label(TermV4) ATreeRec IndentI+1}
	 TermV4 = {Eval1 TermTree4 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.ldom\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% strict dominance
      [] dom(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.dom\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dominance
      [] domeq(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.domeq\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% precedence
      [] prec(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.prec\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% word
      [] word(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a word ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.word\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDisjointSubtreesL
      [] optiDisjointSubtreesL(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.disjointSubtreesL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiEqPrecDaughtersL
      [] optiEqPrecDaughtersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.eqPrecDaughtersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDaughtersLPrecEq
      [] optiDaughtersLPrecEq(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.daughtersLPrecEq\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDaughtersLPrecDaughtersL
      [] optiDaughtersLPrecDaughtersL(TermTree1 TermTree2 TermTree3 TermTree4) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV4) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a label(TermV4) ATreeRec IndentI+1}
	 TermV4 = {Eval1 TermTree4 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.daughtersLPrecDaughtersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiProjective
      [] optiProjective(TermTree) then
	 TermV = {Eval1 TermTree V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.projective\n'#{Indent IndentI+1}#'NodeRecs '#TermV#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroOrOneMothers
      [] optiZeroOrOneMothers(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroOrOneMothers\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroOrOneMothersL
      [] optiZeroOrOneMothersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroOrOneMothersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroOrOneDaughters
      [] optiZeroOrOneDaughters(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroOrOneDaughters\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroOrOneDaughtersL
      [] optiZeroOrOneDaughtersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroOrOneDaughtersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroMothers
      [] optiZeroMothers(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroMothers\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroMothersL
      [] optiZeroMothersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroMothersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroDaughters
      [] optiZeroDaughters(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroDaughters\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiZeroDaughtersL
      [] optiZeroDaughtersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.zeroDaughtersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneOrMoreMothers
      [] optiOneOrMoreMothers(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneOrMoreMothers\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneOrMoreMotherL
      [] optiOneOrMoreMothersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneOrMoreMothersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneOrMoreDaughters
      [] optiOneOrMoreDaughters(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneOrMoreDaughters\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneOrMoreDaughtersL
      [] optiOneOrMoreDaughtersL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneOrMoreDaughtersL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneMother
      [] optiOneMother(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneMother\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneMotherL
      [] optiOneMotherL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneMotherL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneDaughter
      [] optiOneDaughter(TermTree1 TermTree2) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneDaughter\n'#{Indent IndentI+1}#TermV1#' '#TermV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiOneDaughterL
      [] optiOneDaughterL(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V a label(TermV3) ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.oneDaughterL\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiImpl
      [] optiImpl(FormOptiTree FormTree) then
	 FormOptiV = {Eval1 FormOptiTree V M T ATreeRec IndentI+3}
	 FormV = {Eval1 FormTree V M T ATreeRec IndentI+3}
      in
	 {Indent IndentI}#'if\n'#FormOptiV#{Indent IndentI}#'then\n'#FormV#{Indent IndentI}#'else\n'#{Indent IndentI}#'   1\n'#{Indent IndentI}#'end\n'
% 	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	 %% optiNeg
%       [] optiNeg(FormOptiTree) then
% 	 FormOptiV = {Eval1 FormOptiTree V M T ATreeRec IndentI+1}
%       in
% 	 {Indent IndentI}#'{Not '#FormOptiV#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiConj
      [] optiConj(FormOptiTree1 FormOptiTree2) then
	 FormOptiV1 = {Eval1 FormOptiTree1 V M T ATreeRec IndentI}
	 FormOptiV2 = {Eval1 FormOptiTree2 V M T ATreeRec IndentI}
      in
	 FormOptiV1#{Indent IndentI}#'andthen\n'#FormOptiV2
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDisj
      [] optiDisj(FormOptiTree1 FormOptiTree2) then
	 FormOptiV1 = {Eval1 FormOptiTree1 V M T ATreeRec IndentI}
	 FormOptiV2 = {Eval1 FormOptiTree2 V M T ATreeRec IndentI}
      in
	 FormOptiV1#{Indent IndentI}#'orelse\n'#FormOptiV2
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiIn
      [] optiIn(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiIn\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiNotin
      [] optiNotin(ExprTree1 ExprTree2) then
	 ExprV1 = {Eval1 ExprTree1 V i T ATreeRec IndentI+1}
	 ExprV2 = {Eval1 ExprTree2 V i T ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiNotin\n'#{Indent IndentI+1}#ExprV1#' '#ExprV2#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiLedge
      [] optiLedge(TermTree1 TermTree2 TermTree3 TermTree4) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a label(TermV4) ATreeRec IndentI+1}
	 TermV4 = {Eval1 TermTree4 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiLedge\n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiEdge
      [] optiEdge(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiEdge \n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiLdom
      [] optiLdom(TermTree1 TermTree2 TermTree3 TermTree4) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a label(TermV4) ATreeRec IndentI+1}
	 TermV4 = {Eval1 TermTree4 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiLdom \n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDom
      [] optiDom(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiDom \n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% optiDomeq
      [] optiDomeq(TermTree1 TermTree2 TermTree3) then
	 TermV1 = {Eval1 TermTree1 V n node ATreeRec IndentI+1}
	 TermV2 = {Eval1 TermTree2 V n node ATreeRec IndentI+1}
	 TermV3 = {Eval1 TermTree3 V a dim ATreeRec IndentI+1}
      in
	 {Indent IndentI}#'{PW.optiDomeq \n'#{Indent IndentI+1}#TermV1#' '#TermV2#' '#TermV3#'}\n'
      end
   end
in
   {Eval1 Tree o a noType o 6}
end
%%
HeaderV =
'%% Copyright 2001-2011\n'#
'%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and\n'#
'%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
\n'#
'%%    Jochen Setz <info@jochensetz.de> (Saarland University)\n'#
'%%\n'#
'functor\n'#
'import\n'#
'%   System(show)\n'#
'\n'#
'   PW at \'PW.ozf\'\n'#
'export\n'#
'   Constraint\n'#
'define\n'#
'   proc {Constraint NodeRecs G Principle FD FS Select}\n'
FooterV = '   end\n'#
'end\n'
%%
Tokenized = {Tokenizer.fromURL 'http://www.ps.uni-sb.de/~rade/links.html'}
% Tokenized = {Tokenizer.fromString "defprinciple \"principle.testPW\" {dims {D} constraints {
% existsone V1::node: edge(V1 1 bla D)
% existsone V1::node: edge(V1 1 D)
% existsone V1::node: edge(1 V1 bla D)
% existsone V1::node: edge(1 V1 D)
% ~exists V1::node: edge(V1 1 bla D)
% ~exists V1::node: edge(V1 1 D)
% ~exists V1::node: edge(1 V1 bla D)
% ~exists V1::node: edge(1 V1 D)
% (existsone V1::node: edge(V1 1 bla D)) | (~exists V1::node: edge(V1 1 bla D))
% (existsone V1::node: edge(V1 1 D)) | (~exists V1::node: edge(V1 1 D))
% (existsone V1::node: edge(1 V1 bla D)) | (~exists V1::node: edge(1 V1 bla D))
% (existsone V1::node: edge(1 V1 D)) | (~exists V1::node: edge(1 V1 D))
% exists V1::node: edge(V1 1 bla D)
% exists V1::node: edge(V1 1 D)
% exists V1::node: edge(1 V1 bla D)
% exists V1::node: edge(1 V1 D)}}
% "}
%{Inspect Tokenized}
Tree = {Parser Tokenized}
%{Inspect Tree}
{Property.put 'print.depth' 10000}
{Property.put 'print.width' 10000}
%{Show Tree}
Tree1 = {Optimize Tree}
%{Inspect Tree1}
_#DefPrinciples = {Eval Tree1}
for ConstantA#ConstantAConstantVRec#ConstraintsV in DefPrinciples do
   NameA = ConstantA
   NameSs = {String.tokens {A2S NameA} &.}
   NameCh|NameS = {Nth NameSs 2}
   NameS1 = {Char.toUpper NameCh}|NameS
   NameA1 = {S2A NameS1}
   %%
   PrincipleV = HeaderV#ConstraintsV#FooterV
   %%
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   DVAs = {Arity ConstantAConstantVRec}
   PrincipleDefV =
   '%% Copyright 2001-2011\n'#
   '%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and\n'#
   '%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
\n'#
   '%%    Jochen Setz <info@jochensetz.de> (Saarland University)\n'#
   '%%\n'#
   'functor\n'#
   'export\n'#
   '   Principle\n'#
   'define\n'#
   '   Principle =\n'#
   '   elem(tag: principledef\n'#
   '	id: elem(tag: constant\n'#
   '		 data: \''#NameA#'\')\n'#
   '    dimensions: '#{Vs2ListV
		       {Map DVAs
			fun {$ DVA}
			   'elem(tag: variable\n'#
			   '     data: \''#DVA#'\')\n'
			end}}#'\n'#
   '    constraints: [elem(tag: constant\n'#
   '			   data: \''#NameA1#'\')#\n'#
   '                  elem(tag: integer\n'#
   '                       data: 130)])\n'#
   'end\n'
in
   {PutV PrincipleV '../Solver/Principles/Lib/'#NameA1#'.oz'}
   {Inspect 'Saved principle ../Solver/Principles/Lib/'#NameA1#'.oz'}
   {PutV PrincipleDefV '../Solver/Principles/'#NameA1#'.oz'}
   {Inspect 'Saved principle definition ../Solver/Principles/'#NameA1#'.oz'}
end
