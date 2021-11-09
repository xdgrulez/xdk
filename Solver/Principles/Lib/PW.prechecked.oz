%%
%%  Module PW.prechecked
%%
%%  This module exports all the basic so-called "prechecked" PW predicates,
%%  i.e. those performing some basic determinacy checks to avoid creating
%%  some of the propagators otherwise required by their full semantics.
%%
%%  A prechecked predicate will normally return its result in an indirect
%%  form: either a record trivial(X), where X is the actual result, or a
%%  procedure P, where {P} yields the result. The first form - trivial(X) -
%%  means that the result X doesn't really involve creating any propagators
%%  whatsoever and whould probably not be worth memoizing.
%%
%%  The whole point of this module is allowing memoization to be optional
%%  while avoiding (i) code duplication (i.e. a whole new version of PW.base)
%%  and (ii) memoizing trivial results. When memoization is off, all predicates
%%  in this module return values already in "dechecked" form (i.e. actual
%%  results, not as trivial(X) records or procedures). This happens after
%%  exported feature decheckOn is called. When memoization is on, the return
%%  values are not dechecked. Some of them will pass unchanged through the
%%  predicates in PW.base.oz and will reach CPKit.memo.oz. There they will
%%  be memoized only if they are not trivial _and_ any procedure yielding
%%  non-trivial results will be called only if the corresponding result has
%%  not yet been memoized.
%%
functor
import
   Opti(isIn:OptiIsIn) at 'Opti.ozf'
   FS at 'FS.ozf'
   FD at 'FD.ozf'
   Memo(decheck:RealDecheck) at 'Memoizer.ozf'
   Space
   Service
export
   PrecheckOn
   PrecheckOff
   DecheckOn
   DecheckOff
   decheck:ApplyPubDecheck
   recheck:ApplyPrivDecheck
   Conj
   Disj
   Impl
   Equi
   In
   Notin
   BoolDotSet
   IfThenElseSet
   Zero
   One
   ZeroOrOne
   OneOrMore
