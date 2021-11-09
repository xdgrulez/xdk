functor
export
   Principle
define
   Principle =
   elem(tag: principledef
	id: elem(tag: constant
		 data: 'principle.tag')
	dimensions:
	   [elem(tag: variable
		 data: 'D')]
	args:
	   [elem(tag: variable
		 data: 'Anchor')#
	    elem(tag: 'type.iset'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))
	    %%
	    elem(tag: variable
		 data: 'Dominates')#
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
		 data: 'Foot')#
	    elem(tag: 'type.set'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))
	    %%
	    elem(tag: variable
		 data: 'Leaves')#
	    elem(tag: 'type.set'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))
	    %%
	    elem(tag: variable
		 data: 'Order')#
	    elem(tag: 'type.list'
		 arg: elem(tag: 'type.labelref'
			   arg: elem(tag: variable
				     data: 'D')))]
	defaults:
	   [elem(tag: variable
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
		 data: 'Dominates')#
	    elem(tag: featurepath
		 root: '_'
		 dimension: elem(tag: variable
				 data: 'D')
		 aspect: 'entry'
		 fields: [elem(tag: constant
			       data: 'dominates')])
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
	    %%
	    elem(tag: variable
		 data: 'Leaves')#
	    elem(tag: featurepath
		 root: '_'
		 dimension: elem(tag: variable
				 data: 'D')
		 aspect: 'entry'
		 fields: [elem(tag: constant
			       data: 'leaves')])
	    %%
	    elem(tag: variable
		 data: 'Order')#
	    elem(tag: list
		 args: nil)]
	model:
	   elem(tag: 'type.record'
		args:
		   [elem(tag: constant
			 data: 'anchorsL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'belowL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
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
			 data: 'pastedL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
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
			 data: 'leaveYieldL')#
		    elem(tag: 'type.vec'
			 arg1: elem(tag: 'type.labelref'
				    arg: elem(tag: variable
					      data: 'D'))
			 arg2: elem(tag: 'type.ints'))
		    %%
		    elem(tag: constant
			 data: 'yield')#
		    elem(tag: 'type.ints')])
	constraints:
	   [elem(tag: constant
		 data: 'TAGMakeNodes')#
	    elem(tag: integer
		 data: 130)
	    %%
	    elem(tag: constant
		 data: 'TAGConditions')#
	    elem(tag: integer
		 data: 120)
	    %%
	    elem(tag: constant
		 data: 'TAGDist')#
	    elem(tag: integer
		 data: 90)])
end
