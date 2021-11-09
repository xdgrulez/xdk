functor
import
   MatchHelpers(getSem:GetSem) at 'MatchHelpers.ozf'
   LazyList(map:LazyMap) at 'LazyList.ozf'
   %Ozcar(breakpoint:BP)
export
   Match
   MkCoercer
   Fail
   IsFail
   Any
prepare
   fun {Fst X} X.1 end
   fun {ApplyBinary P X} {P X} end
   Zip = List.zip
   DropWhile = List.dropWhile
   RecordToList = Record.toList
   ListToTuple = List.toTuple
   ProcedureApply = Procedure.apply
   BottomUpFail = {NewName}
define
   Fail = BottomUpFail
   fun {MkCoercer Tid CoerceFs}
      fun {$ X}
	 XTid = {Label X}
      in
	 if XTid == Tid then X
	 elseif {HasFeature CoerceFs XTid} then
	    Tid({CoerceFs.XTid X.1})
	 else
	    Fail
	 end
      end
   end

   fun {Any X}
      X
   end

   fun {IsFail X}
      {IsTuple X}
      andthen ({Label X} == Fail orelse {CondSelect X 1 unit} == Fail)
   end 

   fun {MatchArgs Coercers Args CoercedArgs}
      if {Length Coercers} == {Length Args} then
	 CoercedArgs1 = {Zip Coercers Args ApplyBinary}
      in
	 if {Some CoercedArgs1 IsFail} then false
	 else
	    CoercedArgs = CoercedArgs1
	    true
	 end
      else false end
   end
   
   local
      fun {ApplyAction A OrigSemL Args AuxArg Rslt}
	 Args1 = {Map Args Fst}
	 Rslt1
      in
	 case A
	 of keep(T) then Rslt1 = T({ListToTuple OrigSemL Args1}) else
	    Args2 = AuxArg|OrigSemL|{Append Args1 [Rslt1]}
	 in
	    {ProcedureApply A Args2}
	 end
	 if {IsFail Rslt1} then false else
	    Rslt = Rslt1
	    true
	 end
      end
   in
      fun {Match TransDefs Cut AuxArg Tree}
	 fun {Match1 Tree}
	    case {Cut Tree} of [Rslt] then Rslt else
	       Sem = {GetSem Tree}
	       SemL = {Label Sem}
	    in
	       if {HasFeature TransDefs SemL} then
		  Rule = TransDefs.SemL
	       in
		  if {IsUnit Rule} then SemL(Tree) else
		     Args = {LazyMap {RecordToList Sem} Match1}
		  in
		     if {Some Args IsFail} then Fail else
			Rslt
			Rules = if {IsList Rule} then Rule else [Rule] end
			Doables = {DropWhile Rules
				   fun {$ Rule} CoercedArgs in
				      {Not {MatchArgs Rule.sig Args CoercedArgs}
				       andthen {ApplyAction Rule.action SemL
						CoercedArgs AuxArg Rslt}}
				   end}
		     in
			if Doables == nil then Fail else Rslt end
		     end
		  end
	       else Fail end
	    end
	 end
	 Rslt = {Match1 Tree}
      in
	 if {IsFail Rslt} then nil else [Rslt.1] end
      end
   end
end