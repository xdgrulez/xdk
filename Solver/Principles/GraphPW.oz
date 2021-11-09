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
		 data: 'principle.graphPW')
	dimensions: [elem(tag: variable
			  data: 'D')]
	model:
	   elem(tag: 'type.record'
		args:
		   [
		    elem(tag: constant
			 data: 'mothers')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'mothersL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'up')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'upL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'upEndL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'equp')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'eq')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'daughters')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'daughtersL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'down')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'downL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'eqdown')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'labels')#
		    elem(tag: 'type.set'
			 arg: elem(tag: 'type.labelref'
				   arg: elem(tag: variable
					     data: 'D')))
		   ])
	constraints: [elem(tag: constant
			   data: 'GraphPWConstraints')#
		      elem(tag: integer
			   data: 130)
		      %%
		      elem(tag: constant
			   data: 'GraphPWDist')#
		      elem(tag: integer
			   data: 90)
		     ]
       )
end
