declare
[Domain] = {Module.link ['Compiler/Lattices/Domain.ozf']}
[Tuple1] = {Module.link ['Compiler/Lattices/Tuple.ozf']}
[Set] = {Module.link ['Compiler/Lattices/Set.ozf']}
Lat1 = {Domain.make [1 2 3]}
Lat2 = {Domain.make [1 2 3]}
Lat3 = {Domain.make [subj obj]}
Lat4 = {Tuple1.make [Lat1 Lat2 Lat3]}
Lat5 = {Set.make Lat4 a}
