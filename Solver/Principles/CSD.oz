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
		 data: 'principle.csd')
	dimensions: [elem(tag: variable
			  data: 'D')]
	args: [elem(tag: variable
		    data: 'NounLabels')#
	       elem(tag: 'type.set'
		    arg: elem(tag: 'type.labelref'
			      arg: elem(tag: variable
					data: 'D')))]
	defaults: [elem(tag: variable
			data: 'NounLabels')#
		   elem(tag: set
			args: nil)]
	constraints: [elem(tag: constant
			   data: 'CSD')#
		      elem(tag: integer
			   data: 110)])
end
