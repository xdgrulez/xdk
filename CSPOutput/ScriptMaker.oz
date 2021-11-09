%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)

   FS(value)
   
   Propagators(get) at 'Propagators.ozf'
   CSPParser(parse) at 'Parsers/CSPParser.ozf'
export
   Make
define
   fun {Make ConstraintSs PrintProc}
      proc {FindVars ArgTup}
	 case ArgTup
	 of det(atom)#_ then skip
	 [] det(int)#_ then skip
	 [] det(bool)#_ then skip
	 [] det(fset)#(_#_) then skip
	 [] det(list)#ArgTups then
	    {ForAll ArgTups FindVars}
	 [] det(tuple)#ArgTups then
	    {ForAll ArgTups FindVars}
	 [] det(record)#ArgTups then      
	    {ForAll ArgTups FindVars}
	 [] kinded(int)#I then
	    if {Not {HasFeature FdIADict I}} then
	       FdIADict.I := fd
	    end
	 [] kinded(bool)#I then
	    if {Not {HasFeature FdboolIADict I}} then
	       FdboolIADict.I := fdbool
	    end
	 [] kinded(fset)#I then
	    if {Not {HasFeature FsIADict I}} then
	       FsIADict.I := fs
	    end
	 end
      end
      %%
      FunctorAFunctorRec = {Propagators.get}
      %%
      FdIADict = {NewDictionary}
      FdboolIADict = {NewDictionary}
      FsIADict = {NewDictionary}
      ConstraintSsI = {Length ConstraintSs}
      FunctorALIsArgTupsTups =
      for S in ConstraintSs I in 1..ConstraintSsI collect:Collect do
	 FunctorA#LIs#ArgTups = {CSPParser.parse S}
      in
	 {ForAll ArgTups FindVars}
	 {Collect FunctorA#LIs#ArgTups}
	 if I mod 1000==0 then {PrintProc I#'/'#ConstraintSsI} end
      end
      FdIATups = {Dictionary.entries FdIADict}
      FdIATupsI = {Length FdIATups}
      FdboolIATups = {Dictionary.entries FdboolIADict}
      FdboolIATupsI = {Length FdboolIATups}
      FsIATups = {Dictionary.entries FsIADict}
      FsIATupsI = {Length FsIATups}
      {PrintProc propagators#ConstraintSsI}
      {PrintProc variables#FdIATupsI+FdboolIATupsI+FsIATupsI#
       o(fd: FdIATupsI
	 fdbool: FdboolIATupsI
	 fs: FsIATupsI)}
      ScriptProc =
      proc {$ IVarRecTup}
	 FdIVarTups = {Map FdIATups
		       fun {$ I#_} I#_ end}
	 FdIVarRec = {List.toRecord o FdIVarTups}
	 FdboolIVarTups = {Map FdboolIATups
			   fun {$ I#_} I#_ end}
	 FdboolIVarRec = {List.toRecord o FdboolIVarTups}
	 FsIVarTups = {Map FsIATups
		       fun {$ I#_} I#_ end}
	 FsIVarRec = {List.toRecord o FsIVarTups}
	 !IVarRecTup = FdIVarRec#FdboolIVarRec#FsIVarRec
	 %%
	 fun {ArgTup2Arg ArgTup}
	    case ArgTup
	    of det(atom)#A then A
	    [] det(int)#I then I
	    [] det(bool)#I then I
	    [] det(fset)#(Spec#_) then
	       {FS.value.make Spec}
	    [] det(list)#ArgTups then
	       {Map ArgTups ArgTup2Arg}
	    [] det(tuple)#ArgTups then
	       Args = {Map ArgTups ArgTup2Arg}
	    in
	       {List.toTuple '#' Args}
	    [] det(record)#ArgTups then      
	       Args = {Map ArgTups ArgTup2Arg}
	    in
	       {List.toTuple o Args}
	    [] kinded(int)#I then
	       FdIVarRec.I
	    [] kinded(bool)#I then
	       FdboolIVarRec.I
	    [] kinded(fset)#I then
	       FsIVarRec.I
	    end
	 end
      in
	 for FunctorA#LIs#ArgTups in FunctorALIsArgTupsTups do
	    Functor = FunctorAFunctorRec.FunctorA
	    Proc = {FoldL LIs
		    fun {$ AccX LI} AccX.LI end Functor}
	    Args = {Map ArgTups ArgTup2Arg}
	 in
	    {Procedure.apply Proc Args}
	 end
      end
   in
      ScriptProc
   end
end
