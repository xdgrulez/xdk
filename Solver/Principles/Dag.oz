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
		 data: 'principle.dag')
	dimensions: [elem(tag: variable
			  data: 'D')]
	args: [
	       elem(tag: variable
		    data: 'Connected')#
	       elem(tag: 'type.bool')
	       %%
	       elem(tag: variable
		    data: 'DisjointDaughters')#
	       elem(tag: 'type.bool')

	      ]
	defaults: [
		   elem(tag: variable
			data: 'Connected')#
		   elem(tag: constant
			data: 'false')
		   %%
		   elem(tag: variable
			data: 'DisjointDaughters')#
		   elem(tag: constant
			data: 'false')
		  ]
	constraints: [elem(tag: constant
			   data: 'Dag')#
		      elem(tag: integer
			   data: 130)])
end
