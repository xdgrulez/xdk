functor
import
%   System(show:Show)
   FD at 'FD.ozf'
   FS at 'FS.ozf'
   PW at 'PW.base.ozf'
   Memo at 'Memoizer.ozf'
   Prechk(decheckOff:DecheckOff) at 'PW.prechecked.ozf'
   System(onToplevel:OnToplevel)
export
   New
   Reset
prepare
   Reset = {NewName}
   proc {ApplyNullary P} {P} end
   V2A = VirtualString.toAtom
%   fun {Snd Tup} Tup.2 end
define
   fun {New}
      PW = {MkPW}
      FD = {MkFD PW}
      FS = {MkFS PW}
   in
      'exports'(fd:FD fs:FS pw:PW)
   end
   proc {CondReset PW}
      if {Not {OnToplevel}} then {PW.Reset} end
   end
   fun {MkFD PW}
      {AdjoinList FD
       [ distribute#proc {$ Arg1 Arg2}
		       {CondReset PW}
		       {FD.distribute Arg1 Arg2}
		    end
       ]}
   end
   fun {MkFS PW}
      {AdjoinList FS
       [ distribute#proc {$ Arg1 Arg2}
		       {CondReset PW}
		       {FS.distribute Arg1 Arg2}
		    end
       ]}
   end

   local
      fun {CheckIn PW}
	 proc {$ F#_}
	    if {Not {HasFeature PW F}} then
	       {Exception.raiseError memokit(type:missingFeature(F) msg:'PW.base.ozf does not export feature '#F)}
	    end
	 end
      end
   in
      proc {MkPW MemoPW}
	 MemoResets = {NewCell nil}
	 fun {Memoize Proc IndexDefs Precheck}
	    M = {Memo.new Proc IndexDefs Precheck}
	    MRs
	 in
	    MRs = (MemoResets := M.reset|MRs)
	    M.proxy
	 end
	 proc {ResetProc}
	    {ForAll @MemoResets ApplyNullary}
	 end
	 fun {MemoPWDot Feat} thread MemoPW.Feat end end
	 InterPW = {Adjoin {PW.mkDyn MemoPWDot} PW}
	 DeltaList = {Flatten {MkMemoList InterPW Memoize}}
      in
	 {ForAll DeltaList {CheckIn InterPW}}
	 MemoPW = {AdjoinList InterPW (Reset#ResetProc)|DeltaList}
 	 {DecheckOff}
      end
   end
   
   X = '"'
   fun {DotIndex X} X.index end
   fun {Ind I} app(DotIndex I) end
   fun {Atm X} app(V2A X) end
   
   VVLD = [{Atm 4#X#{Ind 1}#X#3#X#{Ind 2}}]
   VVD = [{Atm 3#X#{Ind 1}#X#{Ind 2}}]
   VV = [{Atm {Ind 1}#X#{Ind 2}}]
   VLD = [{Atm 3#X#2#X#{Ind 1}}]
   VXLD = [{Atm 4#X#3#X#{Ind 1}}]
   VD = [{Atm 2#X#{Ind 1}}]
%   VLLD = [{Atm 4#X#3#X#2#X#{Ind 1}}]
   VXLLD = [{Atm 5#X#4#X#3#X#{Ind 1}}]
%   XD = [{Atm app(Snd 1#2)}]
   XD = [{Atm 2}]
   
   fun {MkMem PW Memoize}
      fun {Mem IndexDefs Prechecked Feat}
	 Feat#{Memoize PW.Feat IndexDefs Prechecked}
      end
      fun {Mems IndexDefs Prechecked Feats}
	 {Map Feats fun {$ F} {Mem IndexDefs Prechecked F} end}
      end
   in
      Mem#Mems
   end

   fun {MkMemoList PW Memoize}
      Mem#Mems = {MkMem PW Memoize}
   in
      [
       {Mems VVLD true
	[ 
	 ledge
	 ldom
	]}
       {Mems VVD true
	[
	 edge
	 dom
	 domeq
	 xedge
	 xdom
	]}
       {Mem VV false prec}
       {Mem XD false projective}
       {Mems VLD true
	[
	 oneMotherL
	 zeroOrOneMothersL
	 oneOrMoreMothersL
	 zeroMothersL
	 oneDaughterL
	 zeroOrOneDaughtersL
	 oneOrMoreDaughtersL
	 zeroDaughtersL
	]}
       {Mems VXLD false
	[
	 eqPrecDaughtersL
	 daughtersLPrecEq
	]}
       {Mems VD true
	[
	 oneMother
	 zeroOrOneMothers
	 oneOrMoreMothers
	 zeroMothers
	 oneDaughter
	 zeroOrOneDaughters
	 oneOrMoreDaughters
	 zeroDaughters
	]}
       {Mems VD false
	[
	 disjointDaughtersL
	 disjointSubtreesL
	]}
       {Mem VXLLD false daughtersLPrecDaughtersL}
      ]
   end
end

