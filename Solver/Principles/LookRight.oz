%% Copyright 2004-2011
%% by Ondrej Bojar <obo@cuni.cz>
%%
functor
export
   Principle
define
   Principle =
   elem(tag: principledef
        id: elem(tag: constant
                 data: 'principle.lookright')
        dimensions: [elem(tag: variable
                          data: 'D')]
        args: [elem(tag: variable
                    data: 'LookRight')#
               elem(tag: 'type.vec'
                    arg1: elem(tag: 'type.ref'
			       idref: elem(tag: constant
                                      data: 'id.agrreq'))
                    arg2: elem(tag: 'type.iset' % the set of labels
                               arg: elem(tag: 'type.labelref'
                                         arg: elem(tag: variable
                                                   data: 'D'))))]
        defaults: [elem(tag: variable
                        data: 'LookRight')#
                   elem(tag: featurepath
                        root: '_'
                        dimension: elem(tag: variable
                                        data: 'D')
                        aspect: 'entry'
                        fields: [elem(tag: constant
                                      data: 'lookright')])]
        constraints: [elem(tag: constant
                           data: 'LookRight')#
                      elem(tag: integer
                           data: 130)])
end
