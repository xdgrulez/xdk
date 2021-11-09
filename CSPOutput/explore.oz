%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(exit getArgs)
   Explorer(object)
   FD(is reflect)
   FS(reflect)
   Inspector(inspect)
   Open(file)
   Property(put)
   System(showError show)
   
   Helpers(getLines unPickleRec changeSuffix) at 'Helpers.ozf'
   ScriptMaker(make) at 'ScriptMaker.ozf'
   SolutionViewer(view) at 'SolutionViewer.ozf'
   
   ModelParser(parse) at 'Parsers/ModelParser.ozf'
prepare
   ListLast = List.last
   ListPartition = List.partition
   ListTake = List.take
   RecordMap = Record.map
   RecordToList = Record.toList
define
   V2A = VirtualString.toAtom
   %%
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   csp(single type:string char:&c default:unit)
	  )}
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--csp <File>                 csp output file\n'#
       ' -c                          (e.g. --csp "test.csp")'
      }
      {Application.exit 0}
   end
   %%
   UrlS = AArgRec.csp
   Ss = {Helpers.getLines UrlS}
   ConstraintSs
   ModelSs1
   %% example constraint lines:
   %%   'FS'#[value make]#[det(tuple)#[det(int)#1 det(int)#2] kinded(fset)#1]
   %% example model line:
   %%   % [1 entryIndex var#2]
   %% other lines:
   %%   % CSP for input "a b"
   %%   % id principle.graph GraphMakeNodes
   {ListPartition Ss
    fun {$ S} {Not S.1==&%} end
    ConstraintSs ModelSs1}
   ModelSs = {Filter ModelSs1
	      fun {$ S} {Nth S 3}==&[ end}
   ScriptProc = {ScriptMaker.make ConstraintSs Inspector.inspect}
   %%
   fun {IVarRecTup2Nodes FdIVarRec#FdboolIVarRec#FsIVarRec ModelSs}
      ModelXs =
      for S in ModelSs collect:Collect do
	 &%|& |S1 = S
	 Xs = {ModelParser.parse S1}
	 X = {ListLast Xs}
	 Y = case X
	     of det#Z then Z
	     [] fdvar#J then FdIVarRec.J
	     [] fdboolvar#J then FdboolIVarRec.J
	     [] fsvar#J then FsIVarRec.J
	     end
	 Xs1 = {ListTake Xs {Length Xs}-1}
	 Xs2 = {Append Xs1 [Y]}
      in
	 {Collect Xs2}
      end
      ModelRec = {Helpers.unPickleRec ModelXs}
      Nodes = {RecordToList ModelRec}
   in
      Nodes
   end
   %%
   proc {InspectNodes I IVarRecTup}
      Nodes = {IVarRecTup2Nodes IVarRecTup ModelSs}
   in
      {Inspector.inspect Nodes}
   end
   %%
   proc {ShowDAGs I _#_#FsIVarRec}
      FsISpecRec = {RecordMap FsIVarRec FS.reflect.lowerBound}
   in  
      {SolutionViewer.view I FsISpecRec ModelSs noDeleteProc}
   end
   %%
   proc {SaveSolution SolI FdIVarRec#FdboolIVarRec#FsIVarRec}
      V = {Helpers.changeSuffix UrlS 'sol'#SolI}
      FileO = {New Open.file
	      init(name: V
		   flags: [create truncate write text])}
   in      
      for I in {Arity FdIVarRec} do
	 D = FdIVarRec.I
	 Spec = I#fd#{FD.reflect.dom D}
	 V = {Value.toVirtualString Spec 10000 10000}#'\n'
      in
	 {FileO write(vs: V)}
      end
      for I in {Arity FdboolIVarRec} do
	 D = FdboolIVarRec.I
	 Spec = I#fd#{FD.reflect.dom D}
	 V = {Value.toVirtualString Spec 10000 10000}#'\n'
      in
	 {FileO write(vs: V)}
      end
      for I in {Arity FsIVarRec} do
	 M = FsIVarRec.I
	 Spec = I#fs#{FS.reflect.lowerBound M}#{FS.reflect.upperBound M}#{FS.reflect.card M}
	 V = {Value.toVirtualString Spec 10000 10000}#'\n'
      in
	 {FileO write(vs: V)}
      end
      %%
      for ModelS in ModelSs do
	 {FileO write(vs: ModelS#'\n')}
      end
      {FileO close}
      {Inspector.inspect {V2A 'solution '#SolI#' saved to file '#V}}
   end
   %%
   {Explorer.object delete(information all)}
   {Explorer.object add(information InspectNodes label:'Inspect Nodes')}
   {Explorer.object add(information SaveSolution label:'Save Solution')}
   {Explorer.object add(information ShowDAGs label:'Show DAGs')}
   {Explorer.object all(ScriptProc)}
end