define
   %%
   %%  Decheck control: allows switching memoization on/off
   %%
   local
      fun {Id X} X end
      PrivDecheck = {NewCell RealDecheck}
      PubDecheck = {NewCell Id}
      proc {DecheckOnGlobal}
	 PrivDecheck := RealDecheck
	 PubDecheck := Id
      end
      proc {DecheckOffGlobal}
	 PrivDecheck := Id
	 PubDecheck := RealDecheck
      end
   in
      DecheckOn = {Service.synchronous.newProc DecheckOnGlobal}
      DecheckOff = {Service.synchronous.newProc DecheckOffGlobal}
      fun {ApplyPubDecheck X} {@PubDecheck X} end
      fun {ApplyPrivDecheck X} {@PrivDecheck X} end
   end
   Decheck = ApplyPrivDecheck
   %%
   %%  Precheck control: allows switching prechecking on/off
   %%
   local
      IsDetC = {NewCell IsDet}
      OptiIsInC = {NewCell OptiIsIn}
      fun {ConstFalse _} false end
      fun {ConstUnknown _ _} unknown end
      proc {PrecheckOnGlobal}
	 IsDetC := IsDet
	 OptiIsInC := OptiIsIn
      end
      proc {PrecheckOffGlobal}
	 IsDetC := ConstFalse
	 OptiIsInC := ConstUnknown
      end
   in
      PrecheckOn = {Service.synchronous.newProc PrecheckOnGlobal}
      PrecheckOff = {Service.synchronous.newProc PrecheckOffGlobal}
      fun {CondIsDet X} {@IsDetC X} end
      fun {CondOptiIsIn D M} {@OptiIsInC D M} end
   end
   %%
   local
      fun {MergeAfterStable S}
	 {Space.ask S _}
	 {Space.merge S}
      end
   in
      fun {MakeSet Spec}
	 {MergeAfterStable {Space.new fun {$} {FS.value.make Spec} end}}
      end
   end
   %%
   fun {Conj D1 Proc}
      R = if {CondIsDet D1} then
	     case D1
	     of 1 then Proc
	     [] 0 then trivial(0)
	     end
	  else
	     D2 = {Proc}
	  in
	     if {CondIsDet D2} then
		case D2
		of 1 then trivial(D1)
		[] 0 then trivial(0)
		end
	     else
		fun {$} {FD.conj D1 D2} end
	     end
	  end
   in
      {Decheck R}
   end
   %%
   fun {Disj D1 Proc}
      R = if {CondIsDet D1} then
	     case D1
	     of 1 then trivial(1)
	     [] 0 then Proc
	     end
	  else
	     D2 = {Proc}
	  in
	     if {CondIsDet D2} then
		case D2
		of 1 then trivial(1)
		[] 0 then trivial(D1) 
		end
	     else
		fun {$} {FD.disj D1 D2} end
	     end
	  end
   in
      {Decheck R}
   end
   %%
   fun {Impl D1 Proc}
      R = if {CondIsDet D1} then
	     case D1
	     of 1 then Proc
	     [] 0 then trivial(1)
	     end
	  else
	     D2 = {Proc}
	  in
	     if {CondIsDet D2} then
		case D2
		of 1 then trivial(1)
		[] 0 then fun {$} {FD.nega D1} end
		end
	     else
		fun {$} {FD.impl D1 D2} end
	     end
	  end
   in
      {Decheck R}
   end
   %%
   fun {Equi D1 Proc}
      R = if {CondIsDet D1} then
	     case D1
	     of 1 then Proc
	     [] 0 then fun {$} {FD.nega {Proc}} end
	     end
	  else
	     D2 = {Proc}
	  in
	     if {CondIsDet D2} then
		case D2
		of 1 then trivial(D1)
		[] 0 then fun {$} {FD.nega D1} end
		end
	     else
		fun {$} {FD.equi D1 D2} end
	     end
	  end
   in
      {Decheck R}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Set connectives
   fun {In D M}
      R = case {CondOptiIsIn D M}
	  of 'in' then trivial(1)
	  [] out then trivial(0)
	  [] unknown then fun {$} {FS.reified.include D M} end
	  end
   in
      {Decheck R}
   end
   %%
   fun {Notin D M}
      R = case {CondOptiIsIn D M}
	  of 'in' then trivial(0)
	  [] out then trivial(1)
	  [] unknown then fun {$} {FD.nega {FS.reified.include D M}} end
	  end
   in
      {Decheck R}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% BoolDotSet: B -> M -> MOrEmpty - "multiplies" set M by
   %% FD boolean B. If B is 1 then MOrEmpty = M else MOrEmpty =
   %% Empty.
   %%
   local
      fun {IsEmpty M} {FD.reified.equal {FS.card M} 0} end
      Empty = FS.value.empty
   in
      fun {BoolDotSet B M}
	 R = if {CondIsDet B} then
		case B
		of 1 then trivial(M)
		[] 0 then trivial(Empty) end
	     else proc {$ M1}
		     MIsEmpty = {IsEmpty M}
		  in
		     M1 = {FS.var.decl}
		     {FS.subset M1 M}
		     {IsEmpty M1 {FD.disj {FD.nega B} MIsEmpty}} 
		     {FS.reified.subset M M1 {FD.disj B MIsEmpty}}
		  end
	     end
      in
	 {Decheck R}
      end
   end
   fun {IfThenElseSet B M1 M2}
      R = if {CondIsDet B} then
	     case B
	     of 1 then trivial(M1)
	     [] 0 then trivial(M2) end
	  else proc {$ M3}
		  AllEqual = {FS.reified.equal M1 M2}
	       in
		  M3 = {FS.var.decl}
		  {FS.subset M3 {FS.union M1 M2}}
		  {FS.subset {FS.intersect M1 M2} M3}
		  {FS.reified.equal M3 M1
		   {FD.disj AllEqual B}}
		  {FS.reified.equal M3 M2
		   {FD.disj AllEqual {FD.nega B}}}
	       end
	  end
   in
      {Decheck R}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Set cardinality constraints
   %%
   fun {MkCheckArityIn Vals Proc}
      Dom = {MakeSet Vals}
   in
      fun {$ S}
	 Card = {FS.card S}
	 R = case {CondOptiIsIn Card Dom}
	     of 'in' then trivial(1)
	     [] out then trivial(0)
	     [] unknown then fun {$} {Proc Card} end
	     end
      in
	 {Decheck R}
      end
   end

   fun {MkCheckArityNotIn Vals Proc}
      Dom = {MakeSet Vals}
   in
      fun {$ S}
	 Card = {FS.card S}
	 R = case {CondOptiIsIn Card Dom}
	     of 'in' then trivial(0)
	     [] out then trivial(1)
	     [] unknown then fun {$} {Proc Card} end
	     end
      in
	 {Decheck R}
      end
   end

   fun {MkArityEqual Val}
      {MkCheckArityIn [Val] fun {$ D} {FD.reified.equal D Val} end}
   end
   
   One = {MkArityEqual 1}
   Zero = {MkArityEqual 0}
   ZeroOrOne = {MkCheckArityIn [0 1]
		fun {$ D} {FD.reified.lesseq D 1} end}
   OneOrMore = {MkCheckArityNotIn [0]
		fun {$ D} {FD.reified.greatereq D 1} end}
end
