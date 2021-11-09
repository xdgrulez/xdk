functor
import
   System(show)
   Inspector(inspect)
   
   Helpers(termTree2AI constantTree2A t2V tree2T vs2ListV) at 'Helpers.ozf'
export
   Type
prepare
   ListToRecord = List.toRecord
   A2S = Atom.toString
   V2A = VirtualString.toAtom
   V2S = VirtualString.toString
define
   fun {CollectDefTypes Tree}
      Coord1 = Tree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = Tree.file
      File = if File1==unit then noFile else File1 end
      Sem = Tree.sem
   in
      case Sem
      of s(DefTypeTreeList _) then
	 ConstantATypeTreeTups = {Map DefTypeTreeList.sem CollectDefTypes}
	 ConstantATypeTreeRec = {ListToRecord o ConstantATypeTreeTups}
      in
	 ConstantATypeTreeRec
      [] deftype(ConstantTree TypeTree) then
	 ConstantA = {Helpers.constantTree2A ConstantTree}
      in
	 ConstantA#TypeTree
      end
   end

   %%
   %%
   %% TypeNonQuantifier: ConstantATypeTreeRec Context Form
   %%                 -> o(operation:Tree con:Context)
   %% Extends the Context by Types found in Operation which
   %% aren't Quantifiers, and extends the tree by founded type-annotations
   fun {TypeNonQuantifier ConstantATypeTreeRec Context Form}
      FirstOp = Form.sem
      {Inspector.inspect FirstOp}
   in
      case FirstOp
      of neg(FormTree) then
	 NewValues = {DecideStrategy ConstantATypeTreeRec Context FormTree}
      in
	 o(operation:neg(NewValues.operation)
	   con:NewValues.con)
      [] conj(FormTree1 FormTree2) then
	 DoneFormTree1 = {DecideStrategy ConstantATypeTreeRec Context FormTree1}
	 DoneFormTree2 = {DecideStrategy ConstantATypeTreeRec Context FormTree2}
	 NewContext1 = {UnionContext Context DoneFormTree1.con}
	 NewContext2 = {UnionContext Context DoneFormTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
      in
	 o(operation:conj(DoneFormTree1.operation DoneFormTree2.operation) con:NewContext) 
      [] disj(FormTree1 FormTree2) then
	 DoneFormTree1 = {DecideStrategy ConstantATypeTreeRec Context FormTree1}
	 DoneFormTree2 = {DecideStrategy ConstantATypeTreeRec Context FormTree2}
	 NewContext1 = {UnionContext Context DoneFormTree1.con}
	 NewContext2 = {UnionContext Context DoneFormTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
      in
	 o(operation:disj(DoneFormTree1.operation DoneFormTree2.operation) con:NewContext)
      [] impl(FormTree1 FormTree2) then
	 DoneFormTree1 = {DecideStrategy ConstantATypeTreeRec Context FormTree1}
	 DoneFormTree2 = {DecideStrategy ConstantATypeTreeRec Context FormTree2}
	 NewContext1 = {UnionContext Context DoneFormTree1.con}
	 NewContext2 = {UnionContext Context DoneFormTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
      in
	 o(operation:impl(DoneFormTree1.operation DoneFormTree2.operation) con:NewContext)
      [] equi(FormTree1 FormTree2) then
	 DoneFormTree1 = {DecideStrategy ConstantATypeTreeRec Context FormTree1}
	 DoneFormTree2 = {DecideStrategy ConstantATypeTreeRec Context FormTree2}
	 NewContext1 = {UnionContext Context DoneFormTree1.con}
	 NewContext2 = {UnionContext Context DoneFormTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
      in
	 o(operation:equi(DoneFormTree1.operation DoneFormTree2.operation) con:NewContext)
      [] eq(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 if TypeExprTree1 == notype1 andthen TypeExprTree2 \= notype1 then
	    o(operation:eq(anno(DoneExprTree1.operation TypeExprTree2) DoneExprTree2.operation) con:NewContext)
	 elseif TypeExprTree2 == notype1 andthen TypeExprTree1 \= notype1 then
	    o(operation:eq(DoneExprTree1.operation anno(DoneExprTree2.operation TypeExprTree1)) con:NewContext)
	 elseif TypeExprTree2 \= notype1 andthen TypeExprTree1 \= notype1 andthen TypeExprTree2 \= TypeExprTree1 then
	    raise "Typeclash" end
	 else
	    o(operation:eq(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	 end
      [] neq(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 if TypeExprTree1 == notype1 andthen TypeExprTree2 \= notype1 then
	    o(operation:neq(anno(DoneExprTree1.operation TypeExprTree2) DoneExprTree2.operation) con:NewContext)
	 elseif TypeExprTree2 == notype1 andthen TypeExprTree1 \= notype1 then
	    o(operation:neq(DoneExprTree1.operation anno(DoneExprTree2.operation TypeExprTree1)) con:NewContext)
	 elseif TypeExprTree2 \= notype1 andthen TypeExprTree1 \= notype1 andthen TypeExprTree2 \= TypeExprTree1 then
	    raise "Typeclash" end
	 else
	    o(operation:neq(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	 end
      [] 'in'(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 case TypeExprTree2 of
	    set(Type) then
	    if TypeExprTree1 == notype1 then
	       o(operation:'in'(anno(DoneExprTree1.operation Type) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 [] notype1 then
	    if TypeExprTree1 \= notype1 then
	       o(operation:'in'(DoneExprTree1.operation anno(DoneExprTree2.operation set(TypeExprTree1))) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 else
	    if TypeExprTree2.set == TypeExprTree1 then
	       o(operation:'in'(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Typeclash" end
	    end
	 end
      [] notin(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 case TypeExprTree2 of
	    set(Type) then
	    if TypeExprTree1 == notype1 then
	       o(operation:notin(anno(DoneExprTree1.operation Type) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 [] notype1 then
	    if TypeExprTree1 \= notype1 then
	       o(operation:notin(DoneExprTree1.operation anno(DoneExprTree2.operation set(TypeExprTree1))) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 else
	    if TypeExprTree2.set == TypeExprTree1 then
	       o(operation:notin(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Typeclash" end
	    end
	 end
      [] subseteq(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 case TypeExprTree2 of
	    set(Type) then
	    if TypeExprTree1 == notype1 then
	       o(operation:subseteq(anno(DoneExprTree1.operation set(Type)) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 [] notype1 then
	    case TypeExprTree1 of
	    set(Type1) then
	       o(operation:subseteq(anno(DoneExprTree1.operation set(Type1)) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 else
	    if TypeExprTree2.set == TypeExprTree1.set then
	       o(operation:subseteq(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Typeclash" end
	    end
	 end
      [] disjoint(ExprTree1 ExprTree2) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext Context DoneExprTree2.con}
	 NewContext = {UnionContext NewContext1 NewContext2}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
      in
	 case TypeExprTree2 of
	    set(Type) then
	    if TypeExprTree1 == notype1 then
	       o(operation:disjoint(anno(DoneExprTree1.operation set(Type)) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 [] notype1 then
	    case TypeExprTree1 of
	    set(Type1) then
	       o(operation:disjoint(anno(DoneExprTree1.operation set(Type1)) DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Couldn't determine type" end
	    end
	 else
	    if TypeExprTree2.set == TypeExprTree1.set then
	       o(operation:disjoint(DoneExprTree1.operation DoneExprTree2.operation) con:NewContext)
	    else
	       raise "Typeclash" end
	    end
	 end
      [] intersect(ExprTree1 ExprTree2 ExprTree3) then
	 DoneExprTree1 = {DecideStrategy ConstantATypeTreeRec Context ExprTree1}
	 DoneExprTree2 = {DecideStrategy ConstantATypeTreeRec Context ExprTree2}
	 DoneExprTree3 = {DecideStrategy ConstantATypeTreeRec Context ExprTree3}
	 NewContext1 = {UnionContext Context DoneExprTree1.con}
	 NewContext2 = {UnionContext NewContext2 DoneExprTree2.con}
	 NewContext = {UnionContext NewContext2 DoneExprTree3.con}
	 TypeExprTree1 = if {HasFeature DoneExprTree1.operation anno} then
			    DoneExprTree1.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree2 = if {HasFeature DoneExprTree2.operation anno} then
			    DoneExprTree2.operation.anno.2
			 else
			    notype1
			 end
	 TypeExprTree3 = if {HasFeature DoneExprTree3.operation anno} then
			    DoneExprTree2.operation.anno.2
			 else
			    notype1
			 end
      in
%%%%%%%% DUMMY DUMMY DUMMY
	  o(operation:dummy
	   con:dummy)
      [] prec(TermTree1 TermTree2) then
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
      in
	 o(operation:prec(TermTree1 TermTree2)
	   con:NewContext2)
      [] word(TermTree1 TermTree2) then
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:word)}
	 else
	    NewContext1
	 end
      in
	 o(operation:word(TermTree1 TermTree2)
	   con:NewContext2)
      [] ledge(TermTree1 TermTree2 TermTree3 TermTree4) then
	 %% %
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
	 ConstantAI3 = {Helpers.termTree2AI TermTree3}
	 ConstantS3 = {V2S ConstantAI3}
	 NewContext3 =
	 if {Char.isAlpha ConstantS3.1} andthen
	    {Char.isUpper ConstantS3.1} andthen
	    {All ConstantS3
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    T = {Helpers.tree2T TermTree4}
	 in
	    {UnionContext NewContext2 o(ConstantAI3:label(T))}
	 else
	    NewContext2
	 end
      in
	 o(operation:ledge(TermTree1 TermTree2 TermTree3 TermTree4)
	   con:NewContext3)
      [] edge(TermTree1 TermTree2 TermTree3) then
	 %% %
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
	 ConstantAI3 = {Helpers.termTree2AI TermTree3}
	 ConstantS3 = {V2S ConstantAI3}
      in
	 o(operation:edge(TermTree1 TermTree2 TermTree3)
	   con:NewContext2)
      [] ldom(TermTree1 TermTree2 TermTree3 TermTree4) then
	 %% %
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
	 ConstantAI3 = {Helpers.termTree2AI TermTree3}
	 ConstantS3 = {V2S ConstantAI3}
	 NewContext3 =
	 if {Char.isAlpha ConstantS3.1} andthen
	    {Char.isUpper ConstantS3.1} andthen
	    {All ConstantS3
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    T = {Helpers.tree2T TermTree4}
	 in
	    {UnionContext NewContext2 o(ConstantAI3:label(T))}
	 else
	    NewContext2
	 end
      in
	 o(operation:ldom(TermTree1 TermTree2 TermTree3 TermTree4)
	   con:NewContext3)
      [] dom(TermTree1 TermTree2 TermTree3) then
	 %% %
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
	 ConstantAI3 = {Helpers.termTree2AI TermTree3}
	 ConstantS3 = {V2S ConstantAI3}
      in
	 o(operation:dom(TermTree1 TermTree2 TermTree3)
	   con:NewContext2)
      [] domeq(TermTree1 TermTree2 TermTree3) then
	 %% %
	 ConstantAI1 = {Helpers.termTree2AI TermTree1}
	 ConstantS1 = {V2S ConstantAI1}
	 NewContext1 =
	 if {Char.isAlpha ConstantS1.1} andthen
	    {Char.isUpper ConstantS1.1} andthen
	    {All ConstantS1
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext Context o(ConstantAI1:node)}
	 else
	    Context
	 end
	 ConstantAI2 = {Helpers.termTree2AI TermTree2}
	 ConstantS2 = {V2S ConstantAI2}
	 NewContext2 =
	 if {Char.isAlpha ConstantS2.1} andthen
	    {Char.isUpper ConstantS2.1} andthen
	    {All ConstantS2
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    {UnionContext NewContext1 o(ConstantAI2:node)}
	 else
	    NewContext1
	 end
	 ConstantAI3 = {Helpers.termTree2AI TermTree3}
	 ConstantS3 = {V2S ConstantAI3}
      in
	 o(operation:domeq(TermTree1 TermTree2 TermTree3)
	   con:NewContext2)
      [] anno(ExprTree TypeTree) then
	 Type = {Helpers.tree2T TypeTree ConstantATypeTreeRec}
      in
	 case ExprTree.sem
	 of constant(Token) then
	    ConstantV = Token.sem
	    ConstantA = {V2A ConstantV}
	    ConstantS = {A2S ConstantS}
	 in
	    if {Char.isAlpha ConstantS.1} andthen
	       {Char.isUpper ConstantS.1} andthen
	       {All ConstantS
		fun {$ Ch}
		   {Char.isAlpha Ch} orelse {Char.isDigit Ch}
		end}
	    then
	       o(operation:anno(ExprTree TypeTree)
		 con:{UnionContext Context o(ConstantA:Type)})
	    else
	       o(operation:ann(ExprTree TypeTree)
		con:Context)
	    end
	 [] integer(Token) then
	    IntegerI = Token.sem
	    NewContext = {UnionContext Context o(IntegerI:Type)}
	 in
	    o(operation:anno(ExprTree TypeTree)
	      con:NewContext)
	 [] set(TermList) then
	    NewTermConList = {Map
			      TermList
			      fun {$ Term}
				 {DecideStrategy
				  ConstantATypeTreeRec
				  Context
				  Term}
			      end}
	    NewTermList = {Map
			   NewTermConList
			   fun {$ TermCon}
			      TermCon.operation
			   end}
	    NewContext = {Map
			  NewTermConList
			  fun {$ TermCon}
			     {UnionContext
			      Context
			      TermCon.con}
			  end}
	    ElemType = {Helpers.tree2T NewTermList.1.2 ConstantATypeTreeRec}
	    
	 in
	    if Type == ElemType
	    then
	       o(operation:anno(set(NewTermList) TypeTree)
		 con:NewContext)
	    else
	       raise 'Typerror: Setelement != Set'
	       end
	    end
	 [] tuple(TermList) then
	    NewTermConList = {Map
			      TermList
			      fun {$ Term}
				 {DecideStrategy ConstantATypeTreeRec Context Term}
			      end}
	    NewTermList = {Map
			   NewTermConList
			   fun {$ TermCon}
			      TermCon.operation
			   end}
	   
	    NewContext = {Map
			  NewTermConList
			  fun {$ TermCon}
			     {UnionContext Context TermCon.con}
			  end}
	 in
	    o(operation:anno(set(NewTermList) TypeTree) con:NewContext)
	 [] anno(ExprTree TypeTree) then
	    o(operation:anno(
			   {DecideStrategy
			    ConstantATypeTreeRec
			    Context
			    ExprTree}.operation
			   TypeTree)
	      con:Context)
	 [] entry(Term1 Term2 Constant) then
	    NewOpConRec =  {DecideStrategy
			    ConstantATypeTreeRec
			    Context
			    entry(Term1 Term2 Constant)}
	 in
	    o(operation:anno(NewOpConRec.operation
			     TypeTree)
	      con:NewOpConRec.con)
	 [] attrs(Term1 Term2 Constant) then
	    NewOpConRec =  {DecideStrategy
			    ConstantATypeTreeRec
			    Context
			    attrs(Term1 Term2 Constant)}
	 in
	    o(operation:anno(NewOpConRec.operation
			     TypeTree)
	      con:NewOpConRec.con)
	 else
	    o
	 end
      [] constant(Token) then
	 ConstantV = Token.sem
	 ConstantA = {V2A ConstantV}
	 ConstantS = {A2S ConstantS}
      in
	 if {Char.isAlpha ConstantS.1} andthen
	    {Char.isUpper ConstantS.1} andthen
	    {All ConstantS
	     fun {$ Ch}
		{Char.isAlpha Ch} orelse {Char.isDigit Ch}
	     end}
	 then
	    if {HasFeature Context ConstantA} then
	       o(operation:anno(Token Context.ConstantA)
		 con:Context)
	    else
	       raise 'Could not detect Type'
	       end
	    end
	 end
      [] integer(Token) then
	 IntegerI = Token.sem
      in
	 if {HasFeature Context IntegerI} then
	       o(operation:anno(Token Context.IntegerI)
		 con:Context)
	 else
	    raise 'Could not detect Type'
	    end
	 end
      [] set(TermTreeList) then
	    NewTermConList = {Map
			      TermTreeList
			      fun {$ Term}
				 {DecideStrategy
				  ConstantATypeTreeRec
				  Context
				  Term}
			      end}
	    NewTermList = {Map
			   NewTermConList
			   fun {$ TermCon}
			      TermCon.operation
			   end}
	    NewContext = {Map
			  NewTermConList
			  fun {$ TermCon}
			     {UnionContext
			      Context
			      TermCon.con}
			  end}
	    ElemType = {Helpers.tree2T NewTermList.1.2 ConstantATypeTreeRec}
      in
	 %%% Achtung RTFM
	 if {Not ElemType.empty}
	 then
	    o(operation:anno(set(NewTermList) set(ElemType))
	      con:NewContext)
	 else
	    raise 'Typerror: Setelement != Set'
	    end
	 end
      [] tuple(TermTreeList) then
	 NewTermConList = {Map
			   TermTreeList
			   fun {$ Term}
			      {DecideStrategy ConstantATypeTreeRec Context Term}
			   end}
	 NewTermTreeList = {Map
			NewTermConList
			fun {$ TermCon}
			   TermCon.operation
			end}
	 NewTypeList = {Map
			NewTermConList
			fun {$ TermCon}
			   TermCon.con
			end}
	 NewContext = {Map
		       NewTermConList
		       fun {$ TermCon}
			  {UnionContext Context TermCon.con}
		       end}
      in
	 o(operation:anno(NewTermTreeList tuple(NewTypeList))
	   con:NewContext)
	 %%[] entry(TermTree1 TermTree2 ConstantTree) then
	 
      else
	 o
      end
   end
   %%
   %%
   %% DecideStrategy: ConstantATypeTreeRec Context Form
   %%                -> o(operation:Tree con:Context)
   %% Extends the current context, if the next Operator is a Quantor
   %% Otherwise it will call TypeNonQuantifier
   fun {DecideStrategy ConstantATypeTreeRec Context Form}
      FirstOp = Form.sem
   in
      case FirstOp
      of exists(ConstantTree DomTree FormTree) then
	 VarName = {Helpers.constantTree2A ConstantTree}
	 Dom = {Helpers.tree2T DomTree ConstantATypeTreeRec}
	 NewContext = {UnionContext Context o(VarName:Dom)}
	 NewValues = {DecideStrategy ConstantATypeTreeRec NewContext FormTree}
      in
	 o(operation:exists(ConstantTree DomTree NewValues.operation)
	   con:NewValues.con)
      [] exists(ConstantTree FormTree) then
	 VarName = {Helpers.constantTree2A ConstantTree}
      in
	 if {HasFeature Context VarName} then
	    raise 'ERROR: Variable already defined'#VarName end
	 else
	    NewContext = {UnionContext Context o(VarName:undef)}
	    NewValues = {DecideStrategy ConstantATypeTreeRec NewContext FormTree}
	 in
	    case NewValues.con.VarName
	    of undef then
	       raise 'ERROR: Variable has no type'#VarName end
	    else
	       %% %%Variable aus Context entfernen
	       o(operation:exists(ConstantTree NewValues.con.VarName NewValues.operation)
		 con:NewValues.con)
	    end
	 end
      [] forall(ConstantTree DomTree FormTree) then
	 VarName = {Helpers.constantTree2A ConstantTree}
	 Dom = {Helpers.tree2T DomTree ConstantATypeTreeRec}
	 NewContext = {UnionContext Context o(VarName:Dom)}
	 NewValues = {DecideStrategy ConstantATypeTreeRec NewContext FormTree}
      in
	 o(operation:forall(ConstantTree DomTree NewValues.operation)
	   con:NewValues.con)
      [] forall(ConstantTree FormTree) then
	 VarName = {Helpers.constantTree2A ConstantTree}
      in
	 if {HasFeature Context VarName} then
	    raise 'ERROR: Variable already defined'#VarName end
	 else
	    NewContext = {UnionContext Context o(VarName:undef)}
	    NewValues = {DecideStrategy ConstantATypeTreeRec NewContext FormTree}
	 in
	    case NewValues.con.VarName
	    of undef then
	       raise 'ERROR: Variable has no type'#VarName end
	    else
	       %% %%Variable aus Context entfernen
	       o(operation:forall(ConstantTree NewValues.con.VarName NewValues.operation)
		 con:NewValues.con)
	    end
	 end
      else
	 {TypeNonQuantifier ConstantATypeTreeRec Context Form}
      end
   end
   %%
   fun {UnionContext Context1 Context2}
      As1 = {Arity Context1}
      As2 = {Arity Context2}
      As21 = {Filter As2
	      fun {$ A2} {Not {Member A2 As1}} end}
      As = {Append As1 As21}
      %%
      ATTups =
      {Map As
       fun {$ A}
	  T1 = {CondSelect Context1 A undef}
	  T2 = {CondSelect Context2 A undef}
	  %%
	  T =
	  if T1==T2 then
	     T1
	  else
	     T11 = if T1==undef then _ else T1 end
	     T21 = if T2==undef then _ else T2 end
	  in
	     try
		T11 = T21
	     catch E then
		{Inspector.inspect 'UnionContext'}
		{Inspector.inspect E}
	     end
	     T11
	  end
       in
	  A#T
       end}
      ATRec = {List.toRecord o ATTups}
   in
      ATRec
   end
   %%
   %%
   %% Type Tree: Tree -> List of PrincipleTrees
   %% Builds TypeRecord
   %% For each Principle
   %%   For each Form
   %%    Call DecideStrategy
   fun {Type Tree}
      {System.show 1}
      ConstantATypeTreeRec = {CollectDefTypes Tree}
      {System.show 2}
      DefPrincipleList = Tree.sem.2
      {System.show 3}
      TempList = {Map DefPrincipleList.sem
		  fun {$ DefPrinciple}
		     FormList = DefPrinciple.sem.3.sem.1
		  in
		     {Map FormList.sem
		      fun {$ Form}
			 {DecideStrategy ConstantATypeTreeRec o Form}
		      end
		     }
		  end
		 }
   in
      TempList
   end
%      tree
end
