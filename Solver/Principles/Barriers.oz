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
		 data: 'principle.barriers')
	dimensions: [elem(tag: variable
			  data: 'D1')
		     elem(tag: variable
			  data: 'D2')
		     elem(tag: variable
			  data: 'D3')
		    ]
	args: [elem(tag: variable
		    data: 'Blocks')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D2')))]
	defaults: [elem(tag: variable
			data: 'Blocks')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D3')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'blocks')])]
	constraints: [elem(tag: constant
			   data: 'Barriers')#
		      elem(tag: integer
			   data: 110)])
end
