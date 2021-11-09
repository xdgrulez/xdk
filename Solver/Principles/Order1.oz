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
		 data: 'principle.order1')
	dimensions: [elem(tag: variable
			  data: 'D')]
	args: [elem(tag: variable
		    data: 'On')#
	       elem(tag: 'type.iset'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D')))
	       %%
	       elem(tag: variable
		    data: 'Order')#
	       elem(tag: 'type.list'
		    arg: elem(tag: 'type.set'
			      arg: elem(tag: 'type.labelref'
					arg: elem(tag: variable
						  data: 'D'))))
	       %%
	       elem(tag: variable
		    data: 'Yields')#
	       elem(tag: 'type.bool')]
	defaults: [elem(tag: variable
			data: 'On')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'on')])
		   %%
		   elem(tag: variable
			data: 'Order')#
		   elem(tag: list
			args: nil)
		   %%
		   elem(tag: variable
			data: 'Yields')#
		   elem(tag: constant
			data: 'false')]
	model:
	   elem(tag: 'type.record'
		args:
		   [elem(tag: constant
			 data: 'selfSet')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'self')#
		    elem(tag: 'type.labelref'
			 arg: elem(tag: variable
				   data: 'D'))
		    %%
		    elem(tag: constant
			 data: 'yield')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'yieldS')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'yieldL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))])
	constraints: [elem(tag: constant
			   data: 'OrderMakeNodes')#
		      elem(tag: integer
			   data: 130)
		      %%
		      elem(tag: constant
			   data: 'Order1Conditions')#
		      elem(tag: integer
			   data: 120)
		      %%
		      elem(tag: constant
			   data: 'OrderDist')#
		      elem(tag: integer
			   data: 90)
		     ])
end
