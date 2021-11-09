%%
%% Authors:
%%   Ralph Debusmann <rade@ps.uni-sb.de>
%%   Denys Duchier <duchier@ps.uni-sb.de>
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Ralph Debusmann, 2001-2011
%%   Denys Duchier, 2001-2011
%%   Marco Kuhlmann, 2003-2011
%%

functor
export
   Principle
define
   Principle =
   elem(tag: principledef
	id: elem(tag: constant
		 data: 'principle.orderWithCuts')
	dimensions:
	   [elem(tag: variable
		 data: 'D')]
	args:
	   [elem(tag: variable
		 data: 'On')#
	    elem(tag: 'type.iset'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))
	    %%
	    elem(tag: variable
		 data: 'Order')#
	    elem(tag: 'type.list'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))
	    %%
	    elem(tag: variable
		 data: 'Cut')#
	    elem(tag: 'type.vec'
		 arg1: elem(tag: 'type.labelref'
			    arg: elem(tag: variable
				      data: 'D'))
		 arg2: elem(tag: 'type.set'
			    arg: elem(tag: 'type.labelref'
				      arg: elem(tag: variable
						data: 'D'))))
	    %%
	    elem(tag: variable
		 data: 'Paste')#
	    elem(tag: 'type.set'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))]
	defaults:
	   [elem(tag: variable
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
		 data: 'Cut')#
	    elem(tag: featurepath
		 root: '_'
		 dimension: elem(tag: variable
				 data: 'D')
		 aspect: 'entry'
		 fields: [elem(tag: constant
			       data: 'cut')])
	    %%
	    elem(tag: variable
		 data: 'Paste')#
	    elem(tag: featurepath
		 root: '_'
		 dimension: elem(tag: variable
				 data: 'D')
		 aspect: 'entry'
		 fields: [elem(tag: constant
			       data: 'paste')])]
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
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'pasteByL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'paste')#
		    elem(tag: 'type.ints')
		    %%
		    elem(tag: constant
			 data: 'pasteL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'takeProjL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'giveProjL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'keepProjL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))])
	constraints:
	   [
	    elem(tag: constant
		 data: 'OrderWithCutsMakeNodes')#
	    elem(tag: integer
		 data: 130)
	    %%
	    elem(tag: constant
		 data: 'OrderWithCutsConditions')#
	    elem(tag: integer
		 data: 120)
	    %%
	    elem(tag: constant
		 data: 'OrderWithCutsDist')#
	    elem(tag: integer
		 data: 90)
	   ])
end
