%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
%import
%   System(show)
export
   CIL2A
   VIL2A
   CIL2VIL
   CIL2IIL
   
   AILTups2A1ILRec

   Normalize
   Segment
   EscapeSyntaxMarkers
   
   Xs2X
prepare
   RecordForAllInd = Record.forAllInd
   RecordMapInd = Record.mapInd
   RecordFilter = Record.filter
define
   S2A = String.toAtom
   V2S = VirtualString.toString
   %%
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into an Oz atom A.
   fun {CIL2A CIL} CIL.data end
   %% VIL2A: VIL -> A
   %% Transforms an IL variable VIL into an Oz atom A.
   fun {VIL2A VIL} VIL.data end
   %%
   %% CIL2VIL: CIL -> VIL
   %% Converts an IL constant CIL into an IL variable VIL
   fun {CIL2VIL CIL}
      {Adjoin CIL elem(tag: variable)}
   end
   %% 
   S2I = String.toInt
   %%
   A2S = Atom.toString
   %%
   fun {A2I A} {S2I {A2S A}} end
   %%
   %% CIL2IIL: CIL -> IIL
   %% Converts an IL constant CIL into an IL integer IIL
   fun {CIL2IIL CIL}
      A = CIL.data
      I = if A==infty then A else {A2I A} end
      IIL = {Adjoin CIL elem(tag: integer
			     data: I)}
   in
      IIL
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
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
	  [] '2' then
	     if I==0 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Obligatory (two elements/attributes required) element/attribute missing: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	     if I>2 then
		raise error1('functor':'Compiler/XML/Helpers.ozf' 'proc':'AILTups2A1ILRec' msg:'Obligatory element/attribute (two elements/attributes required) occurs more than twice: '#A1 info:o(AILTups A1CardARec A1ILsRec) coord:Coord file:File) end
	     end
	  in
	     ILs
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
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Normalize: S -> S
   %% Removes superfluous spaces.
   fun {Normalize S}
      case S
      of nil then nil
      [] & |& |S1 then {Normalize & |S1}         %% 2 spaces -> 1 space
      []    Ch|S1 then Ch|{Normalize S1}         %% recurse
      end
   end
   %% Segment: S -> As
   %% Breaks up a string into a list of atoms.
   fun {Segment S}
      %% normalize
      S1 = {Normalize S}
      %% remove leading space if there is any
      S2 = case S1 
	   of & |S3 then S3
	   else S1
	   end
      %% tokenize into strings separated by spaces
      Ss = {String.tokens S2 & }
      As = {Map Ss S2A}
   in
      As
   end
   %% EscapeSyntaxMarkers: V -> S
   %% Escapes XML syntax markers (at least <, > and &).
   fun {EscapeSyntaxMarkers V}
      S = {V2S V}
   in
      for Ch in S append:Append do
	 S1 =
	 case Ch
	 of &< then "&lt;"
	 [] &> then "&gt;"
	 [] && then "&amp;"
	 else [Ch]
	 end
      in
	 {Append S1}
      end
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
end
