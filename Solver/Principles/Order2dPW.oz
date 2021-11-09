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
		 data: 'principle.order2dPW')
        dimensions: [elem(tag: variable
                          data: 'D')
                     elem(tag: variable
                          data: 'ORD')
                    ]
        constraints: [elem(tag: constant
                           data: 'Order2dPW')#
                      elem(tag: integer
                           data: 140)
                     ])
end
