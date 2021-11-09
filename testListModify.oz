declare
{Inspector.configure widgetShowStrings true}
[Helpers] = {Module.link ['Helpers.ozf']}
[String1] = {Module.link ['x-oz://system/String.ozf']}
fun {EditLines Ss BeginPrefixS EndPrefixS IndentS EditProc}
   Ss1
   Ss2
   {List.takeDropWhile
    Ss
    fun {$ S} {Not {List.isPrefix BeginPrefixS S}} end
    Ss1
    Ss2}
   Ss11 = {Append Ss1 {List.take Ss2 1}}
   Ss21 = {List.drop Ss2 1}
   Ss3
   Ss4
   {List.takeDropWhile
    Ss21
    fun {$ S} {Not {List.isPrefix EndPrefixS S}} end
    Ss3
    Ss4}
   Ss31 =
   {Map Ss3
    fun {$ S} {String1.lstrip S unit} end}
   %%
   Ss32 = {EditProc Ss31}
   %%
   Ss33 = {Map Ss32
	   fun {$ S} {Append IndentS S} end}
   Ss5 = {Append Ss11 {Append Ss33 Ss4}}
in
   Ss5
end
fun {MakeAddLineProc LineS}
   fun {EditProc Ss}
      Ss1 = LineS|Ss
      Ss2 = {List.sort Ss1
	     fun {$ S1 S2}
		A1 = {String.toAtom S1}
		A2 = {String.toAtom S2}
	     in
		A1 < A2
	     end}
   in
      Ss2
   end
in
   EditProc
end
fun {MakeRemoveLineProc LineS}
   fun {EditProc Ss}
      Ss1 =
      {Filter Ss
       fun {$ S} {Not {List.isPrefix LineS S}} end}
   in
      Ss1
   end
in
   EditProc
end
%Ss = {Helpers.getLines "test/Principles.oz"}
%EditProc1 = {MakeAddLineProc "DasAuto(principle)"}
%EditProc1 = {MakeRemoveLineProc "Chorus(principle)"}
%Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "   " EditProc1}
%%
%EditProc2 = {MakeRemoveLineProc "Chorus.principle"}
%Ss2 = {EditLines Ss1 "% begin list 2" "% end list 2" "    " EditProc2}
%%
%{Helpers.putLines Ss2 "test/Principles.oz1"}
%{Inspect done}
%%
%Ss = {Helpers.getLines "test/makefile1.oz"}
%EditProc1 = {MakeAddLineProc "'DasAuto.ozf'"}
%EditProc1 = {MakeRemoveLineProc "'Chorus.ozf'"}
%Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "   " EditProc1}
%%
%{Helpers.putLines Ss1 "test/makefile1.oz1"}
%{Inspect done}
%%
%Ss = {Helpers.getLines "test/makefile2.oz"}
%EditProc1 = {MakeAddLineProc "'DasAuto.ozf'"}
%EditProc1 = {MakeRemoveLineProc "'Chorus.ozf'"}
%Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
%%
%{Helpers.putLines Ss1 "test/makefile2.oz1"}
%{Inspect done}
%%
%Ss = {Helpers.getLines "test/makefile3.oz"}
%EditProc1 = {MakeAddLineProc "'dasAuto.ul'"}
%EditProc1 = {MakeRemoveLineProc "'orderPW.ul'"}
%Ss1 = {EditLines Ss "% begin list 1" "% end list 1" "\t " EditProc1}
%%
%{Helpers.putLines Ss1 "test/makefile3.oz1"}
%{Inspect done}
%%
Ss = {Helpers.getLines "test/principles.xml"}
EditProc1 = {MakeAddLineProc "<principleDef id=\"principle.dasAuto\"/>"}
%EditProc1 = {MakeRemoveLineProc "<principleDef id=\"principle.chorus\"/>"}
Ss1 = {EditLines Ss "<!-- begin list 1" "<!-- end list 1" "" EditProc1}
%%
{Helpers.putLines Ss1 "test/principles.xml1"}
{Inspect done}
