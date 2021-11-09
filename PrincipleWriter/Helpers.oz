%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   
   Open(file)
export
   %% general
   CoordFile2V
   E2V
   Indent
   Multiply
   NoDoubles
   PutV
   Vs2V

   %% PW-specific
   ConstantTree2A
   Sem2A
   TermTree2AI
   T2V
   Tree2T
   T2Tree
   Tree2ILV
   ConstantTreeIsVar
   SemIsVar
   TokenIsVar
   CanBeDomT
   CanBeSetT
   CanBeTupleT
define
   S2A = String.toAtom
   S2I = String.toInt
   V2A = VirtualString.toAtom
   V2S = VirtualString.toString
   fun {V2I V} {S2I {V2S V}} end
   %%
   %% CoordFile2V: Coord File -> V
   %% Transforms a coordinate Coord and file File into a virtual
   %% string V.
   fun {CoordFile2V Coord File}
      CoordV =
      case Coord
      of I1#I2 then
	 if I1==I2 then
	    I1
	 else
	    I1#'-'#I2
	 end
      [] noCoord then noCoord
      elseif {IsInt Coord} then Coord
      else
	 raise error1('functor':'PrincipleWriter/Helpers.ozf' 'proc':'CoordFile2V' msg:'Illformed coordinate.' info:o(Coord) coord:noCoord file:noFile) end
      end
      CoordV1 = if CoordV==noCoord then
		   'no line'
		else
		   'line: '#CoordV
		end
      FileV = if File==noFile then
		 'no file'
	      else
		 'file: '#File
	      end
      V = if CoordV1=='no line' andthen FileV=='no file' then ''
	  else '('#CoordV1#', '#FileV#')'
	  end
   in
      V
   end
   %% E2V: E -> V
   %% Returns virtual string V corresponding to exception E.
   fun {E2V E}
      V =
      case E
      of error1(msg: MsgA
		coord: Coord
		file: File ...) then
	 CoordFileV = {CoordFile2V Coord File}
      in
	 MsgA#' '#CoordFileV
      [] error(kernel(stringNoInt S) ...) then
	 'Could not convert string to integer: "'#S#'"'
      [] tokenizer(MsgA Coord File ...) then
	 CoordFileV = {CoordFile2V Coord File}
      in
	 'UL tokenizer error '#CoordFileV#': '#MsgA
      [] error(url(_ File) ...) then
	 'Cannot open file: '#File
      [] parser(input:token(coord:Coord file:File ...)|_
		...) then
	 CoordV = {CoordFile2V Coord File}
      in
	 'UL parser error '#CoordV
      [] parser(input:token(sem:_ sym:_)|_
		stack:_|token(coord:Coord file:File ...)|_ ...) then
	 CoordV = {CoordFile2V Coord File}
      in
	 'UL parser error '#CoordV
