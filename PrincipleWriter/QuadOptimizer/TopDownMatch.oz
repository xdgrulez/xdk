%\define STRICT   % : good for debugging
functor
import
   MatchHelpers(getSem:GetSem
		unify:UnifyTrees
		unaryFunctionAdapter:UnaryFunctionAdapter) at 'MatchHelpers.ozf'
   LazyList(mapTail:LazyMapTail) at 'LazyList.ozf'
   %Ozcar(breakpoint:BP)
export
   Continue
   Just
   Fail
   Easy
   Else
   Apply
   Unify
   Choose
   Dl
   SinglDl
   DlConcat
   AsDl
   Match
   MatchMap
   MkMatch
   MkSimpleMatch
   MkCombine
   MkSimplifyBranch
   MkSimplify
   Final
   Fst
   IfMatched
   IfMatchedElse
   IfFailed
   MkGreedyClosure
   MkIf
   MkIfElse
prepare
   Combine = {NewName}
   Continue = {NewName}
   Fail = {NewName}
   Just = {NewName}
   Easy = {NewName}
   Else = {NewName}
   Apply = {NewName}
   Unify = {NewName}
   Choose = {NewName}
   Dl = {NewName}
   RecordToList = Record.toList
   ListToRecord = List.toRecord
define
\ifdef STRICT
   fun {ByNeed F} {F} end
\endif
   
   IsProc = IsProcedure
   ProcedureArity = Procedure.arity
   ProcedureApply = Procedure.apply
   fun {MkCombine Xs CombineF}
      fun {$ Y}
	 Combine({Final Xs} Y CombineF)
      end
   end

   fun {SinglDl X} Tail in Dl(X|Tail Tail) end
   
   %%
   %% DlConcat: Dls -> Dl - concatenates a list of difference lists
   %% into a single one.
   local
      fun lazy {ChainDls Dls LastT}
	 case Dls of Dl(L T)|Rest then
	    T = {ChainDls Rest LastT}
	    L
	 [] nil then LastT
	 end
      end
   in
      fun {DlConcat Dls} T L = {ChainDls Dls T} in
	 Dl(L T)
      end
   end

   local
      fun {AsDlAux L T}
	 case L of nil then T
	 [] X|Xs then X|{AsDlAux Xs T}
	 end
      end
   in
      fun {AsDl L} T in
	 Dl({AsDlAux L T} T)
      end
   end
   
   local
      fun lazy {DoCombine Xs Y CombineF OutT}
	 case Xs of
	    nil then OutT
	 [] Z|Zs then Rslt Cont = {DoCombine Zs Y CombineF OutT} in
	    if {CombineF Z Y Rslt} then Rslt|Cont
	    else Cont end
	 end
      end
      proc {ApplyProcPat Pat AuxArg Sem Rslt}
	 PArity = {ProcedureArity Pat}
      in
	 if PArity == 3 + {Width Sem} then
	    SubTrees = {RecordToList Sem}
	 in
	    {ProcedureApply Pat AuxArg|{Label Sem}|{Append SubTrees [Rslt]}}
	 else Rslt = Fail end
      end
      fun {DoProcRslt Rslt Tree OutT}
	 case Rslt of
	    Continue(Pat1 AuxArg1) then
	    {StrictCall Pat1 AuxArg1 Tree OutT}
	 [] Combine(Xs Y CombineF) then
	    {DoCombine Xs Y CombineF OutT}
	 [] !Fail then OutT
	 [] Dl(L T) then
	    OutT = T
	    L
	 else Rslt|OutT end
      end
      proc {DoChoice Pat1 Pat2 AuxArg Tree OutT Rslt} OutT2 in
	 Rslt = {StrictCall Pat1 AuxArg Tree OutT2}
	 OutT2 = {LazyCall Pat2 AuxArg Tree OutT}
      end
      fun {LazyCall Pat AuxArg Tree OutT}
	 {ByNeed fun {$} {StrictCall Pat AuxArg Tree OutT} end}
      end
      fun {StrictCall Pat AuxArg Tree OutT}
	 Sem = {GetSem Tree}
	 SemIsRecord = {IsRecord Sem}
      in
	 case Pat of
	    Just(X) then X|OutT
	 [] nil then OutT
	 [] Pat|Pats then {DoChoice Pat Pats AuxArg Tree OutT}
	 [] Unify(SubPat) then
	    Model#Rslt0 = if {IsProc SubPat}
			  then {SubPat AuxArg {Label Sem}} else SubPat end
	 in
	    if {UnifyTrees Model Tree} then
	       Rslt = if {IsProc Rslt0} then {Rslt0} else Rslt0 end
	    in
	       {DoProcRslt Rslt Tree OutT}
	    else OutT end
	 [] Easy(I SubPat) then
	    if {Not SemIsRecord} orelse {Width Sem} < I then OutT else
	       {StrictCall SubPat AuxArg Sem.I OutT}
	    end
	 [] Easy(SubPat) then
	    {StrictCall Easy(1 SubPat) AuxArg Tree OutT}
	 [] !Fail then OutT
	 [] Apply(Proc) then
	    {DoProcRslt {Proc AuxArg Tree} Tree OutT}
	 [] Choose(I0 IF MkPat) then
	    if I0 > IF then OutT else 
	       {DoChoice {MkPat I0} {AdjoinAt Pat 1 I0+1} AuxArg Tree OutT}
	    end
	 elseif SemIsRecord then
	    if {IsProc Pat} then
	       Rslt = {ApplyProcPat Pat AuxArg Sem}
	    in
	       {DoProcRslt Rslt Tree OutT}
	    elseif {IsRecord Pat} then
	       SubPat = {CondSelect Pat {Label Sem} Else}
	       SubPat1 = if SubPat \= Else then SubPat
			 else {CondSelect Pat Else Fail} end
	    in
	       {StrictCall SubPat1 AuxArg Tree OutT}
	    else OutT end
	 else OutT end
      end
      fun {StrictMatch Pat AuxArg Tree}
	 T
	 Matches = {StrictCall Pat AuxArg Tree T}
      in
	 Dl(Matches T) 
      end
      fun {StrictMatchMap Pat AuxArg Tree MapF}
	 Rslts = {Final {StrictMatch Pat AuxArg Tree}}
	 T L = {LazyMapTail Rslts T MapF}
      in
	 Dl(L T)
      end
   in
