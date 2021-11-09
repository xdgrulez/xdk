%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   TokenizerGen(newTokenizer) at 'TokenizerGen.ozf'
export
   Parse
require
   LALRGen(makeLALR) at 'LALRGen.ozf'
   System(show)
prepare
   {System.show 'generating solution parser'}
   %%
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<int>' '<sstring>'
		'[' ']' '#' '(' ')' 'nil'
	       ]
      start  : 'Line'
      rules  :
	 [
	  rule(head:'Line' body:['FD']
	       action:1)
	  rule(head:'Line' body:['FS']
	       action:1)
	  %%
	  rule(head:'FD' body:['Int' '#' 'Atom' '#' 'Spec']
	       action:line(1 3 5))
	  rule(head:'FS' body:['Int' '#' 'Atom' '#' 'Spec' '#' 'Spec' '#' 'Spec']
	       action:line(1 3 5 7 9))
	  rule(head:'FS' body:['Int' '#' 'Atom' '#' 'Spec' '#' 'Spec' '#' 'Spec1']
	       action:line(1 3 5 7 9))
	  %%
	  rule(head:'Atom' body:['<id>']
	       action:atom(1))
	  rule(head:'Atom' body:['<sstring>']
	       action:atom(1))
	  %%
	  rule(head:'Int' body:['<int>']
	       action:int(1))
	  %%
	  rule(head:'Spec' body:['[' '*'('Spec1') ']']
	       action:spec(2))
	  rule(head:'Spec' body:['nil']
	       action:spec(1))
	  %%
	  rule(head:'Spec1' body:['Int']
	       action:1)
	  rule(head:'Spec1' body:['Int' '#' 'Int']
	       action:spec1(1 3))
	  rule(head:'Spec1' body:['(' 'Spec1' ')']
	       action:2)
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   %%
   {System.show 'generating solution parser done'}
define
   V2A = VirtualString.toAtom
   %%
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 [
	  "[" "]" "(" ")" "#"
	 ]
      eolComments:
	 nil
      balancedComments:
	 nil
      includes:
	 nil
      keywords:
	 [
	  "nil"
	 ]
     )}
   %%
   fun {Parsed2X Parsed}
      case Parsed.sem
      of line(Int Atom Spec1 Spec2 Spec3 ...) then
	 {Parsed2X Int}#{Parsed2X Atom}#{Parsed2X Spec1}#{Parsed2X Spec2}#{Parsed2X Spec3}
      [] line(Int Atom Spec ...) then
	 {Parsed2X Int}#{Parsed2X Atom}#{Parsed2X Spec}
      [] atom(token(sem:V ...)) then
	 if V==nil then
	    nil
	 else
	    {V2A V}
	 end
      [] int(token(sem:I ...)) then
	 I
      [] spec(Spec ...) then
	 {Map Spec.sem Parsed2X}
      [] spec1(Int1 Int2 ...) then
	 {Parsed2X Int1}#{Parsed2X Int2}
      end
   end
   %%
   fun {Parse S}
      Tokenized = {Tokenizer.fromString S}
      Parsed = {Parser Tokenized}
      X = {Parsed2X Parsed}
   in
      X
   end
end
