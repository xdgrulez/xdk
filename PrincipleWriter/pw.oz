%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Inspector(inspect configure)
   Application(getArgs exit)
   Property(get put)
   System(showError printInfo showInfo show)

   Helpers(putV vs2V e2V) at 'Helpers.ozf'

   Parser(parseUrl) at 'Parser.ozf'
   Typer(type) at 'Typer.ozf'
   Evaluator(evaluate) at 'Evaluator.ozf'
   QuadOptimizer(optimize options help) at 'QuadOptimizer/QuadOptimizer.ozf'
prepare
   ListMapInd = List.mapInd
   ListToTuple = List.toTuple
define
   {Inspector.configure widgetTreeFont font(family:courier size:10 weight:normal)}
   {Inspector.configure widgetShowStrings false}
   {Inspector.configure widgetTreeWidth 100}
   {Inspector.configure widgetTreeDepth 100}
   %%
   {Property.put 'errors.depth' 10000}
   {Property.put 'errors.width' 10000}
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%
   A2S = Atom.toString
   S2A = String.toAtom
   %%
   MainOptDefs =
   [
    help(single type:bool char:&h default:false)
    principle(single type:string char:&p default:"")
    definition(single type:string char:&e default:"")
    constraint(single type:string char:&c default:"")
    optimize(single type:bool char:&o default:true)
    debug(single type:bool char:&d default:false)
   ]
   AArgRec =
   {Application.getArgs
    {ListToTuple record {Append QuadOptimizer.options MainOptDefs}}}
   %%
   if AArgRec.help then
      {System.showError
       '*XDG Development Kit (XDK): Principle Writer*\n\n'#
       '--(no)help           display this help\n'#
       ' -h\n'#
       '--principle File     input principle definition file\n'#
       ' -p                  (e.g. -p tree.ul\n'#
       '                      default: "")\n'#
       '--definition File    output principle definition functor\n'#
       ' -e                  (e.g. -e Tree_definition.oz\n'#
       '                      default: "../Solver/Principles/Tree.oz"\n'#
       '                      for principle name = "principle.tree")\n'#
       '                                                      ^^^^\n'#
       '--constraint File    output principle constraint functor\n'#
       ' -c                  (e.g. -c Tree_constraint.oz\n'#
       '                      default: "../Solver/Principles/Lib/Tree.oz"\n'#
       '                      for principle name = "principle.tree")\n'#
       '                                                      ^^^^\n'#
       '--(no)optimize       toggle optimization\n'#
       ' -o                  (default: optimize)'}
      {QuadOptimizer.help}
      {System.showError
       '--(no)debug           toggle debug mode\n'#
       ' -d                   (default: nodebug)'}
      {Application.exit 0}
   end
   %% principle
   PrincipleS = AArgRec.principle
   if PrincipleS=="" then
      {System.showError 'No principle definition file.'}
      {Application.exit 1}
   end
   %% definition
   DefinitionS = AArgRec.definition
   %% constraint
   ConstraintS = AArgRec.constraint
   %% optimize
   OptimizeB = AArgRec.optimize
   %% debug
   DebugB = AArgRec.debug
   %%
   try
      I1 = {Property.get 'time.total'}
      %%
      {System.printInfo PrincipleS#': '}
      %%
      {System.printInfo 'parsing...'}
      Tree = {Parser.parseUrl PrincipleS}
      %%
      {System.printInfo 'typing...'}
      Tree1 = {Typer.type Tree}
      %%
      DefPrinciples#TALatVTups =
      if OptimizeB then
	 %% After optimization error messages may get confusing so
	 %% it's worth it to have a first evaluation pass:
	 {System.printInfo 'evaluating pass 1...'}
	 _ = {Evaluator.evaluate Tree1 AArgRec}
	 %%
	 {System.showInfo 'optimizing...'}
	 Tree2 = {QuadOptimizer.optimize Tree1 AArgRec}
	 %%
	 {System.printInfo 'evaluating pass 2...'}
      in
	 {Evaluator.evaluate Tree2 AArgRec}
      else
	 {System.printInfo 'evaluating...'}
	 {Evaluator.evaluate Tree1 AArgRec}
      end
      %%
      I2 = {Property.get 'time.total'}
      {System.showInfo 'done. ('#I2-I1#'ms)'}
      %%
      HeaderV =
      '%% Copyright 2001-2011\n'#
      '%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and\n'#
      '%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and\n'#
      '%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and\n'#
      '%%    Jochen Setz <info@jochensetz.de> (Saarland University)\n'#
      '%%\n'#
      'functor\n'#
      'import\n'#
      '%   System(show)\n'#
      'export\n'#
      '   Constraint\n'#
      'define\n'#
      '   proc {Constraint NodeRecs G Principle FD FS Select PW ByNeed}\n'#
      {FoldL TALatVTups
       fun {$ AccV TA#LatV}
	  AccV#'      '#LatV#' = '#'{PW.t2Lat '#TA#' NodeRecs G Principle}\n'
       end ''}#
      if TALatVTups==nil then '' else '   in\n' end
      FooterV = '   end\n'#
      'end\n'
   in
      for NameA#DVAs#ConstraintsV in DefPrinciples do
	 NameSs = {String.tokens {A2S NameA} &.}
	 NameCh|NameS = {Nth NameSs 2}
	 NameS1 = {Char.toUpper NameCh}|NameS
	 NameA1 = {S2A NameS1}
	 %%
	 PrincipleDefV =
	 '%% Copyright 2001-2011\n'#
	 '%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and\n'#
	 '%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and\n'#
	 '%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and\n'#
	 '%%    Jochen Setz <info@jochensetz.de> (Saarland University)\n'#
	 '%%\n'#
	 'functor\n'#
	 'export\n'#
	 '   Principle\n'#
	 'define\n'#
	 '   Principle =\n'#
	 '   elem(tag: principledef\n'#
	 '	id: elem(tag: constant\n'#
	 '		 data: \''#NameA#'\')\n'#
	 if DVAs==nil then
	    ''
	 else
	    '        dimensions: '#{Helpers.vs2V
				    {ListMapInd DVAs
				     fun {$ I DVA}
					if I==1 then
					   'elem(tag: variable\n'
					else
					   '                     elem(tag: variable\n'
					end#
					'                          data: \''#DVA#'\')'
				     end}
				    '[' '\n                    ]' '\n'}#'\n'
	 end#
	 '        constraints: [elem(tag: constant\n'#
	 '                           data: \''#NameA1#'\')#\n'#
	 '                      elem(tag: integer\n'#
	 '                           data: 140)\n'#
	 '                     ])\n'#
	 'end\n'
	 ConstraintV = HeaderV#ConstraintsV#FooterV
	 %%
	 PrincipleDefUrlV = if DefinitionS=="" then
			       '../Solver/Principles/'#NameA1#'.oz'
			    else
			       DefinitionS
			    end
	 ConstraintUrlV = if ConstraintS=="" then
			     '../Solver/Principles/Lib/'#NameA1#'.oz'
			  else
			     ConstraintS
			  end
      in
	 {Helpers.putV PrincipleDefV PrincipleDefUrlV}
	 {System.showInfo 'Saved principle definition functor in "'#PrincipleDefUrlV#'"'}
	 {Helpers.putV ConstraintV ConstraintUrlV}
	 {System.showInfo 'Saved constraint functor in "'#ConstraintUrlV#'"'}
      end
   catch E then
      V = {Helpers.e2V E}
   in
      {System.showError '\n'#V}
      if DebugB then {System.show E} end
   end
in
   {Application.exit 0}
end
