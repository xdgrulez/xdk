%%
%%  Module LetTransform
%%
%%  Exports three transforms to deal with let expressions, i.e.
%%  logic variables, namely:
%%
%%  . expand.the: expands all variables where they are applied, leaving
%%    traces so that they can be "restored" later. Traces are of two
%%    forms:
%%
%%    . lettrace(VConstTree Form), which means that formerly there was
%%      a let(VConstTree Form1) at this point and Form was obtained by
%%      expanding all occurrences of variable VConstTree inside Form1;
%%    . srcvar(VConstTree Form), which means that Form or its precursor
%%      before optimization was formerly an application of variable
%%      VConstTree;
%%
%%  . restore.the: restores variables whose traces have not been erased
%%    by optimization. Though unlikely, it is possible that different
%%    applications of one same variable evolve into different forms
%%    as a result of optimization. This is dealt with correctly.
%%
%%  . irreversible.the: expands all variables definitely, i.e. leaving
%%    no traces.
%%
functor
import
%   System(show)

   TopDown(mkMatch:MkMatch
	   apply:Apply
	   'fail':Fail
	   mkGreedyClosure:MkClosure
	   fst:Fst
	   asDl:AsDl
	   ifMatched:IfMatched) at 'TopDownMatch.ozf'
   MatchHelpers(
      getSem:GetSem
      eqSems:EqSems
      constantTree2A:CT2A) at 'MatchHelpers.ozf'
   Helpers(mkAccum:MkAccum) at 'Helpers.ozf'
   PWTreeAccess(committed:MkAccess) at 'PWTreeAccess.ozf'
   GornUtils(gornAdjoin:GornAdjoin) at 'GornUtils.ozf'
   MkTransf at 'MkTransform.ozf'
%   Ozcar(breakpoint:BP)
export
   Irreversible
   Expand
   Restore
prepare
   fun {Const X}
      fun {$ _} X end
   end
   RecordMap = Record.map
   DropWhile = List.dropWhile
define
   %%
   %% InnerIrreversible: the core of let-expression expansion
   %% with no later restoration.
   %%
   local
      o(match:Match ...)
      = {MkAccess o(logicvar:CondExpand
		    var:CondExpand)}

      CondExpand = Apply(fun {$ let(V1 Def _) T}
			    if {EqSems V1 {GetSem T}.1} then
			       replace(Def)
			    else Fail end
			 end)
   in
      fun {InnerIrreversible Test#Let T}
	 Rslt = if {Test Let.1 T} then
		   Diff = {Match Let T}
		in
		   {GornAdjoin T Diff}
		else Fail end
	 Form
      in
	 Rslt#(Form#Form)
      end
   end

   %%
   %% InnerExpand: the core of let-expression expansion leaving
   %% traces for later restoration.
   %%
   local
      o(match:Match ...)
      = {MkAccess o(logicvar:CondExpand
		    var:CondExpand)}
      CondExpand = Apply(fun {$ let(V1A Def) T}
%			    {System.show 1#{GetSem T}.1}
			    V2A = {CT2A {GetSem T}.1}
			 in
			    if V1A == V2A  then
			       replace(srcvar(V2A Def true))
			    else Fail end
			 end)
   in
      fun {InnerExpand _#Let T}
%	 {System.show 2#Let.1}
	 VA = {CT2A Let.1}
	 Def = Let.2
	 Rslt = {Match let(VA Def) T}
	 Form 
      in
	 {GornAdjoin T Rslt}#(lettrace(VA Form)#Form)
      end
   end

   %%
   %% InnerRestore: the core of let-expression restoration.
   %%
   local
      Pat
      o(match:Match mkEasy:MkEasy ...)
      = {MkAccess Pat}
      
      !Pat = o(srcvar:[{MkEasy 2}
		       fun {$ V1A#Collect _ V2A KeyForm Required}
			  if V1A == V2A then Cmd in
			     {Collect
			      o(key:KeyForm cmd:Cmd
				alone:if Required then unit else _ end)}
			     Cmd
			  else Fail end
		       end])
	 
      fun {AccumSeed Seed Seeds} 
	 case {DropWhile Seeds fun {$ Seed1}
			      {Not {EqSems Seed1.key Seed.key}}
			   end}
	 of nil then
	    Def Apply LastCmd = replace(Apply)
	    NewSeed = {Adjoin Seed o(def:Def 
				     apply:Apply
				     cmd:LastCmd)}
	 in
	    Seed.cmd = {AsDl [unify(Def) LastCmd]}
	    NewSeed|Seeds
	 [] Old|_ then
	    Seed.cmd = Old.cmd
	    Old.alone = unit
	    Seeds
	 end
      end

      fun {Seeds2Lets NewVarId Seeds}
	 {FoldL Seeds
	  fun {$ Lets Seed} ActualDef = {GetSem Seed.def}.2 in
	     if {IsFree Seed.alone} then
		Seed.apply = ActualDef
		Lets
	     else
		VConst = constant({NewVarId})
		Let = let(VConst ActualDef _)
	     in
		Seed.apply = var(VConst)
		Let|Lets
	     end
	  end
	  nil}
      end

      local
	 proc {Accum UpperForm Let Form}
	    UpperForm = {AdjoinAt Let 3 Form}
	 end
      in
	 fun {Nest Lets} Upper Lower in
	    Lower = {FoldL Lets Accum Upper}
	    Upper#Lower
	 end
      end
   in
      fun {InnerRestore NewVarId#Lettrace T}
	 VA = Lettrace.1
	 Accum = {MkAccum nil AccumSeed}
	 GornDiff = {Match VA#Accum.accum T}
	 NewT = {GornAdjoin T GornDiff}
      in
	 NewT#{Nest {Seeds2Lets NewVarId {Accum.access}}}
      end
   end

   %%
   %%  MkLetTrans: factors out what's common to all transforms.
   %%
   fun {MkLetTrans StartL InnerTrans BotUpOrTopDwn}
      Pat = o(StartL:Apply(Transform))
    
      fun {Transform Arg T}
	 Let = {GetSem T}
	 Form = Let.{Width Let} 
	 MatchRslt#(UpEnd#LowEnd) = {InnerTrans Arg#Let Form}
      in
	 {IfMatched {Fst MatchRslt} 
	  fun {$ NewForm}
	     LowEnd = NewForm
	     UpEnd
	  end}
      end
      Reduce = {MkMatch Pat}
      Closure = {MkClosure Reduce}
      The = {MkTransf.saturate.BotUpOrTopDwn {RecordMap Pat {Const Closure}}}
   in
      o(innerTrans:InnerTrans
	reduce:Reduce
	closure:Closure
	the:The)
   end
   Irreversible = {MkLetTrans let InnerIrreversible topDown}
   Expand = {MkLetTrans let InnerExpand topDown}
   Restore = {MkLetTrans lettrace InnerRestore bottomUp}
end
