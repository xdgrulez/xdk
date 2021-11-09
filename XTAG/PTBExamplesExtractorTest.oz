declare
[PTBExamplesExtractor] = {Module.link ['PTBExamplesExtractor.ozf']}
SITups = {PTBExamplesExtractor.extract 'Corpora/wsj_2380.pos' false}
%SITups = {PTBExamplesExtractor.extract 'Corpora/wsj_23.pos' false}
for S#I in SITups do {Inspect {String.toAtom S}#I} end
