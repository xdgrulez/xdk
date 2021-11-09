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
		 data: 'principle.barriers.attrib')
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
		    arg: elem(tag: 'type.variable'
			      data: 'T'))
	       elem(tag: variable
		    data: 'Attrib')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.variable'
			      data: 'T'))]
	constraints: [elem(tag: constant
			   data: 'BarriersAttrib')#
		      elem(tag: integer
			   data: 110)])
end
