%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   DictUtils(deepAccess:DeepAccess condPut:CondPut) at 'DictUtils.ozf'
   Memoizer(mkNew:MkNewMemo) at 'Memoizer.ozf'
%   Ozcar(breakpoint:BP)
export
   New
prepare
   RMap = Record.map
   RMapInd = Record.mapInd
   RForAll = Record.forAll
   RClone = Record.clone
   R2L = Record.toList
   D2R = Dictionary.toRecord
   DCondGet = Dictionary.condGet
   MakeNeeded = Value.makeNeeded
   Term = {NewName}
   TermL = [Term]
   TermInfoA = {NewName}
   NOP = {NewName}
define
   fun {Const X} fun {$ _} X end end
   fun {Snd X} X.2 end
   fun {Fst X} X.1 end

   Failed = {Value.failed {Exception.error collectiveMemo(doubleDefinition)}}
   proc {Skip _} skip end
   
   local
      fun {ParAccess L Arg Def D0 K I T|Ts P|Ps}
	 D1 = if T == NOP then D0 else
		 if {IsFree D0} then D0 = {Protect L T} end
		 D0.P
	      end
      in
	 if P == Term then D1 else
	    PDef = Def.P
	 in
	    if {IsFree D1} then NextSynch Synch = L := NextSynch in
	       {Wait Synch}
	       if {IsFree D1} then D1 = {PDef.new Arg P K I} end
	       NextSynch = Synch
	    end
	    {ParAccess L Arg Def {PDef.dot Arg P D1 K K.I} K I+1 Ts Ps}
	 end
      end
   in
      fun {MkParAccess Def Tmpls Path}
	 fun {$ L Arg D K}
	    {ParAccess L Arg Def D K 1 Tmpls Path}
	 end
      end
   end

   proc {Protect L Proc R}
      NextSynch
      Synch = L := NextSynch
   in
      {Wait Synch}
      if {IsFree R} then {Proc R} end
      NextSynch = Synch
   end
   
   fun {MkLookup TermInfo MyId}
      ParAccess = TermInfo.access
      ParTempl = TermInfo.templ
   in
      proc {$ L Arg DCell K IsNew V}
	 ParD = {ParAccess L Arg @DCell K}
      in
	 V = if ParTempl == NOP then ParD else
		if {IsFree ParD} then ParD = {Protect L ParTempl} end
		ParD.MyId
	     end
	 if {IsNeeded V} then
	    IsNew = false
	 else
	    IsNew = true
	    {MakeNeeded V}
	 end
      end
   end

   fun {Inc Cell}
      New
      Old = Cell := New
   in
      New = Old + 1
      New
   end
   
   fun {New Def}
      MemoD = {NewDictionary}
      DefD = {NewDictionary}
      proc {Add MyId Proc IndexPathDef Precheck}
	 ParPath = {Append {R2L {RMap IndexPathDef Fst}} TermL}
	 IndexDef = {RMap IndexPathDef Snd}
	 PathD = {DeepAccess DefD ParPath}
	 TermInfo
      in
	 if {IsFree PathD} then
	    PathD = {NewDictionary}
	    PathD.TermInfoA := (TermInfo = o(access:_ templ:_ path:ParPath count:{NewCell 0}))
	 else TermInfo = PathD.TermInfoA end
	 {CondPut MemoD MyId} = o(lookup:{MkLookup TermInfo {Inc TermInfo.count}}
				  'proc':Proc
				  idef:IndexDef
				  precheck:Precheck
				  guard:Failed)
      end
      local
	 ConstUnit = {Const unit}
	 proc {FixParAccess D Ts}
	    TermInfo = {DCondGet D TermInfoA unit}
	    T NextTs = T|Ts
	 in
	    if TermInfo \= unit then W = @(TermInfo.count) in
	       T = if W == 1 then NOP else fun {$} {MakeTuple '#' W} end end
	       TermInfo.templ = T
	       TermInfo.access = {MkParAccess Def {Reverse NextTs}
				  TermInfo.path}
	    else Rec = {D2R o D} in
	       T = if {Width Rec} > 1 then TRec = {RMap Rec ConstUnit} in
		      fun {$} {RClone TRec} end
		   else NOP end
	       {RForAll Rec proc {$ SubD}
			       {FixParAccess SubD NextTs}
			    end}
	    end
	 end
      in
	 fun {Compile}
	    Id2MemoInfo = {D2R 'export' MemoD}
	 in
	    {FixParAccess DefD nil}
	    fun {$ Arg}
	       D = {NewCell _}
	       L = {NewCell unit}
	       fun {YieldD} D end
	       fun {MkDict MyId} Lookup = Id2MemoInfo.MyId.lookup in
		  o(new:YieldD
		    removeAll:Skip
		    lookup:proc {$ D K IsNew V} {Lookup L Arg D K IsNew V} end)
	       end
	       proc {Reset} D := _ end
	    in
	       o(memos:{RMapInd Id2MemoInfo
			fun {$ MyId Info}
			   {{MkNewMemo {MkDict MyId}} Info.'proc' Info.idef Info.precheck}.proxy
			end}
		 reset:Reset
		 d:D)
	    end
	 end
      end
   in
      o(add:Add compile:Compile)
   end
end
  