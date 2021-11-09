declare
[SyntaxParser] = {Module.link ['SyntaxParser.ozf']}
SyntaxRec = {SyntaxParser.parse}
{Inspect SyntaxRec}

{Record.forAllInd SyntaxRec
 proc {$ A Recs}
    for Rec in Recs do
       if {Member 'Ts0Vs1' Rec.trees} then {Show A} end
    end
 end}
/*
betaCONJs:
','
and
both
but
but
either
nor
'or'
providing
seeing
to

Ts0Vs1:
made
made
make
make
make
makes
making
*/
