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
		 data: 'principle.xTAGRedundant')
	dimensions: [
		     elem(tag: variable
			  data: 'D1')
		     elem(tag: variable
			  data: 'D2')
		    ]
	args: [
	       elem(tag: variable
		    data: 'Anchor')#
	       elem(tag: 'type.labelref'
		    arg: elem(tag: variable
			      data: 'D2'))
	       %%
	       elem(tag: variable
		    data: 'Foot')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D2')))
	      ]
	defaults: [
		   elem(tag: variable
			data: 'Anchor')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D2')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'anchor')])
		   %%
		   elem(tag: variable
			data: 'Foot')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D2')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'foot')])
		  ]
	constraints: [
		      elem(tag: constant
			   data: 'XTAGRedundant')#
		      elem(tag: integer
			   data: 120)
		     ]
       )
end
