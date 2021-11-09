%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(onToplevel show:Show)
%   System(onToplevel)

   Inspector(inspect)
   
   Service(asynchronous)

   FD
   FS
   Select at 'Select/Select.ozf'

   FlatZincFD at 'FlatZinc/FD.ozf'
   FlatZincFS at 'FlatZinc/FS.ozf'
   FlatZincSelect at 'FlatZinc/Select.ozf'
   
   Helpers(appendList str2Xs x2V) at 'Helpers.ozf'
%   Browser(browse:Browse)
export
   Init
   Get
   GetAll
   PrintX
   PrintComment
   PrintCommentRec
   Apply
   GetProfile
   ProfileDone
prepare
   ListLast = List.last
define
   FdCounterICe = {NewCell unit}
   FdboolCounterICe = {NewCell unit}
   FsCounterICe = {NewCell unit}
   PropCounterICe = {NewCell unit}
   PropCostICe = {NewCell unit}
   %%
   VarPortCe = {NewCell unit}
   VarPortStrCe = {NewCell unit}
   ConstraintPortCe = {NewCell unit}
   ConstraintPortStrCe = {NewCell unit}
   BranchPortCe = {NewCell unit}
   BranchPortStrCe = {NewCell unit}
   OutputPortCe = {NewCell unit}
   OutputPortStrCe = {NewCell unit}
   ModelPortCe = {NewCell unit}
   ModelPortStrCe = {NewCell unit}
   %%
   SearchACe = {NewCell unit}
   ProfileBCe = {NewCell false}
   fun {Profiling} @ProfileBCe end
   %% Amazingly, using synchronous services (for NewProp) lead to
   %% misterious failures, hence the following device:
   ProfileDoneCe = {NewCell unit}
   proc {WaitProfileDone} {Wait @ProfileDoneCe} end
   ProfileDone = {Service.asynchronous.newProc
		  proc {$} @ProfileDoneCe = unit end}
   %%
   PortAPortCeRec = o(var: VarPortCe
		      constraint: ConstraintPortCe
		      branch: BranchPortCe
		      output: OutputPortCe
		      model: ModelPortCe)
   fun {PortA2Port PortA} {Access PortAPortCeRec.PortA} end
   PortAPortStrCeRec = o(var: VarPortStrCe
			 constraint: ConstraintPortStrCe
			 branch: BranchPortStrCe
			 output: OutputPortStrCe
			 model: ModelPortStrCe)
   fun {PortA2PortStr PortA} {Access PortAPortStrCeRec.PortA} end
   %%
   proc {Init SearchA ProfileB}
      VarPortStr
      VarPort = {NewPort VarPortStr}
      ConstraintPortStr
      ConstraintPort = {NewPort ConstraintPortStr}
      BranchPortStr
      BranchPort = {NewPort BranchPortStr}
      OutputPortStr
      OutputPort = {NewPort OutputPortStr}
      ModelPortStr
      ModelPort = {NewPort ModelPortStr}
   in
      {Assign VarPortStrCe VarPortStr}
      {Assign VarPortCe VarPort}
      {Assign ConstraintPortStrCe ConstraintPortStr}
      {Assign ConstraintPortCe ConstraintPort}
      {Assign BranchPortStrCe BranchPortStr}
      {Assign BranchPortCe BranchPort}
      {Assign OutputPortStrCe OutputPortStr}
      {Assign OutputPortCe OutputPort}
      {Assign ModelPortStrCe ModelPortStr}
      {Assign ModelPortCe ModelPort}
      %%
      {Assign FdCounterICe 0}
      {Assign FdboolCounterICe 0}
      {Assign FsCounterICe 0}
      %%
      {Assign PropCounterICe 0}
      {Assign PropCostICe 0}
      %%
      {Assign SearchACe SearchA}
      {Assign ProfileBCe ProfileB}
      {Assign ProfileDoneCe _} 
   end
   %%
   fun {Get PortA}
      PortStr = {PortA2PortStr PortA}
      Vs = {Helpers.str2Xs PortStr}
   in
      Vs
   end

   proc {NumberVars Vs Rslt}
      case Vs
      of nil then Rslt = nil
      [] V|Vs1 then RsltTail in
	 case V
	 of var(i:I type:CSPTypeA decl:Decl) then
	    if {IsDet I} then Rslt = RsltTail
	    else
	       I = {NewVar CSPTypeA}
	       {Wait I}
	       Rslt = Decl|RsltTail
	    end
	 else Rslt = V|RsltTail end
	 RsltTail = {NumberVars Vs1}
      end
   end
   
   fun {GetAll}
      SearchA = {Access SearchACe}
      %%
      VarPortStr = {PortA2PortStr var}
      VarXs = {Helpers.str2Xs VarPortStr}
      VarVs = {NumberVars VarXs}
      VarVs1 = case SearchA
	       of print then
		  %% for CSP output, we only need the first line from
		  %% the variable stream reading "% CSP for input ..."
		  %% We do not need the variable declarations; they
		  %% are implicitly done by "propagators" such as
		  %% FD.int etc.
		  [VarVs.1]
	       [] flatzinc then
		  VarVs
	       end
      ConstraintPortStr = {PortA2PortStr constraint}
      ConstraintXs = {Helpers.str2Xs ConstraintPortStr}
      ConstraintVs = {Map ConstraintXs
		      fun {$ X}
			 if X.1=='% ' then
			    X
			 elsecase SearchA
			 of print then
			    {Helpers.x2V X}
			 [] flatzinc then
			    X
			 end
		      end}
      BranchVs = case SearchA
		 of print then nil
		 [] flatzinc then
		    BranchPortStr = {PortA2PortStr branch}
		    BranchVs = {Helpers.str2Xs BranchPortStr}
		 in
		    {Append 'solve'|BranchVs ['satisfy;']}
		 end
      OutputVs = case SearchA
		 of print then nil
		 [] flatzinc then
		    OutputPortStr = {PortA2PortStr output}
		    Vs = {Helpers.str2Xs OutputPortStr}
		 in
		    Vs
		 end
      ModelPortStr = {PortA2PortStr model}
      ModelXs = {Helpers.str2Xs ModelPortStr}
      ModelVs = {Map ModelXs
		 fun {$ ModelX}
		    '% '#X = ModelX
		 in
		    '% '#{Helpers.x2V X}
		 end}
   in
      {Helpers.appendList [VarVs1 ConstraintVs BranchVs OutputVs ModelVs]}
   end
   %%
   fun {GetProfile}
      %% Amazingly, using synchronous services (for NewProp) lead to
      %% misterious failures, hence the following statement:
      {WaitProfileDone}
      NFdInt = @FdCounterICe
      NFdBool = @FdboolCounterICe
      NFdTotal = NFdInt+NFdBool
      NFs = @FsCounterICe
   in
      profile(
	 variables:
	    o(fd:o(int:NFdInt
		   bool:NFdBool
		   total:NFdTotal)
	      fs:NFs
	      total:NFdTotal+NFs)
	 propagators:
	    o(count:@PropCounterICe
	      cost:@PropCostICe))
   end
   %%
   proc {PrintX X PortA}
      Port = {PortA2Port PortA}
   in
      {System.show '--'}
      {System.show X}
      {System.show Port}
      {System.show PortA}
      {System.show '--'}
      {Send Port X}
   end
   %%
   proc {PrintComment X PortA}
      {PrintX '% '#X PortA}
   end
   %%
   fun {PickleRec1 X AccLIs}
      if {IsDet X} then
	 case X
	 of var#fd#I then
	    [{Append AccLIs [fdvar#I]}]
	 [] var#fdbool#I then
	    [{Append AccLIs [fdboolvar#I]}]
	 [] var#fs#I then
	    [{Append AccLIs [fsvar#I]}]
	 elseif {IsRecord X} andthen {Width X}>0 then
	    LIs = {Arity X}
	    LIss =
	    for LI in LIs append:Append2 do
	       LIss = {PickleRec1 X.LI {Append AccLIs [LI]}}
	    in
	       {Append2 LIss}
	    end
	 in
	    LIss
	 else
	    [{Append AccLIs [det#X]}]
	 end
      else
	 [{Append AccLIs [X]}]
      end
   end
   fun {PickleRec X} {PickleRec1 X nil} end
   %%
   proc {PrintCommentRec Rec}
      LIss = {PickleRec Rec}
      LIss1 = {Filter LIss
	       fun {$ LIs} {IsDet {ListLast LIs}} end}
   in
      for LIs in LIss1 do
	 {PrintComment LIs model}
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   FD1 = {Adjoin FD
	  'export'(
	     equal: proc {$ Arg1 Arg2}
		       Arg1 = Arg2
		       %%1 = (Arg1=:Arg2)
		    end
	     notequal: proc {$ Arg1 Arg2}
			  Arg1 \=: Arg2
			  %%1 = (Arg1\=:Arg2)
		       end
	     reified:
		{Adjoin FD.reified
		 reified(equal: proc {$ Arg1 Arg2 Arg3}
				   Arg3 = (Arg1=:Arg2)
				end
			 greater: proc {$ Arg1 Arg2 Arg3}
				     Arg3 = (Arg1>:Arg2)
				  end
			 greatereq: proc {$ Arg1 Arg2 Arg3}
				       Arg3 = (Arg1>=:Arg2)
				    end
			 less: proc {$ Arg1 Arg2 Arg3}
				  Arg3 = (Arg1<:Arg2)
			       end
			 lesseq: proc {$ Arg1 Arg2 Arg3}
				    Arg3 = (Arg1=<:Arg2)
				end
			 notequal: proc {$ Arg1 Arg2 Arg3}
				      Arg3 = (Arg1\=:Arg2)
				   end)})}
   FS1 = local
	    proc {Diff Arg1 Arg2 Arg3}
	       {FS.intersect Arg1 {FS.compl Arg2} Arg3}
	    end
	    fun {IsEmpty M} {FS.card M} =: 0 end
	 in
	    {Adjoin FS
	     'export'(equal: proc {$ Arg1 Arg2}
				Arg1 = Arg2
			     %{FS.subset Arg1 Arg2}
			     %{FS.subset Arg2 Arg1}
			     end
		      notequal: FS.distinct
		      reified:
			 {Adjoin FS.reified
			  reified(subset:
				     proc {$ Arg1 Arg2 Arg3}
					Arg3 = {IsEmpty {Diff Arg1 Arg2}}
					%Arg3 = {FS.reified.equal {FS.intersect Arg1 Arg2} Arg1}
				     end
				  disjoint:
				     proc {$ Arg1 Arg2 Arg3}
					Arg3 = {IsEmpty {FS.intersect Arg1 Arg2}}
				     end
				  include: proc {$ Arg1 Arg2 Arg3}
					      Arg3 = {FD.int 0#1}
					      if {IsDet Arg1} then
						 {FS.reified.isIn Arg1 Arg2 Arg3}
					      elseif {FD.reflect.max Arg1} < 64 then
						 {FS.reified.include Arg1 Arg2 Arg3}
					      else
						 thread
						    or {FS.include Arg1 Arg2}
						       Arg3=1
						    [] {FS.exclude Arg1 Arg2}
						       Arg3=0
						    end
						 end
					      end
					   end
				  notequal: proc {$ Arg1 Arg2 Arg3}
					       {FD1.nega {FS.reified.equal Arg1 Arg2} Arg3}
					    end
				 )}
		      diff:Diff)}
	 end
   %%
   FunctorAFunctorRec =
   o('FD': FD1
     'FS': FS1
     'Select': Select)
   %%
   fun {Arg2ArgTypeTup Arg}
      Arg2#Type2 =
      if {IsDet Arg} then
	 case Arg
	 of Arg1#fd then Arg1#fd
	 [] Arg1#fdbool then Arg1#fdbool
	 [] Arg1#fs then Arg1#fs
	 [] Arg1#list(X) then Arg1#list(X)
	 [] Arg1#tup(X) then Arg1#tup(X)
	 [] Arg1#rec(X) then Arg1#rec(X)
	 [] Arg1#vec(X) then Arg1#vec(X)
	 [] Arg1#any then Arg1#any
	 else Arg#any
	 end
      else
	 Arg#any
      end
   in
      Arg2#Type2
   end
   %%
   fun {AtomicInc Ce N}
      New
      Old = Ce := New
   in
      New = Old + N
      New
   end
   %%
   NewVar = {Service.asynchronous.newFun
	     fun {$ CSPTypeA}
		CounterICe =
		case CSPTypeA
		of fd then FdCounterICe
		[] fdbool then FdboolCounterICe
		[] fs then FsCounterICe
		end
	     in
		{AtomicInc CounterICe 1}
	     end}
   %%
   NewProp = {Service.asynchronous.newProc
	      proc {$ Cost}
		 {AtomicInc PropCounterICe 1 _}
		 {AtomicInc PropCostICe Cost _}
	      end}
   %%
   fun {Arg2CSPArg Arg}
      Arg1#Type1 = {Arg2ArgTypeTup Arg}
   in
      if {IsDet Arg1} then
	 case Arg1
	 of var#Type2#I then
	    Status =
	    case Type2
	    of fd then kinded(int)
	    [] fdbool then kinded(bool)
	    [] fs then kinded(fset)
	    else raise error1('functor':'Solver/Principles/Lib/Share.ozf' 'proc':'Arg2CSPArg' msg:'Unsupported type of an already seen variable.' info:o(Arg) coord:noCoord file:noFile) end
	    end
	 in
	    Status#I
	 elseif {IsList Arg1} then
	    Type =
	    case Type1
	    of list(Type2) then Type2
	    [] vec(Type2) then Type2
	    else any
	    end
	 in
	    det(list)#
	    {Map Arg1
	     fun {$ Arg} {Arg2CSPArg Arg#Type} end}
	 elseif {IsRecord Arg1} andthen {Width Arg1}>0 then
	    Type =
	    case Type1
	    of tup(Type2) then Type2
	    [] rec(Type2) then Type2
	    [] vec(Type2) then Type2
	    else any
	    end
	 in
	    det(tuple)#
	    {Map {Arity Arg1}
	     fun {$ LI} {Arg2CSPArg Arg1.LI#Type} end}
	 elseif Type1==fdbool then det(bool)#Arg1
	 else
	    {Value.status Arg1}#Arg1
	 end
      else
	 SearchA = {Access SearchACe}
	 VarI % = {NewVar Type1}
	 Status =
	 case Type1
	 of fd then
	    case SearchA
	    of print then
	       {PrintX var(i:VarI type:fd decl:VarI) var}
	    [] flatzinc then
	       {PrintX var(i:VarI type:fd decl:'var 0..134217726: '#fd#VarI#';') var}
	    end
	    %%
	    kinded(int)
	 [] fdbool then
	    case SearchA
	    of print then
	       {PrintX var(i:VarI type:fdbool decl:VarI) var}
	    [] flatzinc then
	       {PrintX var(i:VarI type:fdbool decl:'var bool: '#fdbool#VarI#';') var}
	    end
	    %%
	    kinded(bool)
	 [] fs then
	    {Inspector.inspect searchA#SearchA}
	    case SearchA
	    of print then
	       {PrintX var(i:VarI type:fs decl:VarI) var}
	    [] flatzinc then
	       {PrintX var(i:VarI type:fs decl:'var set of 0..134217726: '#fs#VarI#';') var}
	    end
	    %%
	    kinded(fset)
	 else raise error1('functor':'Solver/Principles/Lib/Share.ozf' 'proc':'Arg2CSPArg' msg:'Unsupported type of a new variable.' info:o(Arg) coord:noCoord file:noFile) end
	 end
      in
	 Arg1 = var#Type1#VarI
	 Status#VarI
      end
   end
   %%
   FunctorAFZFunctorRec =
   o('FD': FlatZincFD
     'FS': FlatZincFS
     'Select': FlatZincSelect)
   %%
   local
      proc {CountNewVar Arg}
	 if {Not {IsFree Arg}} then
	    case Arg of V#CSPTypeA then
	       if {IsFree V} then {NewVar CSPTypeA _} end
	    else skip end
	 end
      end
      fun {VecWidth Vec}
	 if {IsFree Vec} then 1
	 elseif {IsList Vec} then {Length Vec}
	 elseif {IsRecord Vec} then {Width Vec}
	 else 1 end
      end
      fun {ComputeCost Arg}
	 if {Not {IsFree Arg}} then
	    case Arg of V#CSPTypeA then
	       case CSPTypeA
	       of vec(_) then {VecWidth V}
	       [] list(_) then {VecWidth V}
	       else 1 end
	    else 1 end
	 else 1 end
      end
   in  
      proc {ComputeProfile Args}
	 Cost = {FoldL {Map Args ComputeCost} Number.'+' 0}
      in
	 {NewProp Cost}
	 if {Not {System.onToplevel}} then {ForAll Args CountNewVar} end
      end
   end
   %%
   proc {Apply FunctorA LIs Args}
      if {Profiling} then
	 {ComputeProfile Args}
      end
      if {System.onToplevel} then
	 SearchA = {Access SearchACe}
	 CSPArgs = {Map Args Arg2CSPArg}
      in
	 case SearchA
	 of print then
	    {PrintX FunctorA#LIs#CSPArgs constraint}
	 [] flatzinc then
	    Proc = {FoldL LIs
		    fun {$ AccX LI} AccX.LI end
		    FunctorAFZFunctorRec.FunctorA}
	    PortAFlatZincVTups = {Proc CSPArgs}
	 in
	    for PortA#FlatZincV in PortAFlatZincVTups do
 	       if PortA==var then
		  'var '#_#': '#(CSPTypeA#I)#';' = FlatZincV
	       in
		  {PrintX var(i:I type:CSPTypeA decl:FlatZincV) var}
	       else
		  {PrintX FlatZincV PortA}
	       end
	    end
	 end
      else
	 Functor = FunctorAFunctorRec.FunctorA
	 Proc = {FoldL LIs fun {$ AccX LI} AccX.LI end Functor}
	 Args1 = {Map Args
		  fun {$ Arg}
		     Arg1#_ = {Arg2ArgTypeTup Arg}
		  in
		     Arg1
		  end}
      in
	 {Procedure.apply Proc Args1}
      end
   end
end
