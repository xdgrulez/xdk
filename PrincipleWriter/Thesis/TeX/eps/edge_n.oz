[] edge(TermTree1 TermTree2 TermTree3) then
   ConstantAI1 = {Helpers.termTree2AI TermTree1}
   ConstantS1 = {V2S ConstantAI1}
   NewContext1 =
   if {Char.isAlpha ConstantS1.1} andthen
      {Char.isUpper ConstantS1.1} andthen
      {All ConstantS1
       fun {$ Ch}
	  {Char.isAlpha Ch} orelse {Char.isDigit Ch}
       end}
   then
      {UnionContext Context o(ConstantAI1:node)}
   else
      Context
   end
   ConstantAI2 = {Helpers.termTree2AI TermTree2}
   ConstantS2 = {V2S ConstantAI2}
   NewContext2 =
   if {Char.isAlpha ConstantS2.1} andthen
      {Char.isUpper ConstantS2.1} andthen
      {All ConstantS2
       fun {$ Ch}
	  {Char.isAlpha Ch} orelse {Char.isDigit Ch}
       end}
   then
      {UnionContext NewContext1 o(ConstantAI2:node)}
   else
      NewContext1
   end
   ConstantAI3 = {Helpers.termTree2AI TermTree3}
   ConstantS3 = {V2S ConstantAI3}
   NewContext3 =
   if {Char.isAlpha ConstantS3.1} andthen
      {Char.isUpper ConstantS3.1} andthen
      {All Constant S3
       fun {$ Ch}
	  {Char.isAlpha Ch} orelse {Char.isDigit Ch}
       end}
   then
      {UnionContext NewContext2 o(ConstantAI3:dim)}
   else 
      NewContext2
   end
in
   o(operation:edge(TermTree1 TermTree2 TermTree3)
     con:NewContext3)
