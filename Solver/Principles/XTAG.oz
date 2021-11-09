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
		 data: 'principle.xTAG')
	dimensions: [
		     elem(tag: variable
			  data: 'D')
		    ]
	args: [
	       elem(tag: variable
		    data: 'Anchor')#
	       elem(tag: 'type.labelref'
		    arg: elem(tag: variable
			      data: 'D'))
	       %%
	       elem(tag: variable
		    data: 'Foot')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D')))
	      ]
	defaults: [
		   elem(tag: variable
			data: 'Anchor')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'anchor')])
		   %%
		   elem(tag: variable
			data: 'Foot')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'foot')])
		  ]
	model:
	   elem(tag: 'type.record'
		args:
		   [
		    elem(tag: constant
			 data: 'cover')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'coverL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'foot')#
		    elem(tag: 'type.ints')
		   ]
	       )
	constraints: [
		      elem(tag: constant
			   data: 'XTAG')#
		      elem(tag: integer
			   data: 120)
		     ]
       )
end