\ifdef STRICT
      Match = StrictMatch
      MatchMap = StrictMatchMap
\else
      fun lazy {Match Pat AuxArg Tree}
	 {StrictMatch Pat AuxArg Tree}
      end
      fun lazy {MatchMap Pat AuxArg Tree MapF}
	 {StrictMatchMap Pat AuxArg Tree MapF}
      end
\endif
      fun {MkMatch Pat}
	 fun {$ Arg Tree}
	    {Match Pat Arg Tree}
	 end
      end
      fun {MkSimpleMatch Pat}
	 fun {$ Tree}
	    {Match Pat unit Tree}
	 end
      end
      fun {Final X} 
	 case X of Dl(L T) then
	    T = nil
	    L
	 [] !Fail then nil
	 else X end
      end
      fun {Fst X}
	 FinalX = {Final X}
      in
	 case FinalX of
	    !Fail then Fail
	 [] nil then Fail
	 [] Y|_ then Y
	 else FinalX end
      end
      local
	 fun {ConstFail _} Fail end
      in
	 fun {IfMatched Rslt Then}
	    {IfMatchedElse Rslt unit Then ConstFail}
	 end
	 fun {IfFailed Rslt Then}
	    {IfMatchedElse unit Rslt ConstFail Then}
	 end
      end
      fun {IfMatchedElse Rslt ElseVal Then Else}
	 case Rslt of !Fail
	 then {Else ElseVal}
	 elsecase {Final Rslt}
	 of nil then {Else ElseVal}
	 [] Matches then {Then Matches} end
      end
   end
   fun {MkSimplify L#Arity}
      case Arity of
	 1 then fun {$ _ _ X1} L(X1) end
      [] 2 then fun {$ _ _ X1 X2} L(X1 X2) end
      [] 3 then fun {$ _ _ X1 X2 X3} L(X1 X2 X3) end
      [] 4 then fun {$ _ _ X1 X2 X3 X4} L(X1 X2 X3 X4) end
      [] 5 then fun {$ _ _ X1 X2 X3 X4 X5} L(X1 X2 X3 X4 X5) end
      end
   end
   local
      fun {DoLabelAndMatch L#MatchDef} L#{MkSimplify MatchDef} end
   in
      fun {MkSimplifyBranch Defs}
	 {ListToRecord o {Map Defs DoLabelAndMatch}}
      end
   end
   local
      Noth = {NewName}
      fun {Close Trans Arg Prev Cur}
	 case {Final {Trans Arg Cur}} of
	    nil then Prev
	 [] First|_ then {Close Trans Arg First First}
	 end
      end
   in
      fun {MkGreedyClosure Trans}
	 fun {$ Arg Tree}
	    case {Close Trans Arg Noth Tree} 
	    of !Noth then nil
	    [] X then [X] end
	 end
      end
   end
   fun {MkIf TestF ThenPat}
      {MkIfElse TestF ThenPat Fail}
   end
   fun {MkIfElse TestF0 ThenPat ElsePat}
      TestF = {UnaryFunctionAdapter TestF0}
   in
      Apply(fun {$ Arg T}
	       if {TestF Arg T} then Continue(ThenPat Arg)
	       else Continue(ElsePat Arg) end
	    end)
   end      
end
