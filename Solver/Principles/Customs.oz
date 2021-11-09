%% Copyright 2004-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University)
%%    Ondrej Bojar <obo@cuni.cz>
%%
functor
export
   Principle
define
   Principle =
   elem(tag: principledef
        id: elem(tag: constant
                 data: 'principle.customs')
        dimensions: [elem(tag: variable
                          data: 'D')]
        args: [elem(tag: variable
                    data: 'Customs')#
               elem(tag: 'type.iset' % the set of labels
                    arg: elem(tag: 'type.labelref'
                              arg: elem(tag: variable
                                                   data: 'D')))]
        defaults: [elem(tag: variable
                        data: 'Customs')#
                   elem(tag: featurepath
                        root: '_'
                        dimension: elem(tag: variable
                                        data: 'D')
                        aspect: 'entry'
                        fields: [elem(tag: constant
                                      data: 'customs')])]
        constraints: [elem(tag: constant
                           data: 'Customs')#
                      elem(tag: integer
                           data: 130)])
end
