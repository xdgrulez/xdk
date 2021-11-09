%%
%%  Module Helpers
%%
%%  Exports common utilities.
%%
functor
import
   Counter(newFromInt:NewCounter) at 'x-oz://system/adt/Counter.ozf'
export
   Push
   PushUnique
   UpdateCell
   MkAccum
   MkNewAtom
   Index
prepare
   VS2A = VirtualString.toAtom
   Partition = List.partition
define
   %%
   %% Push: X -> Xs -> Ys - Ys is Xs including X.
   fun {Push X Xs} X|Xs end
   %%
   %% PushUnique: X -> Xs -> Ys - Ys is Xs including X. If X is already
   %% in Xs, Ys = Xs.
   fun {PushUnique X Xs}
      if {Member X Xs} then Xs else X|Xs end
   end
   %%
   %% UpdateCell: C -> X -> Updater - atomically updates the value
   %% of C to {Updater X @C}.
   proc {UpdateCell C X Updater}
      New
      Old = C := New
   in
      New = {Updater X Old}
   end
   %%
   %% MkAccum: Zero -> AccumF -> Accum - creates an accumulator
   %% initialized to Zero and updatable by AccumF.
   fun {MkAccum Zero AccumF}
      C = {NewCell Zero}
      proc {Accum X} {UpdateCell C X AccumF} end
   in
      o(accum:Accum access:fun {$} @C end)
   end

   %%
   %% MkNewAtom: BaseVS -> StartI -> NewAtom - creates a nullary function
   %% NewAtom returning a "fresh" atom at each call, by juxtaposing
   %% virtual string BaseVS with integers starting from StartI.
   %% 
   fun {MkNewAtom BaseVS StartI}
      C = {NewCounter StartI}
   in
      fun {$} {VS2A BaseVS#{C.next}} end
   end

   %%
   %% Index: L -> MkKey -> MkVal -> Groups - organizes the elements
   %% of L into groups of the form Key#Values, where each V in Values
   %% is obtained by {MkVal E} for an unique element in L such that
   %% Key == {MkKey E}.
   %% 
   fun {Index L MkKey MkVal}
      case L
      of nil then nil
      [] X|Xs then
	 XKey = {MkKey X}
	 Grouped
	 Others = {Partition Xs fun {$ Y} XKey == {MkKey Y} end
		   Grouped}
      in
	 ({MkKey X}#{Map X|Grouped MkVal})|{Index Others MkKey MkVal}
      end
   end
end