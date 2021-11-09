%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   Syntax
define
   Syntax =
   o('S': 'GRAMMAR'
     'GRAMMAR': elem(tag: grammar
		     principles: '*'('PRINCIPLEDEF')
		     outputs: '*'('OUTPUTDEF')
		     usedimensions: '*'('CONSTANT')
		     dimensions: '*'('DIMENSION')
		     classes: '*'('CLASSDEF')
		     entries: '*'('ENTRY'))
     
     'PRINCIPLEDEF': elem(tag: principledef
			  id: 'CONSTANT'
			  dimensions: '*'('VARIABLE')
			  args: '*'('VARIABLE'#'TYPE')
			  defaults: '*'('VARIABLE'#'TERM')
			  model: '?'('TYPE')
			  constraints: '*'('CONSTANT'#'INTEGER'))

     'OUTPUTDEF': elem(tag: outputdef
		       id: 'CONSTANT'
		       'functor': 'CONSTANT')
     
     'DIMENSION': elem(tag: dimension
		       id: 'CONSTANT'
		       attrs: '?'('TYPE')
		       entry: '?'('TYPE')
		       label: '?'('TYPE')
		       types: '*'('TYPEDEF')
		       principles: '*'('USEPRINCIPLE')
		       outputs: '*'('OUTPUT')
		       useoutputs: '*'('USEOUTPUT'))

     'OUTPUT': elem(tag: output
		    idref: 'CONSTANT')

     'USEOUTPUT': elem(tag: useoutput
		       idref: 'CONSTANT')

     'TYPEDEF': elem(tag: typedef
		     id: 'CONSTANT'
		     type: 'TYPE')

     'TYPE': disj(elem(tag: 'type.domain'
		       args: '*'('CONSTANT'))
		  elem(tag: 'type.set'
		       arg: 'TYPE')
		  elem(tag: 'type.iset'
		       arg: 'TYPE')
		  elem(tag: 'type.tuple'
		       args: '*'('TYPE'))
		  elem(tag: 'type.list'
		       arg: 'TYPE')
		  elem(tag: 'type.record'
		       args: '*'('CONSTANT'#'TYPE'))
		  elem(tag: 'type.valency'
		       arg: 'TYPE')
		  elem(tag: 'type.card')
		  elem(tag: 'type.vec'
		       arg1: 'TYPE'
		       arg2: 'TYPE')
		  elem(tag: 'type.int')
		  elem(tag: 'type.ints')
		  elem(tag: 'type.string')
		  elem(tag: 'type.bool')
		  elem(tag: 'type.ref'
		       idref: 'CONSTANT')
		  elem(tag: 'type.labelref'
		       arg: 'VARIABLE')
		  elem(tag: 'type.variable'
		       data: 'ATOM'))
     
     'USEPRINCIPLE': elem(tag: useprinciple
			  idref: 'CONSTANT'
			  dimensions: '*'('VARIABLE'#'CONSTANT')
			  args: '*'('VARIABLE'#'TERM'))
     
     'CLASSDEF': elem(tag: classdef
		      id: 'CONSTANT'
		      vars: '*'('VARIABLE')
		      body: 'CLASS')
     
     'CLASS': disj(elem(tag: 'class.dimension'
			idref: 'CONSTANT'
			arg: 'TERM')
		   elem(tag: 'class.ref'
			idref: 'CONSTANT'
			args: '*'('VARIABLE'#'TERM'))
		   elem(tag: conj
			args: '*'('CLASS'))
		   elem(tag: disj
			args: '*'('CLASS')))
     
     'ENTRY': elem(tag: entry
		   body: 'CLASS')
     
     'TERM': disj('CONSTANT'
		  'VARIABLE'
		  'INTEGER'
		  'CARD'
		  'CONSTANT'#'CARD' % for valency sets (do not fall under RECSPEC)
		  'VARIABLE'#'CARD' % for valency sets (do not fall under RECSPEC)
		  elem(tag: top)
		  elem(tag: bot)
		  elem(tag: set
		       args: '*'('TERM'))
		  elem(tag: list
		       args: '*'('TERM'))
		  elem(tag: record
		       args: '*'('RECSPEC'))
		  elem(tag: setgen
		       arg: 'SETGEN')
		  elem(tag: featurepath
		       root: 'ROOT'
		       dimension: 'VARIABLE'
		       aspect: 'ASPECT'
		       fields: '*'('CONSTANT'))
		  elem(tag: annotation
		       arg1: 'TERM'
		       arg2: 'TYPE')
		  elem(tag: conj
		       args: '*'('TERM'))
		  elem(tag: disj
		       args: '*'('TERM'))
		  elem(tag: concat
		       args: '*'('TERM'))
		  elem(tag: order
		       args: '*'('TERM'))
		  elem(tag: bounds
		       arg1: 'TERM'
		       arg2: 'TERM'))
     
     'CONSTANT': elem(tag: constant
		      data: 'ATOM')

     'VARIABLE': elem(tag: variable
		      data: 'ATOM')     

     'INTEGER': disj(elem(tag: integer
			  data: 'INT')
		     elem(tag: integer
			  data: 'infty'))
          
     'CARD': disj(elem(tag: 'card.wild'
		       arg: 'WILD')
		  elem(tag: 'card.set'
		       args: '*'('INTEGER'))
		  elem(tag: 'card.interval'
		       arg1: 'INTEGER'
		       arg2: 'INTEGER'))

     'WILD': disj('!' '?' '*' '+')

     'RECSPEC': disj('CONSTANT'#'TERM'
		     'VARIABLE'#'TERM'
		     elem(tag: conj
			  args: '*'('RECSPEC'))
		     elem(tag: disj
			  args: '*'('RECSPEC')))

     'SETGEN': disj('CONSTANT'
		    elem(tag: conj
			 args: '*'('SETGEN'))
		    elem(tag: disj
			 args: '*'('SETGEN')))

     'ROOT': disj('_' '^')
     'ASPECT': disj('entry' 'attrs')
    )
end
