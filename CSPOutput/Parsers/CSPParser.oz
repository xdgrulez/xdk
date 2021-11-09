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
   {System.show 'generating CSP parser'}
   %%
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<int>' '<sstring>'
		'{' '}' '[' ']' '(' ')' '#'
	       ]
      start  : 'Line'
      rules  :
	 [
	  rule(head:'Line' body:['Term' '#' 'Term' '#' 'Term']
	       action:line(1 3 5))
	  %%
	  rule(head:'Term' body:['Atom']
	       action:1)
	  rule(head:'Term' body:['Int']
	       action:1)
	  rule(head:'Term' body:['Set']
	       action:1)
	  rule(head:'Term' body:['List']
	       action:1)
	  rule(head:'Term' body:['Kinded']
	       action:1)
	  %%
	  rule(head:'Atom' body:['<id>']
	       action:atom(1))
	  rule(head:'Atom' body:['<sstring>']
	       action:atom(1))
	  %%
	  rule(head:'Int' body:['<int>']
	       action:int(1))
	  %%
	  rule(head:'Spec' body:['Int']
	       action:1)
	  rule(head:'Spec' body:['Int' '#' 'Int']
	       action:spec(1 3))
	  %%
	  rule(head:'Set' body:['{' '*'('Spec') '}' '#' 'Int']
	       action:set(2 5))
	  %%
	  rule(head:'List' body:['[' '*'('Term') ']']
	       action:list(2))
	  %%
	  rule(head:'Kinded' body:['Atom' '(' 'Atom' ')' '#' 'Term']
	       action:kinded(1 3 6))
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   %%
   {System.show 'generating CSP parser done'}
define
   V2A = VirtualString.toAtom
   %%
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 [
	  "{" "}" "[" "]" "(" ")" "#"
	 ]
      eolComments:
	 nil
      balancedComments:
	 nil
      includes:
	 nil
      keywords:
	 nil
     )}
   %%
   fun {Parsed2Tup Parsed}
      case Parsed.sem
      of line(Term1 Term2 Term3 ...) then
	 {Parsed2Tup Term1}#{Parsed2Tup Term2}#{Parsed2Tup Term3}
      [] atom(token(sem:V ...)) then
	 if V==nil then
	    nil
	 else
	    {V2A V}
	 end
      [] int(token(sem:I ...)) then
	 I
      [] spec(Int1 Int2 ...) then
	 {Parsed2Tup Int1}#{Parsed2Tup Int2}
      [] set(Spec Int ...) then
	 {Map Spec.sem Parsed2Tup}#{Parsed2Tup Int}
      [] list(Term ...) then
	 {Map Term.sem Parsed2Tup}
      [] kinded(Atom1 Atom2 Term ...) then
	 A = {Parsed2Tup Atom1}
      in
	 A({Parsed2Tup Atom2})#{Parsed2Tup Term}
      end
   end
   %%
   fun {Parse S}
      Tokenized = {Tokenizer.fromString S}
      Parsed = {Parser Tokenized}
      Tup = {Parsed2Tup Parsed}
   in
      Tup
   end
end
