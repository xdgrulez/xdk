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
		 data: 'principle.agreementSubset')
	dimensions: [elem(tag: variable
			  data: 'D')]
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
					data: 'D')))]
	defaults: [elem(tag: variable
			data: 'Agr1')#
		   elem(tag: featurepath
			root: '^'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'attrs'
			fields: [elem(tag: constant
				      data: 'agr')])
		   %%
		   elem(tag: variable
			data: 'Agr2')#
		   elem(tag: featurepath
			root: '_'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'attrs'
			fields: [elem(tag: constant
				      data: 'agr')])
		   %%
		   elem(tag: variable
			data: 'Agree')#
		   elem(tag: featurepath
			root: '^'
			dimension: elem(tag: variable
					data: 'D')
			aspect: 'entry'
			fields: [elem(tag: constant
				      data: 'agree')])]
	constraints: [elem(tag: constant
			   data: 'AgreementSubset')#
		      elem(tag: integer
			   data: 100)])
end
