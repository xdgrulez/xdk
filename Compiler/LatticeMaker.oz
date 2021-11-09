%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   
   Flat(make) at 'Lattices/Flat.ozf'
   Domain(make) at 'Lattices/Domain.ozf'
   Tuple(make) at 'Lattices/Tuple.ozf'
   Set(make) at 'Lattices/Set.ozf'
   Record1(make) at 'Lattices/Record.ozf'
   List1(make) at 'Lattices/List.ozf'
   Card(make) at 'Lattices/Card.ozf'
   Int1(make) at 'Lattices/Int.ozf'
   String1(make) at 'Lattices/String.ozf'
export
   MakeTnLatRec
prepare
   RecordMap = Record.map
   RecordMapInd = Record.mapInd
define
   fun {MakeTnLatRec TnTypeRec}
      fun {MakeTnLatRec1 Tn}
	 if {Not {HasFeature TnTypeRec Tn}} then
	    raise error1('functor':'Compiler/LatticeMaker.ozf' 'proc':'MakeTnLatRec1' msg:'Type record does not contain type name.' info:o(TnTypeRec Tn) coord:noCoord file:noFile) end
	 end
	 Type = TnTypeRec.Tn
      in
	 case Type
	 of elem(tag: 'type.domain'
		 args: Args) then
%	    {System.show domain#1}
	    X = {Domain.make Args}
	 in
%	    {System.show domain#2}
	    X
	 [] elem(tag: 'type.set'
		 arg: Arg) then
%	    {System.show set#1}
	    Arg1 = {MakeTnLatRec1 Arg}
	    X = {Set.make Arg1 a}
	 in
%	    {System.show set#2}
	    X
	 [] elem(tag: 'type.iset'
		 arg: Arg) then
%	    {System.show iset#1}
	    Arg1 = {MakeTnLatRec1 Arg}
	    X = {Set.make Arg1 i}
	 in
%	    {System.show iset#2}
	    X
	 [] elem(tag: 'type.tuple'
		 args: Args) then
%	    {System.show tuple#1}
	    Args1 = {Map Args MakeTnLatRec1}
	    X = {Tuple.make Args1}
	 in
%	    {System.show tuple#2}
	    X
	 [] elem(tag: 'type.list'
		 arg: Arg) then
%	    {System.show list#1}
	    Arg1 = {MakeTnLatRec1 Arg}
	    X = {List1.make Arg1}
	 in
%	    {System.show list#2}
	    X
	 [] elem(tag: 'type.record'
		 args: Args) then
%	    {System.show record#1}
	    Args1 = {RecordMap Args MakeTnLatRec1}
	    X = {Record1.make Args1}
	 in
%	    {System.show record#2}
	    X
	 [] elem(tag: 'type.card') then
%	    {System.show card#1}
	    X = {Card.make}
	 in
%	    {System.show card#2}
	    X
	 [] elem(tag: 'type.int') then
%	    {System.show int#1}
	    X = {Int1.make}
	 in
%	    {System.show int#2}
	    X
	 [] elem(tag: 'type.string') then
%	    {System.show string#1}
	    X = {String1.make}
	 in
%	    {System.show string#2}	    
	    X
	 else
	    raise error1('functor':'Compiler/LatticeMaker.ozf' 'proc':'MakeTnLatRec1' msg:'Illformed type.' info:o(Type) coord:noCoord file:noFile) end
	     end
      end
      TnLatRec = {RecordMapInd TnTypeRec
		  fun {$ Tn _} {MakeTnLatRec1 Tn} end}
   in
      TnLatRec
   end
end
