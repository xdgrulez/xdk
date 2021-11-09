declare
PortI = 4712
[GrammarGenerator] = {Link ['../XTAG/GrammarGenerator.ozf']}
GrammarV = {GrammarGenerator.generate ['a' 'man' 'who' 'sleeps'] true simple}
{Inspect {VirtualString.toAtom GrammarV}}
{Inspect {Length {VirtualString.toString GrammarV}}}
