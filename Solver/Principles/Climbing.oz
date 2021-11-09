%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   Principle
define
   Principle =
   elem(tag: principledef
	id: elem(tag: constant
		 data: 'principle.climbing')
	args: [elem(tag: variable
		    data: 'Subgraphs')#
	       elem(tag: 'type.bool')
	       %%
	       elem(tag: variable
		    data: 'MotherCards')#
	       elem(tag: 'type.bool')]
	defaults: [elem(tag: variable
			data: 'Subgraphs')#
		   elem(tag: constant
			data: 'true')
		   %%
		   elem(tag: variable
			data: 'MotherCards')#
		   elem(tag: constant
			data: 'true')]
	dimensions: [elem(tag: variable
			  data: 'D1')
		     elem(tag: variable
			  data: 'D2')]
	constraints: [elem(tag: constant
			   data: 'Climbing')#
		      elem(tag: integer
			   data: 110)])
end
