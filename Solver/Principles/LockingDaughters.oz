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
		 data: 'principle.lockingDaughters')
	dimensions: [elem(tag: variable
			  data: 'D1')
		     elem(tag: variable
			  data: 'D2')
		     elem(tag: variable
			  data: 'D3')
		    ]
	args: [
	       elem(tag: variable
		    data: 'LockDaughters')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D1')))
	       %%
	       elem(tag: variable
		    data: 'ExceptAbove')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D1')))
	       %%
	       elem(tag: variable
		    data: 'Key')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D2')))
	      ]
	defaults: [
		   elem(tag: variable
			data: 'LockDaughters')#
		   elem(tag: set
			args: nil)
		   %%
		   elem(tag: variable
			data: 'ExceptAbove')#
		   elem(tag: set
			args: nil)
		   %%
		   elem(tag: variable
			data: 'Key')#
		   elem(tag: set
			args: nil)
		  ]
	constraints: [elem(tag: constant
			   data: 'LockingDaughters')#
		      elem(tag: integer
			   data: 110)])
end
