%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect:Inspect)
%   System(show:Show)

   Helpers(constantTree2A:ConstantTree2A
	   indent:Indent
	   tokenIsVar:TokenIsVar
	   t2V:T2V
	   tree2ILV:Tree2ILV
	   tree2T:Tree2T
	   vs2V:Vs2V) at 'Helpers.ozf'
export
   Evaluate
prepare
   RecordMap = Record.map
   ListMapInd = List.mapInd
   ListToTuple = List.toTuple
   V2A = VirtualString.toAtom
define
   %%
   %% UpdateVarTable: VarTable VarA T -> VarTable1
   %% Extends variable table V by new variable VarA with type T.
   %% Variable tables are mappings from variable names (atoms) to
   %% variable infos (VarInfo). VarInfo is a record partially mapping
   %% modes to virtual strings which represent values in that mode in
   %% the compiled output.
   %%
   %% The modes are:
   %%   a: atom
   %%   i: integer
   %%   m: set
   %%   n: node record
   %%
   fun {UpdateVarTable VarTable VarA T}
      VarInfo = case T
		of dim then o(a:'{Principle.dVA2DIDA '#VarA#'}') %% i?
		[] logic then o(i:VarA#'I')
		[] node then o(n:VarA#'NodeRec' i:VarA#'NodeRec.index')
		[] tset(_) then o(m:VarA#'M')
		else
		   o(a:VarA#'A' i:VarA#'I')
		end
      VarTable1 = {AdjoinAt VarTable VarA VarInfo}
   in
      VarTable1
   end
   
   %% Evaluate: Tree Options -> DefPrinciples
   %% Evaluates tree Tree to list of DefPrinciple tuples
   %% ConstantA#ConstantAs#ConstraintsV consisting of the principle
   %% name (ConstantA), a list of dimension variables (ConstantAs),
   %% and a virtual string representing the compiled constraint.
   %% Options is a record of evaluation options.
   fun {Evaluate Tree Options}
      fun {T2LatV T}
	 TV = {T2V T}
	 TA = {V2A TV}
	 if {Not {HasFeature TALatVDict TA}} then
	    I = {Length {Dictionary.items TALatVDict}}
	 in
	    TALatVDict.TA := 'Lat'#(I+1)
	 end
      in
	 TALatVDict.TA
      end
      %%
      %% ledge, ldom
      fun {VVLDPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 TermV2 = {Evaluate1 Sem.2 VarTable n node 0 false}
	 A = {ConstantTree2A Sem.4}
	 TermV3 = {Evaluate1 Sem.3 VarTable a label(A) 0 false}
	 TermV4 = {Evaluate1 Sem.4 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' '#TermV2#' '#TermV3#' '#TermV4#'}'
      end      
      %%
      %% daughtersLPrecDaughtersL
      fun {VLLDPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 A = {ConstantTree2A Sem.4}
	 TermV2 = {Evaluate1 Sem.2 VarTable a label(A) 0 false}
	 TermV3 = {Evaluate1 Sem.3 VarTable a label(A) 0 false}
	 TermV4 = {Evaluate1 Sem.4 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' NodeRecs '#TermV2#' '#TermV3#' '#TermV4#'}'
      end      
      %%
      %% edge, dom, domeq
      fun {VVDPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 TermV2 = {Evaluate1 Sem.2 VarTable n node 0 false}
	 TermV3 = {Evaluate1 Sem.3 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' '#TermV2#' '#TermV3#'}'
      end    
      %% prec
      fun {VVPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 TermV2 = {Evaluate1 Sem.2 VarTable n node 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' '#TermV2#'}'
      end
      %%
      %% disjointDaughtersL, disjointSubtreesL, zeroOrOneMothers,
      %% zeroOrOneDaughters, zeroMothers, zeroDaughters,
      %% oneOrMoreMothers, oneOrMoreDaughters, oneMother, oneDaughter
      fun {VDPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 TermV2 = {Evaluate1 Sem.2 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' '#TermV2#'}'
      end
      %%
      %% zeroOrOneMothersL, zeroOrOneDaughtersL, zeroMothersL,
      %% zeroDaughtersL, oneOrMoreMothersL, oneOrMoreDaughtersL,
      %% oneMotherL, oneDaughterL
      fun {VLDPredicate Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 A = {ConstantTree2A Sem.3}
	 TermV2 = {Evaluate1 Sem.2 VarTable a label(A) 0 false}
	 TermV3 = {Evaluate1 Sem.3 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' '#TermV2#' '#TermV3#'}'	 
      end
      %%
      %% eqPrecDaughtersL, daughtersLPrecEq
      fun {VLDPredicate1 Sem VarTable T IndentI}
	 TermV1 = {Evaluate1 Sem.1 VarTable n node IndentI+1 false}
	 A = {ConstantTree2A Sem.3}
	 TermV2 = {Evaluate1 Sem.2 VarTable a label(A) 0 false}
	 TermV3 = {Evaluate1 Sem.3 VarTable a dim 0 false}
      in
	 '{PW.'#{Label Sem}#'\n'#TermV1#' NodeRecs '#TermV2#' '#TermV3#'}'	 
      end
      %%
      %% subseteq (2), disjoint (2), intersect (3), union (3), minus
      %% (3), one (1), zero (1), oneOrMore (1), zeroOrOne (1)
      fun {NarySetPredicate N Sem VarTable T IndentI}
	 fun {NestedEval SetExprTree}
	    '\n'#{Evaluate1 SetExprTree VarTable i undef IndentI+1 false}
	 end
      in
	 '{PW.'#{Label Sem}#{RecordMap {Adjoin Sem '#'} NestedEval}#'}'
      end
      %%
      %% intersect, union, minus, nodeCompl
      fun {BinarySetOp Sem VarTable ModeA T IndentI}
	 ExprV1 = {Evaluate1 Sem.1 VarTable i undef IndentI+1 true}
	 ExprV2 = {Evaluate1 Sem.2 VarTable i undef IndentI+1 false}
      in
	 '{FS.'#{Label Sem}#'\n'#ExprV1#ExprV2#'}'
      end
      %%
      %% mothers, daughters, down, up, eqdown, equp
      fun {ModelAccess Sem VarTable IndentI}
	 NodeV = {Evaluate1 Sem.1 VarTable n node 0 false}
	 DimV = {Evaluate1 Sem.2 VarTable a dim 0 false}
      in
	 NodeV#'.'#DimV#'.model.'#{Label Sem}
      end
      %%
      %% mothersL, daughtersL, downL, upEndL
      fun {ModelAccessL Sem VarTable IndentI}
	 A = {ConstantTree2A Sem.3}
	 EdgeLabelV = {Evaluate1 Sem.2 VarTable a label(A) 0 false}
	 Feat = {Label Sem}
      in
	 {ModelAccess Feat(Sem.1 Sem.3) VarTable IndentI}#'.'#EdgeLabelV
      end
      %%
      fun {AnyQuantifier Sem VarTable ModeA T IndentI}
	 VarA = {ConstantTree2A Sem.1}
	 Dom = {Tree2T Sem.2 o}
	 VarTable1 = {UpdateVarTable VarTable VarA Dom}
	 %%
	 FormV = {Evaluate1 Sem.3 VarTable1 ModeA logic IndentI+4 true}
	 LabelA = {Label Sem}
	 IndentA = {Indent IndentI}
      in
	 case Dom
	 of node then
	    NodeRecV = VarTable1.VarA.n
	 in
	    '{PW.'#LabelA#'Nodes NodeRecs\n'#
	    IndentA#' fun {$ '#NodeRecV#'}\n'#
	    FormV#
	    IndentA#' end}'
	 else
	    AV = VarTable1.VarA.a
	    IV = VarTable1.VarA.i
	    %%
	    DomLatV = {T2LatV Dom}
	 in
	    '{PW.'#LabelA#'Dom '#DomLatV#'\n'#
	    IndentA#' fun {$ '#AV#' '#IV#'}\n'#
	    FormV#
	    IndentA#' end}'
	 end
      end
      %%
      fun {Quantifier Sem VarTable ModeA T IndentI}
	 {AnyQuantifier Sem VarTable ModeA T IndentI}
      end
      %%
      fun {SetQuantifier Sem VarTable ModeA T IndentI}
	 {AnyQuantifier Sem VarTable ModeA T IndentI}
      end
      fun {Xequal Sem VarTable ModeA T IndentI}
	 ExprV1 = {Evaluate1 Sem.1 VarTable i undef IndentI+1 true}
	 ExprV2 = {Evaluate1 Sem.2 VarTable i undef IndentI+1 false}
	 A = case {Label Sem}
	     of eq then 'eq'
	     else 'neq'
	     end
      in
	 '{PW.'#A#'\n'#ExprV1#ExprV2#'}'
      end
      %%
      fun {Evaluate1 Tree VarTable ModeA T IndentI NewLineB}
	 Coord1 = Tree.coord
	 Coord = if Coord1==unit then noCoord else Coord1 end
	 File1 = Tree.file
	 File = if File1==unit then noFile else File1 end
	 %%
	 IndentA = {Indent IndentI}
	 %%
	 Sem = Tree.sem
	 V =
	 case Sem
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% S
	 of s(_ DefPrincipleTreeList) then
	    DefPrinciples =
	    {Map DefPrincipleTreeList.sem
	     fun {$ DefPrincipleTree}
		{Evaluate1 DefPrincipleTree VarTable ModeA T IndentI false}
	     end}
	 in
	    noIndent(DefPrinciples)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Defprinciple
	 [] defprinciple(ConstantTree DimsTree ConstraintsTree) then
	    ConstantA = {ConstantTree2A ConstantTree}
	    ConstantAs = {Evaluate1 DimsTree VarTable ModeA T IndentI false}
	    VarTable1 = o    
	    ConstraintsV = {Evaluate1 ConstraintsTree VarTable1 ModeA T IndentI true}
	 in
	    noIndent(ConstantA#ConstantAs#ConstraintsV)
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Dims
	 [] dims(ConstantTreeList) then
	    noIndent({Map ConstantTreeList.sem ConstantTree2A})
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% letdim
	 [] letdim(ConstantTree1 ConstantTree2 FormTree) then
	    ConstantA1 = {ConstantTree2A ConstantTree1}
	    ConstantA2 = {ConstantTree2A ConstantTree2}
	    VarTable1 = {UpdateVarTable VarTable ConstantA1 dim}
	    FormV = {Evaluate1 FormTree VarTable1 ModeA logic IndentI+1 true}
	 in
	    'local '#ConstantA1#' = \''#ConstantA2#'\' in\n'#
	    FormV#
	    IndentA#'end %local'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% Constraints
	 [] constraints(FormTreeList) then
	    FormTrees = FormTreeList.sem
	    I = {Length FormTrees}
	    FormVs = {ListMapInd FormTrees
		      fun {$ I1 FormTree}
			 {Evaluate1 FormTree VarTable ModeA logic IndentI true}#
			 IndentA#'= 1'#
			 if I1 == I then nil else '\n' end
		      end}
	 in
	    noIndent({ListToTuple '#' FormVs})
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% constant
	 [] constant(Token) then
	    ConstantV = Token.sem
	    ConstantA = {V2A ConstantV}
	 in
	    if {TokenIsVar Token} then
	       VarTable.ConstantA.ModeA
	    else
	       if ModeA==i then
		  LatV = {T2LatV T}
	       in
		  '{'#LatV#'.aI2I \''#ConstantA#'\'}'
	       else
		  '\''#ConstantA#'\''
	       end
	    end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% integer
	 [] integer(Token) then
	    IntegerI = Token.sem
	 in
	    if ModeA==i then
	       IntegerI
	    else
	       '{Nth NodeRecs '#IntegerI#'}'
	    end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set
	 [] set(TermTreeList) then
	    case TermTreeList.sem
	    of nil then
	       'FS.value.empty'
	    [] TermTrees then
	       TermVs = {Map TermTrees
			 fun {$ TermTree}
			    {Evaluate1 TermTree VarTable i undef 0 false}
			 end}
	       TermV = {Vs2V TermVs '[' ']' ' '}
	    in
	       '{FS.value.make '#TermV#'}'
	    end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% type annotation
	 [] anno(ExprTree TypeTree) then
	    T1 = {Tree2T TypeTree o}
	 in
	    noIndent({Evaluate1 ExprTree VarTable ModeA T1 IndentI false})
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% set generator
	 [] setgen(SetgenTree) then
	    SetgenILV = {Tree2ILV SetgenTree}
	    LatV = {T2LatV T}
	 in
	    '{'#LatV#'.encodeProc1 '#SetgenILV#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% tuple
	 [] tuple(TermTreeList) then
	    TermVs = {ListMapInd TermTreeList.sem
		      fun {$ I TermTree}
			 {Evaluate1 TermTree VarTable a undef 0 false}
		      end}
	    TermV = {Vs2V TermVs '[' ']' ' '}
	    LatV = {T2LatV T}
	 in
	    '{'#LatV#'.aIs2I '#TermV#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% lexical attributes access
	 [] entry(TermTree1 TermTree2 ConstantTree) then
	    TermV1 = {Evaluate1 TermTree1 VarTable n node 0 false}
	    TermV2 = {Evaluate1 TermTree2 VarTable a dim 0 false}
	    ConstantV = {Evaluate1 ConstantTree VarTable a attrs 0 false}
	 in
	    TermV1#'.'#TermV2#'.'#entry#'.'#ConstantV
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% non-lexical attributes access
	 [] attrs(TermTree1 TermTree2 ConstantTree) then
	    TermV1 = {Evaluate1 TermTree1 VarTable n node 0 false}
	    TermV2 = {Evaluate1 TermTree2 VarTable a dim 0 false}
	    ConstantV = {Evaluate1 ConstantTree VarTable a attrs 0 false}
	 in
	    TermV1#'.'#TermV2#'.'#attrs#'.'#ConstantV
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% negation
	 [] neg(FormTree) then
	    FormV = {Evaluate1 FormTree VarTable ModeA logic IndentI+1 false}
	 in
	    '{PW.nega \n'#FormV#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% conjunction
	 [] conj(FormTree1 FormTree2) then
	    FormV1 = {Evaluate1 FormTree1 VarTable ModeA logic IndentI+1 true}
	    FormV2 = {Evaluate1 FormTree2 VarTable ModeA logic IndentI+4 true}
	 in
	    '{PW.conj \n'#
	    FormV1#
	    IndentA#' fun {$}\n'#
	    FormV2#
	    IndentA#' end}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjunction
	 [] disj(FormTree1 FormTree2) then
	    FormV1 = {Evaluate1 FormTree1 VarTable ModeA logic IndentI+1 true}
	    FormV2 = {Evaluate1 FormTree2 VarTable ModeA logic IndentI+4 true}
	 in
	    '{PW.disj \n'#
	    FormV1#
	    IndentA#' fun {$}\n'#
	    FormV2#
	    IndentA#' end}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% implication
	 [] impl(FormTree1 FormTree2) then
	    FormV1 = {Evaluate1 FormTree1 VarTable ModeA logic IndentI+1 true}
	    FormV2 = {Evaluate1 FormTree2 VarTable ModeA logic IndentI+4 true}
	 in
	    '{PW.impl \n'#
	    FormV1#
	    IndentA#' fun {$}\n'#
	    FormV2#
	    IndentA#' end}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% equivalence
	 [] equi(FormTree1 FormTree2) then
	    FormV1 = {Evaluate1 FormTree1 VarTable ModeA logic IndentI+1 true}
	    FormV2 = {Evaluate1 FormTree2 VarTable ModeA logic IndentI+4 true}
	 in
	    '{PW.equi \n'#
	    FormV1#
	    IndentA#' fun {$}\n'#
	    FormV2#
	    IndentA#' end}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% let
	 [] let(ConstantTree FormTree1 FormTree2) then
	    ConstantA = {ConstantTree2A ConstantTree}
	    FormV1 = {Evaluate1 FormTree1 VarTable i logic IndentI+4 true}
	    VarTable1 = {UpdateVarTable VarTable ConstantA logic}
	    LetDefV =
	    VarTable1.ConstantA.i#
	    ' = {ByNeed fun {$}\n'#FormV1#IndentA#'  end}\n'
	    FormV2 = {Evaluate1 FormTree2 VarTable1 ModeA logic IndentI+1 true}
	 in
	    'local '#LetDefV#
	    IndentA#'in\n'#FormV2#
	    IndentA#'end %local'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% logicvar: reading logic vars
	 [] logicvar(ConstantTree) then
	    {Evaluate1 ConstantTree VarTable ModeA logic 0 false}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% var: reading arbitrary vars
	 [] var(ConstantTree) then
	    {Evaluate1 ConstantTree VarTable ModeA logic 0 false}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% existential quantification
	 [] exists(_ _ _) = Sem then
	    {Quantifier Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% one-existential quantification
	 [] existsone(_ _ _) = Sem then
	    {Quantifier {Adjoin Sem existsOne} VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% universal quantification
	 [] forall(_ _ _) = Sem then
	    {Quantifier Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% existential quantification (set version)
	 [] setExists(_ _ _) = Sem then
	    {SetQuantifier Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% one-existential quantification
	 [] setExistsOne(_ _ _) = Sem then
	    {SetQuantifier Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% universal quantification
	 [] setForall(_ _ _) = Sem then
	    {SetQuantifier Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% equality
	 [] eq(_ _) = Sem then
	    {Xequal Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% unequality
	 [] neq(_ _) = Sem then
	    {Xequal Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% element
	 [] 'in'(ExprTree1 ExprTree2) then
	    ExprV1 = {Evaluate1 ExprTree1 VarTable i undef IndentI+1 true}
	    ExprV2 = {Evaluate1 ExprTree2 VarTable i undef IndentI+1 false}
	 in
	    '{PW.\'in\'\n'#ExprV1#ExprV2#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% not element
	 [] notin(ExprTree1 ExprTree2) then
	    ExprV1 = {Evaluate1 ExprTree1 VarTable i undef IndentI+1 true}
	    ExprV2 = {Evaluate1 ExprTree2 VarTable i undef IndentI+1 false}
	 in
	    '{PW.notin\n'#ExprV1#ExprV2#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% subset
	 [] subseteq(_ _) = Sem then
	    {NarySetPredicate 2 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjointness
	 [] disjoint(_ _) = Sem then
	    {NarySetPredicate 2 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% intersection
	 [] intersect(_ _) = Sem then
	    {BinarySetOp Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% union
	 [] union(_ _) = Sem then
	    {BinarySetOp Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% minus
	 [] minus(_ _) = Sem then
	    {BinarySetOp Sem VarTable ModeA logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% reified intersection
	 [] intersect(_ _ _) = Sem then
	    {NarySetPredicate 3 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% reified union
	 [] union(_ _ _) = Sem then
	    {NarySetPredicate 3 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% reified minus
	 [] minus(_ _ _) = Sem then
	    {NarySetPredicate 3 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% labeled edge
	 [] ledge(_ _ _ _) = Sem then
	    {VVLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% edge
	 [] edge(_ _ _) = Sem then
	    {VVDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% labeled strict dominance
	 [] ldom(_ _ _ _) = Sem then
	    {VVLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% strict dominance
	 [] dom(_ _ _) = Sem  then
	    {VVDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% dominance
	 [] domeq(_ _ _) = Sem then
	    {VVDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% precedence
	 [] prec(_ _) = Sem then
	    {VVPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% word
	 [] word(TermTree1 TermTree2) then
	    TermV1 = {Evaluate1 TermTree1 VarTable n node IndentI+1 false}
	    TermV2 = {Evaluate1 TermTree2 VarTable a word IndentI+1 false}
	 in
	    '{PW.word\n'#TermV1#' '#TermV2#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjointDaughtersL
	 [] disjointDaughtersL(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% disjointSubtreesL
	 [] disjointSubtreesL(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% eqPrecDaughtersL
	 [] eqPrecDaughtersL(_ _ _) = Sem then
	    {VLDPredicate1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% daughtersLPrecEq
	 [] daughtersLPrecEq(_ _ _) = Sem then
	    {VLDPredicate1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% daughtersLPrecDaughtersL
	 [] daughtersLPrecDaughtersL(_ _ _ _) = Sem then
	    {VLLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% projective
	 [] projective(TermTree) then
	    TermV = {Evaluate1 TermTree VarTable a dim IndentI+1 false}
	 in
	    '{PW.projective NodeRecs\n'#TermV#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroOrOneMothers
	 [] zeroOrOneMothers(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroOrOneMothersL
	 [] zeroOrOneMothersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroOrOneDaughters
	 [] zeroOrOneDaughters(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroOrOneDaughtersL
	 [] zeroOrOneDaughtersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroMothers
	 [] zeroMothers(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroMothersL
	 [] zeroMothersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroDaughters
	 [] zeroDaughters(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroDaughtersL
	 [] zeroDaughtersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneOrMoreMothers
	 [] oneOrMoreMothers(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneOrMoreMotherL
	 [] oneOrMoreMothersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneOrMoreDaughters
	 [] oneOrMoreDaughters(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneOrMoreDaughtersL
	 [] oneOrMoreDaughtersL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneMother
	 [] oneMother(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneMotherL
	 [] oneMotherL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneDaughter
	 [] oneDaughter(_ _) = Sem then
	    {VDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneDaughterL
	 [] oneDaughterL(_ _ _) = Sem then
	    {VLDPredicate Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% one(S) - S is a singleton
	 [] one(_) = Sem then
	    {NarySetPredicate 1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zero(S) - S is empty
	 [] zero(_) = Sem then
	    {NarySetPredicate 1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% oneOrMore(S) - S is not empty
	 [] oneOrMore(_) = Sem then
	    {NarySetPredicate 1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% zeroOrOne(S) - S is empty or a singleton
	 [] zeroOrOne(_) = Sem then
	    {NarySetPredicate 1 Sem VarTable logic IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% allNodes(S) - S contains all node indexes
	 [] allNodes(S) then
	    NodeUniverseTree =
	    value(coord:Coord
		  file:File
		  sem:nodeUniverse(token(coord:Coord file:File sem:nodeUniverse sym:nodeUniverse)))
	    EqTree =
	    value(coord:Coord
		  file:File
		  sem:eq(S NodeUniverseTree))
	 in
	    noIndent({Evaluate1 EqTree VarTable ModeA logic IndentI false})
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% nodeCompl(S) - yields the set of all node indexes
	    %% not in S
	 [] nodeCompl(S) then
	    NodeUniverseTree =
	    value(coord:Coord
		  file:File
		  sem:nodeUniverse(token(coord:Coord file:File sem:nodeUniverse sym:nodeUniverse)))
	 in
	    if S.sem==empty then
	       {Evaluate1 NodeUniverseTree VarTable i tset(node) 0 false}
	    else
	       {BinarySetOp diff(NodeUniverseTree S) VarTable i tset(node) IndentI}
	    end
	 [] nodeUniverse(...) then
	    'NodeRecs.1.nodeSet'
	 [] nodeAsSet(NodeExpr) then
	    '{FS.value.singl '#{Evaluate1 NodeExpr VarTable i node 0 false}#'}' 
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% empty
	 [] empty then
	    'FS.value.empty'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% boolDotSet
	 [] boolDotSet(BoolTree SetTree) then
	    BoolV = {Evaluate1 BoolTree VarTable i logic IndentI+1 true}
	    SetV = {Evaluate1 SetTree VarTable i tset(node) IndentI+1 false}
	 in
	    '{PW.boolDotSet\n'#BoolV#SetV#'}'
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% boolOpSet
	 [] boolOpSet(OpTree BoolTree SetTree) then
	    if OpTree.sem==intersect then
	       BoolDotSetTree = value(coord:Coord
				      file:File
				      sem:boolDotSet(BoolTree SetTree))
	    in
	       noIndent({Evaluate1 BoolDotSetTree VarTable ModeA tset(node) IndentI false})
	    else
	       NodeUniverseTree =
	       value(coord:Coord
		     file:File
		     sem:nodeUniverse(token(coord:Coord file:File sem:nodeUniverse sym:nodeUniverse)))
	       %%
	       BoolV = {Evaluate1 BoolTree VarTable i logic IndentI+1 true}
	       SetV1 = {Evaluate1 NodeUniverseTree VarTable i tset(node) IndentI+1 true}
	       SetV2 = {Evaluate1 SetTree VarTable i tset(node) IndentI+1 false}
	    in
	       '{PW.ifThenElseSet\n'#BoolV#SetV1#SetV2#'}'
	    end
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% mothers
	 [] mothers(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% mothersL
	 [] mothersL(_ _ _) = Sem then
	    {ModelAccessL Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% daughters
	 [] daughters(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% daughtersL
	 [] daughtersL(_ _ _) = Sem then
	    {ModelAccessL Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% down
	 [] down(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% downL
	 [] downL(_ _ _) = Sem then
	    {ModelAccessL Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% up
	 [] up(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% upEndL
	 [] upEndL(_ _ _) = Sem then
	    {ModelAccessL Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% eqdown
	 [] eqdown(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    %% equp
	 [] equp(_ _) = Sem then
	    {ModelAccess Sem VarTable IndentI}
	 end
	 IndentedV = case V
		     of noIndent(V1) then V1
		     elseif IndentI==0 then V
		     else IndentA#V
		     end
	 IndentedV1 = if NewLineB then IndentedV#'\n' else IndentedV end
      in
	 IndentedV1
      end
      TALatVDict = {NewDictionary}
      DefPrinciples = {Evaluate1 Tree o i logic 6 false}
      TALatVTups = {Dictionary.entries TALatVDict}
      TALatVTups1 = {Sort TALatVTups
		     fun {$ _#LatV1 _#LatV2}
			LatA1 = {V2A LatV1}
			LatA2 = {V2A LatV2}
		     in
			LatA1<LatA2
		     end}
   in
      DefPrinciples#TALatVTups1
   end
end
