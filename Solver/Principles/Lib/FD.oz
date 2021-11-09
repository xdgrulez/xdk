%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD(inf sup)

   Share(apply) at 'Share.ozf'
export
   Inf
   Sup

   Assign
   AtLeast
   AtMost
   Bool
   Choose
   Conj
   Decl
   Disj
   Disjoint
   DisjointC
   Distance
   Distinct
   Distinct2
   DistinctB
   DistinctD
   DistinctOffset
   Distribute
   DivD DivI
   Dom
   Element
   Equi
   Exactly
   Exor
   Greater
   Greatereq
   Impl
   Int
   Is
   Less
   Lesseq
   List
   Max
   Min
   Minus
   MinusD
   ModD
   ModI
   Nega
   Plus
   PlusD
   Power
   Record
   Sum
   SumAC
   SumACN
   SumC
   SumCD
   SumCN
   SumD
   TasksOverlap
   Times
   TimesD
   Tuple

   Reflect
   Reified
   Watch

   Equal
   NotEqual
define
   Inf = FD.inf
   Sup = FD.sup
   %%
   proc {Assign Arg1 Arg2} {Share.apply 'FD' [assign] [Arg1 Arg2]} end
   proc {AtLeast Arg1 Arg2 Arg3} {Share.apply 'FD' [atLeast] [Arg1#fd Arg2#vec(fd) Arg3]} end
   proc {AtMost Arg1 Arg2 Arg3} {Share.apply 'FD' [atMost] [Arg1#fd Arg2#vec(fd) Arg3]} end
   proc {Bool Arg1} {Share.apply 'FD' [bool] [Arg1#fd]} end
   proc {Choose Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [choose] [Arg1 Arg2 Arg3 Arg4]} end
   proc {Conj Arg1 Arg2 Arg3} {Share.apply 'FD' [conj] [Arg1#fdbool Arg2#fdbool Arg3#fdbool]} end
   proc {Decl Arg1} {Share.apply 'FD' [decl] [Arg1#fd]} end
   proc {Disj Arg1 Arg2 Arg3} {Share.apply 'FD' [disj] [Arg1#fdbool Arg2#fdbool Arg3#fdbool]} end
   proc {Disjoint Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [disjoint] [Arg1#fd Arg2 Arg3#fd Arg4]} end
   proc {DisjointC Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [disjointC] [Arg1#fd Arg2 Arg3#fd Arg4 Arg5#fd]} end
   proc {Distance Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [distance] [Arg1#fd Arg2#fd Arg3 Arg4#fd]} end
   proc {Distinct Arg1} {Share.apply 'FD' [distinct] [Arg1#vec(fd)]} end
   proc {Distinct2 Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [distinct2] [Arg1#fd Arg2 Arg3#fd Arg4]} end
   proc {DistinctB Arg1} {Share.apply 'FD' [distinctB] [Arg1#vec(fd)]} end
   proc {DistinctD Arg1} {Share.apply 'FD' [distinctD] [Arg1#vec(fd)]} end
   proc {DistinctOffset Arg1 Arg2} {Share.apply 'FD' [distinctOffset] [Arg1#vec(fd) Arg2]} end
   proc {Distribute Arg1 Arg2} {Share.apply 'FD' [distribute] [Arg1 Arg2#vec(fd)]} end
   proc {DivD Arg1 Arg2 Arg3} {Share.apply 'FD' [divD] [Arg1#fd Arg2 Arg3#fd]} end
   proc {DivI Arg1 Arg2 Arg3} {Share.apply 'FD' [divI] [Arg1#fd Arg2 Arg3#fd]} end
   proc {Dom Arg1 Arg2} {Share.apply 'FD' [dom] [Arg1 Arg2#vec(fd)]} end
   proc {Element Arg1 Arg2 Arg3} {Share.apply 'FD' [element] [Arg1#fd Arg2 Arg3#fd]} end
   proc {Equi Arg1 Arg2 Arg3} {Share.apply 'FD' [equi] [Arg1#fdbool Arg2#fdbool Arg3#fdbool]} end
   proc {Exactly Arg1 Arg2 Arg3} {Share.apply 'FD' [exactly] [Arg1#fd Arg2#vec(fd) Arg3]} end
   proc {Exor Arg1 Arg2 Arg3} {Share.apply 'FD' [exor] [Arg1#fdbool Arg2#fdbool Arg3#fdbool]} end
   proc {Greater Arg1 Arg2} {Share.apply 'FD' [greater] [Arg1#fd Arg2#fd]} end
   proc {Greatereq Arg1 Arg2} {Share.apply 'FD' [greatereq] [Arg1#fd Arg2#fd]} end
   proc {Impl Arg1 Arg2 Arg3} {Share.apply 'FD' [impl] [Arg1#fdbool Arg2#fdbool Arg3#fdbool]} end
   proc {Int Arg1 Arg2} {Share.apply 'FD' [int] [Arg1 Arg2#fd]} end
   proc {Is Arg1 Arg2} {Share.apply 'FD' [is] [Arg1#fd Arg2]} end
   proc {Less Arg1 Arg2} {Share.apply 'FD' [less] [Arg1#fd Arg2#fd]} end
   proc {Lesseq Arg1 Arg2} {Share.apply 'FD' [lesseq] [Arg1#fd Arg2#fd]} end
   proc {List Arg1 Arg2 Arg3} {Share.apply 'FD' [list] [Arg1 Arg2 Arg3#list(fd)]} end
   proc {Max Arg1 Arg2 Arg3} {Share.apply 'FD' [max] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {Min Arg1 Arg2 Arg3} {Share.apply 'FD' [min] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {Minus Arg1 Arg2 Arg3} {Share.apply 'FD' [minus] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {MinusD Arg1 Arg2 Arg3} {Share.apply 'FD' [minusD] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {ModD Arg1 Arg2 Arg3} {Share.apply 'FD' [modD] [Arg1#fd Arg2 Arg3#fd]} end
   proc {ModI Arg1 Arg2 Arg3} {Share.apply 'FD' [modI] [Arg1#fd Arg2 Arg3#fd]} end
   proc {Nega Arg1 Arg2} {Share.apply 'FD' [nega] [Arg1#fdbool Arg2#fdbool]} end
   proc {Plus Arg1 Arg2 Arg3} {Share.apply 'FD' [plus] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {PlusD Arg1 Arg2 Arg3} {Share.apply 'FD' [plusD] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {Power Arg1 Arg2 Arg3} {Share.apply 'FD' [power] [Arg1#fd Arg2 Arg3#fd]} end
   proc {Record Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [record] [Arg1 Arg2 Arg3 Arg4#rec(fd)]} end
   proc {Sum Arg1 Arg2 Arg3} {Share.apply 'FD' [sum] [Arg1#vec(fd) Arg2 Arg3#fd]} end
   proc {SumAC Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [sumAC] [Arg1 Arg2#vec(fd) Arg3 Arg4#fd]} end
   proc {SumACN Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [sumACN] [Arg1 Arg2#vec(vec(fd)) Arg3 Arg4#fd]} end
   proc {SumC Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [sumC] [Arg1 Arg2#vec(fd) Arg3 Arg4#fd]} end
   proc {SumCD Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [sumCD] [Arg1 Arg2#vec(fd) Arg3 Arg4#fd]} end
   proc {SumCN Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [sumCN] [Arg1 Arg2#vec(vec(fd)) Arg3 Arg4#fd]} end
   proc {SumD Arg1 Arg2 Arg3} {Share.apply 'FD' [sumD] [Arg1#vec(fd) Arg2 Arg3#fd]} end
   proc {TasksOverlap Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [tasksOverlap] [Arg1#fd Arg2 Arg3#fd Arg4 Arg5#fd]} end
   proc {Times Arg1 Arg2 Arg3} {Share.apply 'FD' [times] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {TimesD Arg1 Arg2 Arg3} {Share.apply 'FD' [timesD] [Arg1#fd Arg2#fd Arg3#fd]} end
   proc {Tuple Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [tuple] [Arg1 Arg2 Arg3 Arg4#tup(fd)]} end
   %%
   Reflect =
   reflect(dom: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect dom] [Arg1#fd Arg2]} end
	   domList: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect domList] [Arg1#fd Arg2#list(fd)]} end
	   max: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect max] [Arg1#fd Arg2#fd]} end
	   mid: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect mid] [Arg1#fd Arg2#fd]} end
	   min: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect min] [Arg1#fd Arg2#fd]} end
	   nbSusps: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect nbSusps] [Arg1#fd Arg2]} end
	   nextLarger: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reflect nextLarger] [Arg1#fd Arg2#fd Arg3#fd]} end
	   nextSmaller: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reflect nextSmaller] [Arg1#fd Arg2#fd Arg3#fd]} end
	   size: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect size] [Arg1#fd Arg2#fd]} end
	   width: proc {$ Arg1 Arg2} {Share.apply 'FD' [reflect width] [Arg1 Arg2]} end) % not documented in Mozart/Oz 1.3.2
   %%
   Reified =
   reified(card: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [reified card] [Arg1#fd Arg2#vec(fd) Arg3#fd Arg4#fdbool]} end
	   distance: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [reified distance] [Arg1#fd Arg2#fd Arg3 Arg4#fd Arg5#fdbool]} end
	   dom: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified dom] [Arg1 Arg2#vec(fd) Arg3#fdbool]} end
	   int: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified int] [Arg1 Arg2#fd Arg3#fdbool]} end
	   sum: proc {$ Arg1 Arg2 Arg3 Arg4} {Share.apply 'FD' [reified sum] [Arg1#vec(fd) Arg2 Arg3#fd Arg4#fdbool]} end
	   sumAC: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [reified sumAC] [Arg1 Arg2#vec(fd) Arg3 Arg4#fd Arg5#fdbool]} end
	   sumACN: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [reified sumACN] [Arg1 Arg2#vec(vec(fd)) Arg3 Arg4#fd Arg5#fdbool]} end
	   sumC: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [reified sumC] [Arg1 Arg2#vec(fd) Arg3 Arg4#fd Arg5#fdbool]} end
	   sumCN: proc {$ Arg1 Arg2 Arg3 Arg4 Arg5} {Share.apply 'FD' [reified sumCN] [Arg1 Arg2#vec(vec(fd)) Arg3 Arg4#fd Arg5#fdbool]} end
	   %%
	   equal: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified equal] [Arg1#fd Arg2#fd Arg3#fdbool]} end
	   greater: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified greater] [Arg1#fd Arg2#fd Arg3#fdbool]} end
	   greatereq: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified greatereq] [Arg1#fd Arg2#fd Arg3#fdbool]} end
	   less: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified less] [Arg1#fd Arg2#fd Arg3#fdbool]} end
	   lesseq: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified lesseq] [Arg1#fd Arg2#fd Arg3#fdbool]} end
	   notequal: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [reified notequal] [Arg1#fd Arg2#fd Arg3#fdbool]} end)
   %%
   Watch =
   watch(max: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [watch max] [Arg1#fd Arg2#fd Arg3]} end
	 min: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [watch min] [Arg1#fd Arg2#fd Arg3]} end
	 size: proc {$ Arg1 Arg2 Arg3} {Share.apply 'FD' [watch size] [Arg1#fd Arg2#fd Arg3]} end)
   %%
   proc {Equal Arg1 Arg2} {Share.apply 'FD' [equal] [Arg1#fd Arg2#fd]} end
   proc {NotEqual Arg1 Arg2} {Share.apply 'FD' [notequal] [Arg1#fd Arg2#fd]} end
end
