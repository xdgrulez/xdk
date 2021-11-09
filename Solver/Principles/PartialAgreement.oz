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
		 data: 'principle.partialAgreement')
	dimensions: [elem(tag: variable
			  data: 'D1')
		     elem(tag: variable
			  data: 'D2')
		     elem(tag: variable
			  data: 'D3')
		    ]
	args: [elem(tag: variable
		    data: 'Agr1')#
	       elem(tag: 'type.variable'
		    data: 'T')
	       %%
	       elem(tag: variable
		    data: 'Agr2')#
	       elem(tag: 'type.variable'
		    data: 'T')
	       %%
	       elem(tag: variable
		    data: 'Agree')#
 	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D1')))
	       %%
	       elem(tag: variable
		    data: 'Projs')#
	       elem(tag: 'type.ints')]
	defaults: [elem(tag: variable
			data: 'Agr1')#
		   elem(tag: featurepath
			root: '^'
			dimension: elem(tag: variable
					data: 'D2')
			aspect: 'attrs'
			fields: [elem(tag: constant
				      data: 'agr')])
		   %%
		   elem(tag: variable
			data: 'Agr2')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D2')
			aspect: 'attrs'
			fields: [elem(tag: constant
				      data: 'agr')])
		   %%
		   elem(tag: variable
			data: 'Agree')#
		   elem(tag: featurepath
			root: '^'
			dimension: elem(tag: variable
					data: 'D3')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'agree')])
		   %%
		   elem(tag: variable
			data: 'Projs')#
		   elem(tag: set
			args: nil)]
	constraints: [elem(tag: constant
			   data: 'PartialAgreement')#
		      elem(tag: integer
			   data: 100)])
end
