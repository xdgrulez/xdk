%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FS(inf sup value)

   Share(apply) at 'Share.ozf'
export
   Inf
   Sup

   Card
   CardRange
   Compl
   ComplIn
   Diff
   Disjoint
   DisjointN
   Distinct
   DistinctN
   Distribute
   Exclude
   ForAllIn
   Include
   Intersect
   IntersectN
   IsIn
   MakeWeights
   MonitorIn
   MonitorOut
   Partition
   Subset
   Subseteq
   Union
   UnionN

   Int
   Reflect
   Reified
   Value
   Var

   Equal
define
   Inf = FS.inf
   Sup = FS.sup
   %%
   proc {Card Arg1 Arg2} {Share.apply 'FS' [card] [Arg1#fs Arg2#fd]} end
   proc {CardRange Arg1 Arg2 Arg3} {Share.apply 'FS' [cardRange] [Arg1 Arg2 Arg3#fs]} end
   proc {Compl Arg1 Arg2} {Share.apply 'FS' [compl] [Arg1#fs Arg2#fs]} end
   proc {ComplIn Arg1 Arg2 Arg3} {Share.apply 'FS' [complIn] [Arg1#fs Arg2#fs Arg3#fs]} end
   proc {Diff Arg1 Arg2 Arg3} {Share.apply 'FS' [diff] [Arg1#fs Arg2#fs Arg3#fs]} end
   proc {Disjoint Arg1 Arg2} {Share.apply 'FS' [disjoint] [Arg1#fs Arg2#fs]} end
   proc {DisjointN Arg1} {Share.apply 'FS' [disjointN] [Arg1#vec(fs)]} end
   proc {Distinct Arg1 Arg2} {Share.apply 'FS' [distinct] [Arg1#fs Arg2#fs]} end
   proc {DistinctN Arg1} {Share.apply 'FS' [distinctN] [Arg1#vec(fs)]} end
   proc {Distribute Arg1 Arg2} {Share.apply 'FS' [distribute] [Arg1 Arg2#list(fs)]} end
   proc {Exclude Arg1 Arg2} {Share.apply 'FS' [exclude] [Arg1#fd Arg2#fs]} end
   proc {ForAllIn Arg1 Arg2} {Share.apply 'FS' [forallIn] [Arg1#fs Arg2]} end
   proc {Include Arg1 Arg2} {Share.apply 'FS' [include] [Arg1#fd Arg2#fs]} end
   proc {Intersect Arg1 Arg2 Arg3} {Share.apply 'FS' [intersect] [Arg1#fs Arg2#fs Arg3#fs]} end
   proc {IntersectN Arg1 Arg2} {Share.apply 'FS' [intersectN] [Arg1#vec(fs) Arg2#fs]} end
   proc {IsIn Arg1 Arg2 Arg3} {Share.apply 'FS' [isIn] [Arg1 Arg2#fs Arg3#fd]} end
   proc {MakeWeights Arg1 Arg2} {Share.apply 'FS' [makeWeights] [Arg1 Arg2]} end
   proc {MonitorIn Arg1 Arg2} {Share.apply 'FS' [monitorIn] [Arg1#fs Arg2]} end
   proc {MonitorOut Arg1 Arg2} {Share.apply 'FS' [monitorOut] [Arg1#fs Arg2]} end
   proc {Partition Arg1 Arg2} {Share.apply 'FS' [partition] [Arg1#vec(fs) Arg2#fs]} end
   proc {Subset Arg1 Arg2} {Share.apply 'FS' [subset] [Arg1#fs Arg2#fs]} end
   proc {Subseteq Arg1 Arg2} {Share.apply 'FS' [subseteq] [Arg1#fs Arg2#fs]} end
   proc {Union Arg1 Arg2 Arg3} {Share.apply 'FS' [union] [Arg1#fs Arg2#fs Arg3#fs]} end
   proc {UnionN Arg1 Arg2} {Share.apply 'FS' [unionN] [Arg1#vec(fs) Arg2#fs]} end
   %%
   Int =
   int(convex: proc {$ Arg1} {Share.apply 'FS' [int convex] [Arg1#fs]} end
       match: proc {$ Arg1 Arg2} {Share.apply 'FS' [int match] [Arg1#fs Arg2#vec(fd)]} end
       max: proc {$ Arg1 Arg2} {Share.apply 'FS' [int max] [Arg1#fs Arg2#fd]} end
       maxN: proc {$ Arg1 Arg2} {Share.apply 'FS' [int maxN] [Arg1#fs Arg2#vec(fd)]} end
       min: proc {$ Arg1 Arg2} {Share.apply 'FS' [int min] [Arg1#fs Arg2#fd]} end
       minN: proc {$ Arg1 Arg2} {Share.apply 'FS' [int minN] [Arg1#fs Arg2#vec(fd)]} end
       seq: proc {$ Arg1} {Share.apply 'FS' [int seq] [Arg1#vec(fs)]} end)
   %%
   Reflect =
   reflect(card: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect card] [Arg1#fs Arg2]} end
	   lowerBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect lowerBound] [Arg1#fs Arg2]} end
	   lowerBoundList: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect lowerBoundList] [Arg1#fs Arg2]} end
	   unknown: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect unknown] [Arg1#fs Arg2]} end
	   unknownList: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect unknownList] [Arg1#fs Arg2]} end
	   upperBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect upperBound] [Arg1#fs Arg2]} end
	   upperBoundList: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect upperBoundList] [Arg1#fs Arg2]} end
	   %%
	   cardOf: cardOf(lowerBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect cardOf lowerBound] [Arg1#fs Arg2]} end
			  unknown: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect cardOf unknown] [Arg1#fs Arg2]} end
			  upperBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [reflect cardOf upperBound] [Arg1#fs Arg2]} end))
   %%
   Reified =
   reified(areIn: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified areIn] [Arg1 Arg2#fs Arg3#list(fdbool)]} end
	   bounds: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FS' [reified bounds] [Arg1 Arg2 Arg3 Arg4 Arg5#fdbool]} end % not documented in Mozart/Oz 1.3.2
	   boundsN: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FS' [reified boundsN] [Arg1 Arg2 Arg3 Arg4 Arg5#fdbool]} end % not documented in Mozart/Oz 1.3.2
	   equal: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified equal] [Arg1#fs Arg2#fs Arg3#fdbool]} end
	   notequal: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified notequal] [Arg1#fs Arg2#fs Arg3#fdbool]} end
	   include: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified include] [Arg1#fd Arg2#fs Arg3#fdbool]} end
	   isIn: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified isIn] [Arg1 Arg2#fs Arg3#fdbool]} end
	   partition: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FS' [reified partition] [Arg1#list(vec(fs)) Arg2 Arg3#vec(fs) Arg4#list(fdbool)]} end
	   %%
	   subset: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified subset] [Arg1#fs Arg2#fs Arg3#fdbool]} end
	   disjoint: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [reified subset] [Arg1#fs Arg2#fs Arg3#fdbool]} end)
   %%
   Value =
   value(empty: FS.value.empty
	 universal: FS.value.universal
	 is: proc {$ Arg1 Arg2} {Share.apply 'FS' [value is] [Arg1#fs Arg2]} end
	 make: proc {$ Arg1 Arg2} {Share.apply 'FS' [value make] [Arg1 Arg2#fs]} end
	 singl: proc {$ Arg1 Arg2} {Share.apply 'FS' [value singl] [Arg1 Arg2#fs]} end
	 toString: proc {$ Arg1 Arg2} {Share.apply 'FS' [value toString] [Arg1#fs Arg2]} end)
   %%
   Var =
   var(bounds: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var bounds] [Arg1 Arg2 Arg3#fs]} end
       decl: proc {$ Arg1} {Share.apply 'FS' [var decl] [Arg1#fs]} end
       is: proc {$ Arg1 Arg2} {Share.apply 'FS' [var is] [Arg1#fs Arg2]} end
       lowerBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [var lowerBound] [Arg1 Arg2#fs]} end
       upperBound: proc {$ Arg1 Arg2} {Share.apply 'FS' [var upperBound] [Arg1 Arg2#fs]} end
       %%
       list: list(bounds: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FS' [var list bounds] [Arg1 Arg2 Arg3 Arg4#list(fs)]} end
		  decl: proc {$ Arg1 Arg2} {Share.apply 'FS' [var list decl] [Arg1 Arg2#list(fs)]} end
		  lowerBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var list lowerBound] [Arg1 Arg2 Arg3#list(fs)]} end
		  upperBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var list upperBound] [Arg1 Arg2 Arg3#list(fs)]} end)
       record: record(bounds: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FS' [var record bounds] [Arg1 Arg2 Arg3 Arg4#rec(fs)]} end
		      decl: proc {$ Arg1 Arg2} {Share.apply 'FS' [var record decl] [Arg1 Arg2#rec(fs)]} end
		      lowerBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var record lowerBound] [Arg1 Arg2 Arg3#rec(fs)]} end
		      upperBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var record upperBound] [Arg1 Arg2 Arg3#rec(fs)]} end)
       tuple: tuple(bounds: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FS' [var tuple bounds] [Arg1 Arg2 Arg3 Arg4#tup(fs)]} end
		    decl: proc {$ Arg1 Arg2} {Share.apply 'FS' [var tuple decl] [Arg1 Arg2#tup(fs)]} end
		    lowerBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var tuple lowerBound] [Arg1 Arg2 Arg3#tup(fs)]} end
		    upperBound: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FS' [var tuple upperBound] [Arg1 Arg2 Arg3#tup(fs)]} end))
   %%
   proc {Equal Arg1 Arg2} {Share.apply 'FS' [equal] [Arg1#fs Arg2#fs]} end
end

