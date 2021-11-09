declare
[TreesParser] = {Module.link ['TreesParser.ozf']}
TreesRec#FamiliesRec = {TreesParser.parse}
%{Inspect TreesRec}
%{Inspect FamiliesRec}
%
[SyntaxParser] = {Module.link ['SyntaxParser.ozf']}
SyntaxRec = {SyntaxParser.parse}
%{Inspect SyntaxRec}
%
fun {NoDoubles Xs}
   {FoldL Xs fun {$ AccXs X}
		if {Member X AccXs} then
		   AccXs
		else
		   {Append AccXs [X]}
		end
	     end nil}
end
%%
SyntaxRec1 =
{Record.map SyntaxRec
 fun {$ Recs}
    As =
    for Rec in Recs append:Append do
       As = Rec.trees
       As1 =
       for A in As append:Append do
	  if {HasFeature FamiliesRec A} then
	     {Append FamiliesRec.A}
	  else
	     {Append [A]}
	  end
       end
    in
       {Append As1}
    end
 in
    {NoDoubles As}
 end}
%{Inspect SyntaxRec1}

declare
I#A =
{Record.foldLInd SyntaxRec1
 fun {$ A AccI#A1 As}
%    {Show A}
    I = {Length As}
 in
    if I>100 then {Show I#A} end
    if I>AccI then
       I#A
    else
       AccI#A1
    end
 end 0#o}
%{Inspect I#A}
