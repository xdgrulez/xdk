%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show:Show)
   FD at 'FD.ozf'
   FS at 'FS.ozf'
   PW at 'PW.base.ozf'
   Memo at 'Memoizer.ozf'
%   Prechk(decheckOff:DecheckOff decheckOn:DecheckOn) at 'PW.prechecked.ozf'
   Prechk(decheckOff:DecheckOff) at 'PW.prechecked.ozf'
   System(onToplevel:OnToplevel)
export
   Prepare
   New
   Option
   Abstract
prepare
   V2A = VirtualString.toAtom
   Reset = {NewName}
   RForAll = Record.forAll
   RMap = Record.map
   RMapInd = Record.mapInd
define

   Option = 'noshared-atomized-dicts'
   Abstract = 'not shared - atomized keys - dicts (worst, legacy version)'

   Prechecked = true
   
   fun {Prepare G}
      unit
   end
   
   fun {New MemoSupport NodesI}
      PW = {MkPW MemoSupport NodesI}
      FD = {MkFD PW}
      FS = {MkFS PW}
   in
%      if Prechecked then {DecheckOff} else {DecheckOn} end
      {DecheckOff}
      'export'(fd:FD fs:FS pw:PW)
   end
   
   proc {CondReset PW}
      if {Not {OnToplevel}} then
	 {PW.Reset}
      end
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

   proc {CallReset M} {M.reset} end
   
   proc {MkPW _ NodesI MemoPW}
      Memos = {RMap MemoFacsRec fun {$ Proc#IDefs#Prechk} {NewMemo Proc IDefs Prechk} end}
      Proxies = {RMapInd Memos fun {$ F Memo} Memo.proxy end}
      proc {ResetProc} {RForAll Memos CallReset} end
   in
      MemoPW = {AdjoinAt {Adjoin PW Proxies} Reset ResetProc}
   end
   
   local
      fun {DotIndex X} X.index end
      fun {Ind I} app(DotIndex I) end
      X = '"'
      fun {Atm X} app(V2A X) end
   in
      VVLD = {Atm 4#X#{Ind 1}#X#3#X#{Ind 2}}
      VVD = {Atm 3#X#{Ind 1}#X#{Ind 2}}
      VV = {Atm {Ind 1}#X#{Ind 2}}
      VLD = {Atm 3#X#2#X#{Ind 1}}
      VXLD = {Atm ignore(2 4)#X#3#X#{Ind 1}}
      VD = {Atm 2#X#{Ind 1}}
      VXLLD = {Atm ignore(2 5)#X#4#X#3#X#{Ind 1}}
      XD = {Atm ignore(1 2)}
   end

   MemoFacs = {NewCell nil}
   
   proc {Mem IndexDefs Precheck Feat}
      MemoFac = (PW.Feat#IndexDefs#Precheck)
      Facs
   in
      Facs = MemoFacs := (Feat#MemoFac)|Facs
   end
   proc {Mems IndexDefs Precheck Feats}
      {ForAll Feats proc {$ F} {Mem IndexDefs Precheck F} end}
   end

   {Mems VVLD Prechecked
    [
     ledge
     ldom
    ]}
   {Mems VVD Prechecked
    [
     edge
     dom
     domeq
    ]}
   {Mem VV false prec}
   {Mem XD false projective}
   {Mems VLD Prechecked
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
   {Mems VD Prechecked
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
   NewMemo = {Memo.mkNew Memo.dict}
   MemoFacsRec = {List.toRecord 'exports' @MemoFacs}
end

