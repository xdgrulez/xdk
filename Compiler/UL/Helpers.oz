%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   AILTups2A1ILRec

   Token2IL

   CIL2A
   VIL2A
   CUL2CIL
   VUL2VIL
   IUL2IIL

   Xs2X
   A2UL
   A2CUL
   CIL2CUL
   A2VUL
   VIL2VUL
prepare
   RecordForAllInd = Record.forAllInd
   RecordMapInd = Record.mapInd
   RecordFilter = Record.filter
define
   %% AILTups2A1ILRec: AILTups A1CardARec A1AsRec Coord File -> A1ILRec
   %% Converts a list of tuples A#IL into a record A1:IL.
   %%   A is an expanded field, A1 is a unexpanded field (e.g. the
   %% unexpanded field A1 corresponds to the expanded fields constant,
   %% conj, and disj)
   %%   A1CardARec is a cardinality record, mapping unexpanded fields to
   %% a cardinality:
   %% '!': only one tuple labeled by a label in A1AsRec.A can occur in
   %% AILTups; it is collected once.
   %% '?': one or no tuple labeled by a label in A1AsRec.A can occur
   %% in AILTups; it is collected once if present.
   %% '*': zero or more tuples labeled by a label in A1AsRec.A can
   %% occur in AILTups; they are collected in a list.
   %% I: I tuples labeled by a label in A1AsRec.A can occur in
   %% AILTups; they are collected in a list.
   %%   A1AsRec is an expansion record, mapping unexpanded fields to
   %% lists of expanded fields. If A1 is not in the arity of the record,
   %% it is implicitly mapped to the singleton set containing itself.
   %%   Coord is a coordinate, and File a file.
   fun {AILTups2A1ILRec AILTups A1CardARec A1AsRec Coord File}
      %% get list of unexpanded fields (A1s)
      A1s = {Arity A1CardARec}
      %% get list of expanded fields (As)
      As = {FoldL A1s
	    fun {$ AccAs A1}
	       As = {CondSelect A1AsRec A1 [A1]}
	    in
	       {Append AccAs As}
	    end nil}
      %% check AILTups for unwanted features (i.e. not in As)
      for A#_ in AILTups do
	 if {Not {Member A As}} then
	    raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Occurrence of unwanted element/attribute: '#A info:o(AILTups A1CardARec A1AsRec) coord:Coord file:File) end
	 end
      end
      %% calculate inverse expansion record (AA1Rec)
      AA1Dict = {NewDictionary}
      {RecordForAllInd A1AsRec
       proc {$ A1 As}
	  for A in As do
	     if {HasFeature AA1Dict A} then
		A11 = AA1Dict.A
	     in
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Cannot calculate inverse expansion record: Expanded field '#A#' occurs in more than one list of expanded fields ('#A1#', '#A11#')' info:o(AILTups A1CardARec A1AsRec) coord:Coord file:File) end
	     end
	     AA1Dict.A := A1
	  end
       end}
      AA1Rec = {Dictionary.toRecord o AA1Dict}
      %% convert AILTups into A1ILTups
      A1ILTups =
      {Map AILTups
       fun {$ A#IL}
	  A1 = {CondSelect AA1Rec A A}
       in
	  A1#IL
       end}
      %% convert A1ILTups into a record (A1ILsRec)
      A1ILsDict = {NewDictionary}
      for A1#IL in A1ILTups do
	 ILs = {CondSelect A1ILsDict A1 nil}
      in
	 A1ILsDict.A1 := {Append ILs [IL]}
      end
      A1ILsRec = {Dictionary.toRecord o A1ILsDict}
      %% convert A1ILsRec into A1ILRec
      A1ILRec =
      {RecordMapInd A1CardARec
       fun {$ A1 CardA}
	  ILs = {CondSelect A1ILsRec A1 nil}
	  I = {Length ILs}
       in
	  case CardA
	  of '!' then
	     if I==0 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Obligatory element/attribute missing: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	     if I>1 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Obligatory element/attribute occurs more than once: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	  in
	     ILs.1
	  [] '?' then
	     if I>1 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Optional element/attribute occurs more than once: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	  in
	     if I==0 then 'n/a' else ILs.1 end
	  [] '*' then
	     ILs
	  elseif {IsInt CardA} then
	     I1 = CardA
	     if I>I1 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Element/Attribute occurs too often: '#A1#' (occurs '#I#' time(s), must occur at most '#I1#' time(s))' info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	     if I<I1 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Element/Attribute occurs not often enough: '#A1#' (occurs '#I#' time(s), must occur at least '#I1#' time(s))' info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	  in
	     ILs
	  else
	     raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Illegal instruction: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	  end
       end}
      A1ILRec1 = {RecordFilter A1ILRec
		  fun {$ IL} {Not IL=='n/a'} end}
   in
      A1ILRec1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   A2S = Atom.toString
   B2S = ByteString.toString
   S2A = String.toAtom
   %%
   fun {B2A B} {S2A {B2S B}} end
   %%
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into an Oz atom A.
   fun {CIL2A CIL} CIL.data end
   %% VIL2A: VIL -> A
   %% Transforms an IL variable VIL into an Oz atom A.
   fun {VIL2A VIL} VIL.data end
   %% Token2IL: Token -> IL
   %% Transforms a token Token into an IL expression, where:
   %% <id>s are mapped to IL variables if starting with an uppercase character,
   %%       and to IL constants otherwise,
   %% <int>s are mapped to IL integers,
   %% <sstring>s, <dstring>s and <gstring>s are mapped to IL constants.
   fun {Token2IL Token}
      Coord = Token.coord
      File = Token.file
      TokenSem = Token.sem
      TokenSym = Token.sym
      IL =
      case TokenSym
      of '<id>' then
	 S = {A2S TokenSem}
	 C = {CondSelect S 1 ''}
      in
	 if {Char.isUpper C} then
	    elem(tag: variable
		 data: TokenSem)
	 else
	    elem(tag: constant
		 data: TokenSem)
	 end
      [] '<int>' then
	 elem(tag: integer
	      data: TokenSem)
      [] 'infty' then
	 elem(tag: integer
	      data: infty)
      elseif TokenSym=='<sstring>' orelse TokenSym=='<dstring>' orelse TokenSym=='<gstring>' then
	 A = {B2A TokenSem}
      in
	 elem(tag: constant
	      data: A)
      else
	 raise error1('functor':'Compiler/UL/Helpers.ozf' 'proc':'Token2IL' msg:'Sym must be <id>, <int>, <sstring>, <dstring>, or <gstring>.' info:o(TokenSym) coord:Coord file:File) end
      end
      IL1 = {Adjoin IL elem(coord: Coord
			    file: File)}
   in
      IL1
   end
   %% CUL2CIL: CUL -> CIL
   %% Transforms a UL constant CUL into an IL constant CIL.
   fun {CUL2CIL CUL}
      Coord = CUL.coord
      File = CUL.file
      %%
      Sem = CUL.sem
      Token = Sem.1
      CIL = {Token2IL Token}
   in
      if {Not CIL.tag==constant} then
	 raise error1('functor':'Compiler/UL/Helpers.ozf' 'proc':'CUL2CIL' msg:'Constant expected (but found a '#CIL.tag#')' info:o(CUL) coord:Coord file:File) end
      end
      CIL
   end
   %%
   %% VUL2VIL: VUL -> VIL
   %% Transforms a UL variable VUL into an IL variable VIL.
   fun {VUL2VIL VUL}
      Coord = VUL.coord
      File = VUL.file
      %%
      Sem = VUL.sem
      Token = Sem.1
      VIL = {Token2IL Token}
   in
      if {Not VIL.tag==variable} then
	 raise error1('functor':'Compiler/UL/Helpers.ozf' 'proc':'VUL2VIL' msg:'Variable expected (but found a '#VIL.tag#')' info:o(VUL) coord:Coord file:File) end
      end
      VIL
   end
   %%
   %% IUL2IIL: IUL -> IIL
   %% Transforms a UL integer IUL into an IL integer IIL.
   fun {IUL2IIL IUL}
      Coord = IUL.coord
      File = IUL.file
      %%
      Sem = IUL.sem
      Token = Sem.1
      IIL = {Token2IL Token}
   in
      if {Not IIL.tag==integer} then
	 raise error1('functor':'Compiler/UL/Helpers.ozf' 'proc':'IUL2IIL' msg:'Integer expected (but found a '#IIL.tag#')' info:o(IUL) coord:Coord file:File) end
      end
      IIL
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Xs2X: Xs SepA -> X
   %% Folds Xs into X.
   %% SepA is the separator (usually '\n' or ' ').
   fun {Xs2X Xs SepA}
      if Xs==nil then ''
      else
	 X1|Xs1 = Xs
	 X =
	 {FoldL Xs1
	  fun {$ AccX X} AccX#SepA#X end X1}
      in
	 X
      end
   end
   %%
   A2S = Atom.toString
   %%
   fun {A2UL A}
      S = {A2S A}
      %%
      UL =
      if {All S Char.isAlNum} then
	 A
      else
	 '"'#A#'"'
      end
   in
      UL
   end
   %%
   A2CUL = A2UL
   %%
   fun {CIL2CUL CIL}
      A = {CIL2A CIL}
      CUL = {A2CUL A}
   in
      CUL
   end
   %%
   A2VUL = A2UL
   %%
   fun {VIL2VUL VIL}
      A = {VIL2A VIL}
      VUL = {A2VUL A}
   in
      VUL
   end
end