%       [] xml(tokenizer(line:Coord file:File ...) ...) then
% 	 CoordV = {CoordFile2V Coord File}
%       in
% 	 'XML tokenizer error '#CoordV
%       [] xml(parser:_ ...) then
% 	 MsgA = {Label E.parser}
% 	 File = E.parser.coord.1
% 	 Coord = E.parser.coord.2
% 	 CoordFileV = {CoordFile2V Coord File}
%       in
% 	 'XML parser error '#CoordFileV#': '#MsgA
%       [] system(module(notFound load A)) then
% 	 'Could not find functor '#A#' (this could be due to two issues, either 1) you have not yet installed the required MOGUL packages, or 2) you have not installed the XDK globally, hence you have to start it from the directory where you extracted it into)'
%       [] system(os(os "connect" _ "Connection refused")
% 		debug:d(info:fapply(_
% 				    [_ _ PortI] ...)|_ ...)) then
% 	 'Socket error: Connection to port '#PortI#' refused (hint: check whether the server is running or choose another port).'
%       [] system(os(os "open" _ "No such file or directory")
% 		debug:d(info:[fapply(_
% 				     [UrlS _ _] 1)] ...)) then
% 	 'Open file error: Cannot open file "'#UrlS#'".'		
      else
	 'unhandled error'
      end
   in
      V
   end
   %% IndentI: I -> A
   %% Creates atom A consisting of I spaces.
   fun {Indent I}
      S =
      for I1 in 1..I collect:Collect do
	 {Collect & }
      end
      A = {S2A S}
   in
      A
   end
   %% Multiply: Xss -> Xss1
   %% Multiplies out a list of lists.
   fun {Multiply Xss}
      Xss1 =
      if Xss==nil then
	 [nil]
      else
	 Xs1|Xss1 = Xss
	 Xss2 = {Map Xs1
		 fun {$ X} [X] end}
      in
	 {FoldL Xss1
	  fun {$ AccXss Xs}
	     for AccXs in AccXss collect:Collect do
		for X in Xs do
		   Xss = {Append AccXs [X]}
		in
		   {Collect Xss}
		end
	     end
	  end Xss2}
      end
   in
      Xss1
   end
   %% NoDoubles: Xs -> Ys
   %% Removes double elements from list Xs.
   fun {NoDoubles Xs}
      {FoldL Xs fun {$ AccXs X}
		   if {Member X AccXs} then
		      AccXs
		   else
		      {Append AccXs [X]}
		   end
		end nil}
   end
   %% PutV: V UrlV -> U
   %% Writes the virtual string V into a file with URL UrlV.
   proc {PutV V UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [create truncate write text])}
   in
      {FileO write(vs: V)}
      {FileO close}
   end
   %% Vs2V: Vs OpenA CloseA SepA -> V
   %% Creates virtual string V from list of virtual strings Vs,
   %% enclosing the elements of Vs in OpenA and CloseA and separating
   %% them with SepA.
   fun {Vs2V Vs OpenA CloseA SepA}
      if Vs==nil then
	 nil
      else
	 V1|Vs1 = Vs
      in
	 OpenA#{FoldL Vs1 fun {$ AccV V} AccV#SepA#V end V1}#CloseA
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IntegerTree2I: IntegerTree -> I
   %% Transforms IntegerTree into integer I.
   fun {IntegerTree2I IntegerTree}
      case IntegerTree
      of value(sem:integer(token(sem:Sem ...)) ...) then
	 {V2I Sem}
      [] value(sem:anno(IntegerTree1 ...) ...) then
	 {IntegerTree2I IntegerTree1}
      end
   end
   %% ConstantTree2A: ConstantTree -> A
   %% Transforms ConstantTree into atom A.
   fun {ConstantTree2A ConstantTree}
      case ConstantTree
      of value(sem:Sem ...) then {Sem2A Sem}
      [] constant(A) then A
      end
   end
   %% Sem2A: Sem -> A
   %% Transforms Sem into atom A.
   fun {Sem2A Sem}
      case Sem
      of constant(token(sem:Sem1 ...)) then
	 {V2A Sem1}
      [] anno(ConstantTree ...) then
	 {ConstantTree2A ConstantTree}
      [] constant(value(sem:Sem1 ...)) then
	 {V2A Sem1}
      [] constant(A) then
	 A
      end
   end
   %%
   fun {A2ConstantTree A}
      value(coord:noCoord
	    file:noFile
	    sem:constant(token(sem:A coord:noCoord file:noFile sym:'<id>')))
   end
   %% TermTree2AI: TermTree -> AI
   %% Transforms TermTree into atom A (if TermTree is a constant) or
   %% into integer I (if TermTree is an integer).
   fun {TermTree2AI TermTree}
      case TermTree
      of value(sem:constant(token(sem:Sem ...)) ...) then
	 {V2A Sem}
      [] value(sem:integer(token(sem:Sem ...)) ...) then
	 {S2I {V2S Sem}}
      [] value(sem:anno(TermTree1 ...) ...) then
	 {TermTree2AI TermTree1}
      end
   end
   %% ConstantTreeIsVar: ConstantTree -> B
   %% Returns true if ConstantTree denotes a variable.
   fun {ConstantTreeIsVar ConstantTree}
      case ConstantTree
      of value(sem:Sem ...) then {SemIsVar Sem}
      [] constant(_) then true
      end
   end
   %% SemIsVar: Sem -> B
   %% Returns true if Sem denotes a variable.
   fun {SemIsVar Sem}
      case Sem
      of constant(token(...)) then {TokenIsVar Sem.1}
      [] constant(_) then true
      end
   end
   %% TokenIsVar: Token -> B
   %% Returns true if Token denotes a variable. Token is a variable
   %% if: 1) it is has been tokenized as an <id>, i.e., was *not*
   %% enclosed in single, double, or guillemet quotes, 2) begins with
   %% an uppercase letter followed by an arbitrary number of letters
   %% and digits.
   fun {TokenIsVar Token}
      V = Token.sem
      S = {V2S V}
   in
      {CondSelect Token sym '<id>'}=='<id>' andthen
      {Char.isAlpha S.1} andthen
      {Char.isUpper S.1} andthen
      {All S
       fun {$ Ch}
	  {Char.isAlpha Ch} orelse {Char.isDigit Ch}
       end}
   end
   %% T2V: T -> V
   %% Transforms type T into virtual string V.
   fun {T2V T}
      case T
      of dom(As) then
	 Vs = {Map As
	       fun {$ A} '\''#A#'\'' end}
	 V = {Vs2V Vs '[' ']' ' '}
      in
	 'dom('#V#')'
      [] label(A) then
	 'label(\''#A#'\')'
      [] node then
	 node
      [] dim then
	 dim
      [] 'attr' then
	 'attr'
      [] word then
	 word
      [] tset(Dom) then
	 V = {T2V Dom}
      in
	 'tset('#V#')'
      [] ttuple(Doms) then
	 Vs = {Map Doms T2V}
	 V = {Vs2V Vs '[' ']' ' '}
      in
	 'ttuple('#V#')'
      [] tdom(T1) then
	 V = {T2V T1}
      in
	 'tdom('#V#')'
      [] tproj(T1 I) then
	 V = {T2V T1}
      in
	 'tproj('#V#' '#I#')'
      [] entry(A1 A2) then
	 'entry(\''#A1#'\' \''#A2#'\')'
      [] attrs(A1 A2) then
	 'attrs(\''#A1#'\' \''#A2#'\')'
      [] eq(Ts) then
	 Vs = {Map Ts T2V}
	 V = {Vs2V Vs '[' ']' ' '}
      in
	 'eq('#V#')'
      [] logic then
	 logic
      [] undef then
	 undef
      end
   end
   %% Tree2T: TypeTree ConstantATypeTreeRec -> T
   %% Transforms type tree TypeTree into type T.
   fun {Tree2T TypeTree ConstantATypeTreeRec}
      Coord1 = TypeTree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = TypeTree.file
      File = if File1==unit then noFile else File1 end
      Sem = TypeTree.sem
   in   
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% domain
      of dom(ConstantTreeList) then
	 ConstantAs = {Map ConstantTreeList.sem ConstantTree2A}
	 ConstantAs1 = {Sort ConstantAs Value.'<'}
      in
	 dom(ConstantAs1)
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
      [] tset(DomTree) then
	 T1 = {Tree2T DomTree ConstantATypeTreeRec}
      in
	 tset(T1)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tuple
      [] ttuple(DomTreeList) then
	 Ts = {Map DomTreeList.sem
	       fun {$ DomTree}
		  {Tree2T DomTree ConstantATypeTreeRec}
	       end}
      in
	 ttuple(Ts)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tdom
      [] tdom(Tree) then
	 T = {Tree2T Tree ConstantATypeTreeRec}
      in
	 tdom(T)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tproj
      [] tproj(Tree IntegerTree) then
	 T = {Tree2T Tree ConstantATypeTreeRec}
	 I = {IntegerTree2I IntegerTree}
      in
	 tproj(T I)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tentry
      [] tentry(ConstantTree1 ConstantTree2) then
	 A1 = {ConstantTree2A ConstantTree1}
	 A2 = {ConstantTree2A ConstantTree2}
      in
	 entry(A1 A2)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% tattrs
      [] tattrs(ConstantTree1 ConstantTree2) then
	 A1 = {ConstantTree2A ConstantTree1}
	 A2 = {ConstantTree2A ConstantTree2}
      in
	 'attrs'(A1 A2)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% teq
      [] teq(TreeList) then
	 Trees = TreeList.sem
	 Ts = {Map Trees
	       fun {$ Tree}
		  {Tree2T Tree ConstantATypeTreeRec}
	       end}
      in
	 eq(Ts)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% logic
      [] logic(...) then
	 logic
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% undef
      [] undef(...) then
	 undef
      end
   end
   %%
   fun {T2Tree T Coord File}
      fun {T2Tree1 T}
	 Sem =
	 case T
	 of dom(As) then
	    ConstantTrees = {Map As A2ConstantTree}
	 in
	    dom(value(coord:Coord
		      file:File
		      sem:ConstantTrees))
	 [] label(A) then
	    ConstantTree = {A2ConstantTree A}
	 in
	    edgelabels(ConstantTree)
	 [] node then
	    node(token(coord:Coord file:File sem:node sym:node))
	 [] dim then
	    dim(token(coord:Coord file:File sem:dim sym:dim))
	 [] 'attr' then
	    'attr'(token(coord:Coord file:File sem:'attr' sym:'attr'))
	 [] word then
	    word(token(coord:Coord file:File sem:word sym:word))
	 [] tset(Dom) then
	    DomTree = {T2Tree1 Dom}
	 in
	    tset(DomTree)
	 [] ttuple(Doms) then
	    DomTrees = {Map Doms T2Tree1}
	 in
	    ttuple(value(coord:Coord
			 file:File
			 sem:DomTrees))
	 [] tdom(T1) then
	    Tree = {T2Tree1 T1}
	 in
	    tdom(Tree)
	 [] tproj(T1 I) then
	    Tree = {T2Tree1 T1}
	 in
	    tproj(Tree
		  value(coord:Coord
			file:File
			sem:integer(token(coord:Coord file:File sem:I sym:'<int>'))))
	 [] entry(A1 A2) then
	    ConstantTree1 = {A2ConstantTree A1}
	    ConstantTree2 = {A2ConstantTree A2}
	 in
	    tentry(ConstantTree1 ConstantTree2)
	 [] attrs(A1 A2) then
	    ConstantTree1 = {A2ConstantTree A1}
	    ConstantTree2 = {A2ConstantTree A2}
	 in
	    tattrs(ConstantTree1 ConstantTree2)
	 [] eq(Ts) then
	    Trees = {Map Ts T2Tree1}
	 in
	    teq(value(coord:Coord
		      file:File
		      sem:Trees))
	 [] logic then
	    logic(token(coord:Coord file:File sem:logic sym:logic))
	 [] undef then
	    undef(token(coord:Coord file:File sem:undef sym:undef))
	 end
      in
	 value(coord:Coord
	       file:File
	       sem:Sem)
      end
   in
      {T2Tree1 T}
   end
   %%
   fun {Tree2ILV Tree}
      Coord1 = Tree.coord
      Coord = if Coord1==unit then noCoord else Coord1 end
      File1 = Tree.file
      File = if File1==unit then noFile else File1 end
      Sem = Tree.sem
   in   
      case Sem
      of conj(SetgenTree1 SetgenTree2) then
	 SetgenILV1 = {Tree2ILV SetgenTree1}
	 SetgenILV2 = {Tree2ILV SetgenTree2}
      in
	 'elem(tag:conj args:['#SetgenILV1#' '#SetgenILV2#'])'
      [] disj(SetgenTree1 SetgenTree2) then
	 SetgenILV1 = {Tree2ILV SetgenTree1}
	 SetgenILV2 = {Tree2ILV SetgenTree2}
      in
	 'elem(tag:disj args:['#SetgenILV1#' '#SetgenILV2#'])'
      [] constant(Token) then
	 A = {V2A Token.sem}
      in
	 'elem(tag:constant data:'#A#')'
      end
   end
   %%
   %% CanBeDomT: T -> B
   fun {CanBeDomT T}
      case T
      of node then false
      [] tset(_) then false
      [] ttuple(_ _) then false
      [] eq(Ts) then {All Ts CanBeDomT}
      [] logic then false
      else true
      end
   end
   %%
   %% CanBeSetT: T -> B
   fun {CanBeSetT T}
      case T
      of tset(_) then true
      [] entry(_ _) then true
      [] attrs(_ _) then true
      [] eq(Ts) then {All Ts CanBeSetT}
      [] undef then true
      else false
      end
   end
   %% CanBeTupleT: T -> B
   fun {CanBeTupleT T}
      case T
      of ttuple(_) then true
      [] tdom(_) then true
      [] entry(_ _) then true
      [] attrs(_ _) then true
      [] eq(Ts) then {All Ts CanBeTupleT}
      [] undef then true
      else false
      end
   end
end
