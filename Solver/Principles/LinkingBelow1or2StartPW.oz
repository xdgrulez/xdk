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
		 data: 'principle.linkingBelow1or2StartPW')
        dimensions: [elem(tag: variable
                          data: 'D1')
                     elem(tag: variable
                          data: 'D2')
                     elem(tag: variable
                          data: 'D3')
                    ]
        constraints: [elem(tag: constant
                           data: 'LinkingBelow1or2StartPW')#
                      elem(tag: integer
                           data: 140)
                     ])
end
