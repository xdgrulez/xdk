%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show:Show)
%   Inspector(inspect:Inspect)
   
   Helpers(
      canBeDomT:CanBeDomT
      canBeSetT:CanBeSetT
      canBeTupleT:CanBeTupleT
      constantTree2A:ConstantTree2A
      tokenIsVar:TokenIsVar
      multiply:Multiply
      noDoubles:NoDoubles
      t2Tree:T2Tree
      t2V:T2V
      termTree2AI:TermTree2AI
      tree2T:Tree2T
      ) at 'Helpers.ozf'
export
   Type
prepare
   ListAllInd = List.allInd
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
   RecordAdjoinAt = Record.adjoinAt
   RecordAdjoinList = Record.adjoinList
   RecordForAllInd = Record.forAllInd
   V2A = VirtualString.toAtom
define
   %% CollectDefTypes: Tree -> ConstantATypeTreeRec
   %% Creates mapping ConstantATypeTreeRec (from constants to type
   %% trees) from the "deftype" definitions.
   fun {CollectDefTypes Tree}
      Coord1 = Tree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = Tree.file
      File = if File1==unit then noFile else File1 end
      Sem = Tree.sem
   in
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% S
      of s(DefTypeTreeList _) then
	 ConstantATypeTreeTups = {Map DefTypeTreeList.sem CollectDefTypes}
	 ConstantATypeTreeRec = {ListToRecord o ConstantATypeTreeTups}
      in
	 ConstantATypeTreeRec
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% DefType
      [] deftype(ConstantTree TypeTree) then
	 ConstantA = {ConstantTree2A ConstantTree}
      in
	 ConstantA#TypeTree
      end
   end
   %%
   fun {Annotate Tree TypeTree}
      Coord1 = Tree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = Tree.file
      File = if File1==unit then noFile else File1 end
      Sem = Tree.sem
      LabelA = {Label Sem}
      Sem1 =
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% type
      of type(tree:Tree1 anno:T ...) then
	 if T==undef then
	    raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Annotate' msg:'Type inference could not find a type here (please annotate yourself).' info:o(Sem) coord:Coord file:File) end
	 end
	 %%
	 TypeTree1 = {T2Tree T Coord File}
      in
	 {Annotate Tree1 TypeTree1}.sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Form (1)
      [] neg(FormTree) then
	 FormTree1 = {Annotate FormTree TypeTree}
      in
	 neg(FormTree1)
	 %%
      [] prec(TermTree1 TermTree2) then
	 TermTree11 = {Annotate TermTree1 TypeTree}.sem.1
	 TermTree21 = {Annotate TermTree2 TypeTree}.sem.1
      in
	 prec(TermTree11 TermTree21)
	 %%
      [] word(TermTree1 TermTree2) then
	 TermTree11 = {Annotate TermTree1 TypeTree}.sem.1
	 TermTree21 = {Annotate TermTree2 TypeTree}.sem.1
      in
	 word(TermTree11 TermTree21)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Expr (1)
      [] set(TermTreeList) then
	 TermTrees = TermTreeList.sem
	 TermTrees1 = {Map TermTrees
		       fun {$ TermTree} {Annotate TermTree undef} end}
	 TermTreeList1 = value(coord:Coord
			       file:File
			       sem:TermTrees1)
      in
	 anno(value(coord:Coord
		    file:File
		    sem:set(TermTreeList1))
	      TypeTree)
      [] setgen(SetgenTree) then
	 anno(value(coord:Coord
		    file:File
		    sem:setgen(SetgenTree))
	      TypeTree)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Tuple
      [] tuple(TermTreeList) then
	 TermTrees = TermTreeList.sem
	 TermTrees1 = {Map TermTrees
		       fun {$ TermTree} {Annotate TermTree undef} end}
	 TermTreeList1 = value(coord:Coord
			       file:File
			       sem:TermTrees1)
      in
	 anno(value(coord:Coord
		    file:File
		    sem:tuple(TermTreeList1))
	      TypeTree)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Term
      [] constant(Token) then
	 anno(value(coord:Coord
		    file:File
		    sem:constant(Token))
	      TypeTree)
      [] integer(Token) then
	 anno(value(coord:Coord
		    file:File
		    sem:integer(Token))
	      TypeTree)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Form (2)
      elseif {Member LabelA [conj disj impl equi]} then
	 FormTree11 = {Annotate Sem.1 undef}
	 FormTree21 = {Annotate Sem.2 undef}
      in
	 LabelA(FormTree11 FormTree21)
      elseif {Member LabelA [forall exists existsone]} then
	 ExprTree = {Annotate Sem.1 undef}.sem.1
	 TypeTree1 = {T2Tree Sem.1.sem.anno Sem.1.coord Sem.1.file}
	 FormTree = {Annotate Sem.2 undef}
      in
	 LabelA(ExprTree TypeTree1 FormTree)
      elseif {Member LabelA [eq neq]} then
	 ExprTree1 = {Annotate Sem.1 undef}
	 ExprTree2 = {Annotate Sem.2 undef}
      in
	 LabelA(ExprTree1 ExprTree2)
      elseif {Member LabelA ['in' notin]} then
	 ExprTree1 = {Annotate Sem.1 undef}
	 ExprTree2 = {Annotate Sem.2 undef}
      in
	 LabelA(ExprTree1 ExprTree2)
      elseif {Member LabelA [subseteq disjoint]} then
	 ExprTree1 = {Annotate Sem.1 undef}
	 ExprTree2 = {Annotate Sem.2 undef}
      in
	 LabelA(ExprTree1 ExprTree2)
      elseif {Member LabelA [intersect union minus]} then
	 ExprTree1 = {Annotate Sem.1 undef}
	 ExprTree2 = {Annotate Sem.2 undef}
	 ExprTree3 = {Annotate Sem.3 undef}
      in
	 LabelA(ExprTree1 ExprTree2 ExprTree3)
      elseif {Member LabelA [ledge ldom]} then
	 TermTree1 = {Annotate Sem.1 undef}.sem.1
	 TermTree2 = {Annotate Sem.2 undef}.sem.1
	 TermTree3 = {Annotate Sem.3 undef}.sem.1
	 TermTree4 = {Annotate Sem.4 undef}.sem.1
      in
	 LabelA(TermTree1 TermTree2 TermTree3 TermTree4)
      elseif {Member LabelA [edge dom domeq]} then
	 TermTree1 = {Annotate Sem.1 undef}.sem.1
	 TermTree2 = {Annotate Sem.2 undef}.sem.1
	 TermTree3 = {Annotate Sem.3 undef}.sem.1
      in
	 LabelA(TermTree1 TermTree2 TermTree3)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% Expr (2)
      elseif {Member LabelA [entry attrs]} then
	 TermTree = {Annotate Sem.1 undef}.sem.1
	 ConstantTree1 = {Annotate Sem.2 undef}.sem.1
	 ConstantTree2 = {Annotate Sem.3 undef}.sem.1
      in
	 anno(value(coord:Coord
		    file:File
		    sem:LabelA(TermTree ConstantTree1 ConstantTree2))
	      TypeTree)
      end
      %%
      Tree1 = value(coord:Coord
		    file:File
		    sem:Sem1)
   in
      Tree1
   end
   %%
   fun {Type Tree}
      fun {Type1 Tree Context T}
	 Coord1 = Tree.coord
	 Coord = if Coord1==unit then noCoord else Coord1 end
	 File1 = Tree.file
	 File = if File1==unit then noFile else File1 end
	 Sem = Tree.sem
	 LabelA = {Label Sem}
	 Sem1 =
	 case Sem
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% S
	 of s(DefTypeTreeList DefPrincipleTreeList) then
	    DefPrincipleTrees = DefPrincipleTreeList.sem
	    DefPrincipleTrees1 =
	    {Map DefPrincipleTrees
	     fun {$ DefPrincipleTree}
		{Type1 DefPrincipleTree Context T}
	     end}
	    DefPrincipleTreeList1 = value(coord:Coord
					  file:File
					  sem:DefPrincipleTrees1)
	 in
	    s(DefTypeTreeList DefPrincipleTreeList1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% DefPrinciple
	 [] defprinciple(ConstantTree DimsTree ConstraintsTree) then
	    dims(ConstantTreeList) = DimsTree.sem
	    ConstantATTups =
	    {Map ConstantTreeList.sem
	     fun {$ ConstantTree}
		ConstantA = {ConstantTree2A ConstantTree}
	     in
		ConstantA#dim
	     end}
	    Context1 = {RecordAdjoinList Context ConstantATTups}
	    %%
	    ConstraintsTree1 = {Type1 ConstraintsTree Context1 T}
	 in
	    defprinciple(ConstantTree DimsTree ConstraintsTree1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% letdim
	 [] letdim(ConstantTree1 ConstantTree2 ConstraintsTree) then
	    ConstraintsTree1 = {Type1 ConstraintsTree Context T}
	 in
	    letdim(ConstantTree1 ConstantTree2 ConstraintsTree1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Constraints
	 [] constraints(FormTreeList) then
	    FormTrees = FormTreeList.sem
	    FormTrees1 =
	    {Map FormTrees
	     fun {$ FormTree}
		FormTree1 = {Type1 FormTree Context logic}
		FormTree11 = {Type1 FormTree1 FormTree1.sem.context logic}
		FormTree111 = {Type1 FormTree11 FormTree11.sem.context logic}
		FormTree1111 = {Annotate FormTree111 undef}
	     in
		FormTree1111
	     end}
	    FormTreeList1 = value(coord:Coord
				  file:File
				  sem:FormTrees1)
	 in
	    constraints(FormTreeList1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type
	 [] type(tree:Tree1
		 anno:T1
		 context:_) then
	    T11 = {Unify T1 T Coord File}
	    Tree11 = {Type1 Tree1 Context T11}
	 in
	    Tree11.sem
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Form (1)
	 [] neg(FormTree) then
	    FormTree1 = {Type1 FormTree Context logic}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:neg(FormTree1))
		 anno:logic
		 context:FormTree1.sem.context)
	    %%
	 [] prec(TermTree1 TermTree2) then
	    TermTree11 = {Type1 TermTree1 Context node}
	    TermTree21 = {Type1 TermTree2 Context node}
	    %%
	    Context1 = {UnionContext
			TermTree11.sem.context TermTree21.sem.context
			Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:prec(TermTree11
				     TermTree21))
		 anno:logic
		 context:Context1)
	    %%
	 [] word(TermTree1 TermTree2) then
	    TermTree11 = {Type1 TermTree1 Context node}
	    TermTree21 = {Type1 TermTree2 Context word}
	    %%
	    Context1 = {UnionContext
			TermTree11.sem.context TermTree21.sem.context
		       Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:word(TermTree11
				     TermTree21))
		 anno:logic
		 context:Context1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Expr (1)
	 [] set(TermTreeList) then
	    if {Not {CanBeSetT T}} then
	       raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Type1' msg:'Set does not have a set type but type '#{T2V T} info:o(Sem T) coord:Coord file:File) end
	    end
	    %%
	    TermTrees = TermTreeList.sem
	    %%
	    TermTrees1 = {Map TermTrees
			  fun {$ TermTree}
			     {Type1 TermTree Context {Simplify tdom(T)}}
			  end}
	    %%
	    TermTreeList1 = value(coord:Coord
				  file:File
				  sem:TermTrees1)
	    %%
	    Ts = {Map TermTrees1
		  fun {$ TermTree} TermTree.sem.anno end}
	    T1 = {UnifyList Ts Coord File}
	    T11 = {Simplify tset(T1)}
	    %%
	    Contexts = {Map TermTrees1
			fun {$ TermTree} TermTree.sem.context end}
	    Context1 = {UnionContextList Contexts Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:set(TermTreeList1))
		 anno:T11
		 context:Context1)
	    %%
	 [] anno(ExprTree TypeTree) then
	    T1 = {Tree2T TypeTree ConstantATypeTreeRec}
	    ExprTree1 = {Type1 ExprTree Context T1}
	 in
	    ExprTree1.sem
	    %%
	 [] setgen(SetgenTree) then
	    type(tree:value(coord:Coord
			    file:File
			    sem:setgen(SetgenTree))
		 anno:T
		 context:Context)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Tuple
	 [] tuple(TermTreeList) then
	    if {Not {CanBeTupleT T}} then
	       raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Type1' msg:'Tuple does not have a tuple type but type '#{T2V T} info:o(Sem T) coord:Coord file:File) end
	    end
	    %%
	    TermTrees = TermTreeList.sem
	    %%
	    case T of ttuple(Doms) then
	       TermTreesI = {Length TermTrees}
	       DomsI = {Length Doms}
	    in
	       if {Not TermTreesI==DomsI} then
		  raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Type1' msg:'Tuple and tuple type have unequal width (tuple: '#TermTreesI#', tuple type: '#DomsI#').' info:o(Sem T) coord:Coord file:File) end
	       end
	    else
	       skip
	    end
	    %%
	    TermTrees1 = {ListMapInd TermTrees
			  fun {$ I TermTree}
			     {Type1 TermTree Context {Simplify tproj(T I)}}
			  end}
	    %%
	    TermTreeList1 = value(coord:Coord
				  file:File
				  sem:TermTrees1)
	    %%
	    Ts = {Map TermTrees1
		  fun {$ TermTree} TermTree.sem.anno end}
	    T1 = {Simplify ttuple(Ts)}
	    %%
	    Contexts = {Map TermTrees1
			fun {$ TermTree} TermTree.sem.context end}
	    Context1 = {UnionContextList Contexts Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:tuple(TermTreeList1))
		 anno:T1
		 context:Context1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Term
	 [] constant(Token) then
	    V = Token.sem
	    A = {V2A V}
	    %%
	    T1#Context1 =
	    if {TokenIsVar Token} then
	       if {HasFeature Context A} then
		  T2 = Context.A
		  T21 = {Unify T T2 Coord File}
		  Context2 = {RecordAdjoinAt Context A T21}
	       in
		  T21#Context2
	       else
		  Context2 = {RecordAdjoinAt Context A T}
	       in
		  T#Context2
	       end
	    else
	       T#Context
	    end
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:constant(Token))
		 anno:T1
		 context:Context1)
	 [] integer(Token) then
	    type(tree:value(coord:Coord
			    file:File
			    sem:integer(Token))
		 anno:node
		 context:Context)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Form (2)
	 elseif {Member LabelA [conj disj impl equi]} then
	    FormTree11 = {Type1 Sem.1 Context logic}
	    FormTree21 = {Type1 Sem.2 Context logic}
	    Context1 = {UnionContext
			FormTree11.sem.context FormTree21.sem.context
			Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(FormTree11 FormTree21))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA [exists existsone forall]} then
	    ExprTree = {Type1 Sem.1 Context undef}
	    FormTree = {Type1 Sem.2 ExprTree.sem.context logic}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(ExprTree FormTree))
		 anno:logic
		 context:FormTree.sem.context)
	    %%
	 elseif {Member LabelA [eq neq]} then
	    ExprTree1 = {Type1 Sem.1 Context undef}
	    ExprTree2 = {Type1 Sem.2 Context undef}
	    %%
	    T1 = {Unify ExprTree1.sem.anno ExprTree2.sem.anno Coord File}
	    Context1 = {UnionContext ExprTree1.sem.context ExprTree2.sem.context
			Coord File}
	    %%
	    ExprTree11 = value(coord:ExprTree1.coord
			       file:ExprTree1.file
			       sem:type(tree:ExprTree1.sem.tree
					anno:T1
					context:Context1))
	    ExprTree21 = value(coord:ExprTree2.coord
			       file:ExprTree2.file
			       sem:type(tree:ExprTree2.sem.tree
					anno:T1
					context:Context1))
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(ExprTree11 ExprTree21))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA ['in' notin]} then
	    ExprTree1 = {Type1 Sem.1 Context undef}
	    ExprTree2 = {Type1 Sem.2 Context undef}
	    %%
	    T1 = ExprTree1.sem.anno
	    T2 = ExprTree2.sem.anno
	    %%
	    if {Not ({CanBeDomT T1} orelse {CanBeTupleT T1})} then
	       raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Type1' msg:'Left argument of an equation does not have a domain or a tuple type but type '#{T2V T1} info:o(Sem ExprTree1 T1) coord:ExprTree1.coord file:ExprTree1.file) end
	    end
	    %%
	    if {Not {CanBeSetT T2}} then
	       raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Type1' msg:'Right argument of an equation does not have a set type but type '#{T2V T2} info:o(Sem ExprTree2 T2) coord:ExprTree2.coord file:ExprTree2.file) end
	    end
	    %%
	    T11 = {Unify T1 {Simplify tdom(T2)} Coord File}
	    T21 = {Unify T2 {Simplify tset(T1)} Coord File}
	    Context1 = {UnionContext ExprTree1.sem.context ExprTree2.sem.context
			Coord File}
	    %%
	    ExprTree11 = value(coord:ExprTree1.coord
				file:ExprTree1.file
				sem:type(tree:ExprTree1.sem.tree
					 anno:T11
					 context:Context1))
	    ExprTree21 = value(coord:ExprTree2.coord
				file:ExprTree2.file
				sem:type(tree:ExprTree2.sem.tree
					 anno:T21
					 context:Context1))
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(ExprTree11 ExprTree21))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA [subseteq disjoint]} then
	    ExprTree1 = {Type1 Sem.1 Context undef}
	    ExprTree2 = {Type1 Sem.2 Context undef}
	    %%
	    T1 = {Unify ExprTree1.sem.anno ExprTree2.sem.anno Coord File}
	    Context1 = {UnionContext ExprTree1.sem.context ExprTree2.sem.context
			Coord File}
	    %%
	    ExprTree11 = value(coord:ExprTree1.coord
			       file:ExprTree1.file
			       sem:type(tree:ExprTree1.sem.tree
					anno:T1
					context:Context1))
	    ExprTree21 = value(coord:ExprTree2.coord
			       file:ExprTree2.file
			       sem:type(tree:ExprTree2.sem.tree
					anno:T1
					context:Context1))
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(ExprTree11 ExprTree21))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA [intersect union minus]} then
	    ExprTree1 = {Type1 Sem.1 Context undef}
	    ExprTree2 = {Type1 Sem.2 Context undef}
	    ExprTree3 = {Type1 Sem.3 Context undef}
	    %%
	    T1 =
	    {UnifyList
	     [ExprTree1.sem.anno ExprTree2.sem.anno ExprTree3.sem.anno] Coord File}
	    Context1 =
	    {UnionContextList
	     [ExprTree1.sem.context ExprTree2.sem.context ExprTree3.sem.context]
	     Coord File}
	    %%
	    ExprTree11 = value(coord:ExprTree1.coord
			       file:ExprTree1.file
			       sem:type(tree:ExprTree1.sem.tree
					anno:T1
					context:Context1))
	    ExprTree21 = value(coord:ExprTree2.coord
			       file:ExprTree2.file
			       sem:type(tree:ExprTree2.sem.tree
					anno:T1
					context:Context1))
	    ExprTree31 = value(coord:ExprTree3.coord
			       file:ExprTree3.file
			       sem:type(tree:ExprTree3.sem.tree
					anno:T1
					context:Context1))
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(ExprTree11 ExprTree21 ExprTree31))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA [ledge ldom]} then
	    TermTree1 = {Type1 Sem.1 Context node}
	    TermTree2 = {Type1 Sem.2 Context node}
	    TermTree4 = {Type1 Sem.4 Context dim}
	    AI = {TermTree2AI TermTree4.sem.tree}
	    TermTree3 = {Type1 Sem.3 Context label(AI)}
	    %%
	    Context1 =
	    {UnionContextList
	     [TermTree1.sem.context TermTree2.sem.context
	      TermTree3.sem.context TermTree4.sem.context]
	     Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(TermTree1
				       TermTree2
				       TermTree3
				       TermTree4))
		 anno:logic
		 context:Context1)
	    %%
	 elseif {Member LabelA [edge dom domeq]} then
	    TermTree1 = {Type1 Sem.1 Context node}
	    TermTree2 = {Type1 Sem.2 Context node}
	    TermTree3 = {Type1 Sem.3 Context dim}
	    %%
	    Context1 =
	    {UnionContextList
	     [TermTree1.sem.context TermTree2.sem.context
	      TermTree3.sem.context]
	     Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(TermTree1
				       TermTree2
				       TermTree3))
		 anno:logic
		 context:Context1)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Expr (2)
	 elseif {Member LabelA [entry attrs]} then
	    TermTree = {Type1 Sem.1 Context node}
	    ConstantTree1 = {Type1 Sem.2 Context dim}
	    ConstantA1 = {ConstantTree2A ConstantTree1.sem.tree}
	    ConstantTree2 = {Type1 Sem.3 Context 'attr'}
	    ConstantA2 = {ConstantTree2A ConstantTree2.sem.tree}
	    %%
	    Context1 =
	    {UnionContextList
	     [TermTree.sem.context
	      ConstantTree1.sem.context ConstantTree2.sem.context]
	     Coord File}
	 in
	    type(tree:value(coord:Coord
			    file:File
			    sem:LabelA(TermTree
				       ConstantTree1
				       ConstantTree2))
		 anno:LabelA(ConstantA1 ConstantA2)
		 context:Context1)
	 end
      in
	 value(coord:Coord
	       file:File
	       sem:Sem1)
      end
      %%
      ConstantATypeTreeRec = {CollectDefTypes Tree}
      Tree1 = {Type1 Tree o _}
   in
      Tree1
   end
   fun {UnionContext Context1 Context2 Coord File}
      ContextDict = {NewDictionary}
      {RecordForAllInd Context1
       proc {$ A T}
	  ContextDict.A := T
       end}
      {RecordForAllInd Context2
       proc {$ A T}
	  T1 =
	  if {HasFeature ContextDict A} then
	     {Unify T ContextDict.A Coord File}
	  else
	     T
	  end
       in
	  ContextDict.A := T1
       end}
      Context = {Dictionary.toRecord o ContextDict}
   in
      Context
   end
   fun {UnionContextList Contexts Coord File}
      {FoldL Contexts
       fun {$ AccContext Context}
	  {UnionContext AccContext Context Coord File}
       end o}
   end
   fun {Simplify T}
      case T
      of tdom(tset(T1)) then T1
      [] tdom(undef) then undef
      [] tdom(eq(Ts)) then eq({Map Ts fun {$ T} tdom(T) end})
      [] tproj(ttuple(T1|Ts) I) then {Nth T1|Ts I}
      [] tproj(undef _) then undef
      [] tproj(eq(Ts) I) then eq({Map Ts fun {$ T} tproj(T I) end})
      [] tset(undef) then undef
      [] tset(eq(Ts)) then eq({Map Ts fun {$ T} tset(T) end})
      [] tset(tdom(T)) then T
      [] ttuple(tproj(T1 1)|Ts) then
	 if {ListAllInd Ts fun {$ I T} T==tproj(T1 I+1) end} then
	    T1
	 else
	    T
	 end
      [] ttuple(Ts) then
	 if {All Ts fun {$ T} T==undef end} then
	    undef
	 else 
	    Tss = {Map Ts
		   fun {$ T}
		      case T of eq(Ts) then Ts else [T] end
		   end}
	    Tss1 = {Multiply Tss}
	    Ts1 = {Map Tss1
		   fun {$ Ts}
		      if {Length Ts}==1 then Ts.1
		      else ttuple(Ts)
		      end
		   end}
	 in
	    if {Length Ts1}==1 then Ts1.1 else eq(Ts1) end
	 end
      [] eq(Ts) then
	 Ts1 =
	 {FoldL Ts
	  fun {$ AccTs T}
	     Ts2 = case T of eq(Ts1) then Ts1 else [T] end
	     Ts3 = {Filter Ts2 fun {$ T} {Not {Member T AccTs}} end}
	  in
	     {Append AccTs Ts3}
	  end nil}
      in
	 eq(Ts1)
      else T
      end
   end
   fun {Unify T1 T2 Coord File}
      case T1#T2
      of undef#T then
	 T
      [] T#undef then
	 T
      [] node#node then
	 node
      [] node#_ then
	 raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Unify' msg:'Error unifying types '#{T2V T1}#' and '#{T2V T2}#' (node type expected?)' info:o(T1 T2) coord:Coord file:File) end
      [] _#node then
	 raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Unify' msg:'Error unifying types '#{T2V T1}#' and '#{T2V T2}#' (non-node type expected?)' info:o(T1 T2) coord:Coord file:File) end
      [] dom(As1)#dom(As2) then
	 if {Not As1==As2} then
	    raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Unify' msg:'Error unifying domain types '#{T2V T1}#' and '#{T2V T2} info:o(T1 T2) coord:Coord file:File) end
	 end
	 dom(As1)
      [] tset(T11)#tset(T21) then
	 tset({Unify T11 T21 Coord File})
      [] ttuple(Ts1)#ttuple(Ts2) then
	 if {Not {Length Ts1}=={Length Ts2}} then
	    raise error1('functor':'PrincipleWriter/Typer.ozf' 'proc':'Unify' msg:'Error unifying tuples '#{T2V T1}#' ('#{Length Ts1}#' projections ) and '#{T2V T2}#' ('#{Length Ts2}#' projections).' info:o(T1 T2) coord:Coord file:File) end
	 end
	 Ts =
	 for T11 in Ts1 T21 in Ts2 collect:Collect do
	    {Collect {Unify T11 T21 Coord File}}
	 end
      in
	 ttuple(Ts)
      [] tdom(T11)#tdom(T21) then
	 tdom({Unify T11 T21 Coord File})
      [] tproj(T11 I)#tproj(T21 I) then
	 tproj({Unify T11 T21 Coord File} I)
      else
	 Ts1 = case T1 of eq(Ts) then Ts else [T1] end
	 Ts2 = case T2 of eq(Ts) then Ts else [T2] end
	 Ts3 = {Append Ts1 Ts2}
	 Ts4 = {Map Ts3 Simplify}
	 Ts5 = {NoDoubles Ts4}
	 Ts6 = {Sort Ts5
		fun {$ T1 T2} {Label T1}<{Label T2} end}
      in
	 if {Length Ts6}==1 then Ts6.1 else eq(Ts6) end
      end
   end
   fun {UnifyList Ts Coord File}
      {FoldL Ts fun {$ AccT T} {Unify AccT T Coord File} end undef}
   end
end
