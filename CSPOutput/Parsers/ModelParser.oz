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
   {System.show 'generating model parser'}
   %%
   GrammarRec =
   grammar(
      tokens : [
		'<id>' '<int>' '<sstring>'
		'[' ']' '#'
	       ]
      start  : 'Line'
      rules  :
	 [
	  rule(head:'Line' body:['[' '*'('Term') ']']
	       action:line(2))
	  %%
	  rule(head:'Term' body:['Atom']
	       action:1)
	  rule(head:'Term' body:['Int']
	       action:1)
	  rule(head:'Term' body:['Pair']
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
	  rule(head:'Pair' body:['Atom' '#' 'Term']
	       action:pair(1 3))
	 ])
   Parser = {LALRGen.makeLALR GrammarRec}
   %%
   {System.show 'generating model parser done'}
define
   V2A = VirtualString.toAtom
   %%
   Tokenizer =
   {TokenizerGen.newTokenizer
    o(operators:
	 [
	  "[" "]" "#"
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
   fun {Parsed2Xs Parsed}
      case Parsed.sem
      of line(Term ...) then
	 {Map Term.sem Parsed2Xs}
      [] atom(token(sem:V ...)) then
	 if V==nil then
	    nil
	 else
	    {V2A V}
	 end
      [] int(token(sem:I ...)) then
	 I
      [] pair(Atom Term ...) then
	 {Parsed2Xs Atom}#{Parsed2Xs Term}
      end
   end
   %%
   fun {Parse S}
      Tokenized = {Tokenizer.fromString S}
      Parsed = {Parser Tokenized}
      Xs = {Parsed2Xs Parsed}
   in
      Xs
   end
end
