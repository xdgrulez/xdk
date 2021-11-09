fun {DecideStrategy ConstantATypeTreeRec Context Form}
   FirstOp = Form.sem
in
   case FirstOp
   of exists(ConstantTree DomTree FormTree) then
      VarName = {Helpers.constantTree2A ConstantTree}
      Dom = {Helpers.tree2T DomTree ConstantATypeTreeRec}
      NewContext = {UnionContext Context o(VarName:Dom)}
      NewValues = {DecideStrategy 
		   ConstantATypeTreeRec NewContext FormTree}
   in
      o(operation:exists(ConstantTree DomTree NewValues.operation)
	con:NewValues.con)
   [] exists(ConstantTree FormTree) then
      VarName = {Helpers.constantTree2A ConstantTree}
   in
      if {HasFeature Context VarName} then
	 raise 'ERROR: Variable already defined'#VarName end
      else
	 NewContext = {UnionContext Context o(VarName:undef)}
	 NewValues = {DecideStrategy 
		      ConstantATypeTreeRec NewContext FormTree}
      in
	 case NewValues.con.VarName
	 of undef then
	    raise 'ERROR: Variable has no type'#VarName end
	 else
	    o(operation:exists(ConstantTree 
			       NewValues.con.VarName 
			       NewValues.operation)
	      con:NewValues.con)
	 end
      end
   else
      {TypeNonQuantifier ConstantATypeTreeRec Context Form}
   end
end
