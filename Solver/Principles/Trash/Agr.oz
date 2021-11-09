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
		 data: 'principle.agr')
	dimensions: [elem(tag: variable
			  data: 'D')]
	args: [elem(tag: variable
		    data: 'Agr')#
	       elem(tag: 'type.variable'
		    data: 'T')
	       %%
	       elem(tag: variable
		    data: 'Agrs')#
	       elem(tag: 'type.iset'
		    arg: elem(tag: 'type.variable'
			      data: 'T'))]
	defaults: [elem(tag: variable
			data: 'Agr')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'attrs'
			fields: [elem(tag: constant
				      data: 'agr')])
		   %%
		   elem(tag: variable
			data: 'Agrs')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'agrs')])]
	constraints: [elem(tag: constant
			   data: 'Agr')#
		      elem(tag: integer
			   data: 130)])
end
