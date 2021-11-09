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
   Memo at 'SharedMemo.ozf'
%   Prechk(decheckOff:DecheckOff decheckOn:DecheckOn) at 'PW.prechecked.ozf'
   Prechk(decheckOn:DecheckOn) at 'PW.prechecked.ozf'
   System(onToplevel:OnToplevel)
   RecUtils(newFactory:NewRecFactory) at 'RecUtils.ozf'
export
   Prepare
   New
   Option
   Abstract
prepare
   Reset = {NewName}
   RForAllInd = Record.forAllInd
define

   Option = 'shared-asis-recs'
   Abstract = 'shared - as-is keys - recs (for low determinacy, e.g. in FlatZinc printing)'

   Prechecked = false
   
   fun {Prepare G}
      MkDIDARec = {NewRecFactory o G.usedDIDAs}
      MkLabelRec = {MkDIDARec}
   in
      {RForAllInd MkLabelRec
       fun {$ DIDA} {NewRecFactory o {G.dIDA2LabelLat DIDA}.constants} end}
      o(mkDIDARec:MkDIDARec
	mkLabelRec:fun {$ DIDA} {MkLabelRec.DIDA} end)
   end
   
   fun {New MemoSupport NodesI}
      PW = {MkPW MemoSupport NodesI}
      FD = {MkFD PW}
      FS = {MkFS PW}
   in
%      if Prechecked then {DecheckOff} else {DecheckOn} end
      {DecheckOn}
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

   proc {MkPW MemoSupport0 NodesI MemoPW}
      MemoSupport = {AdjoinAt MemoSupport0 nodesI NodesI}
      Memo = {NewMemo MemoSupport}
   in
      MemoPW = {AdjoinAt {Adjoin PW Memo.memos} Reset Memo.reset}
   end
   
   local
      fun {RecDot _ _ R _ F} R.F end
   in
      IndexTypes =
      o(d:o(dot:RecDot
	    new:fun {$ Support _ _ _} {Support.mkDIDARec} end)
	v:o(dot:RecDot
	    new:fun {$ Support _ _ _} {MakeTuple '#' Support.nodesI} end)
	l:o(dot:RecDot
	    new:fun {$ Support _ K _} {Support.mkLabelRec K.1} end)
       )
   end
   
   local
      fun {DotIndex X} X.index end
      fun {Ind I} app(DotIndex I) end
      fun {D I} d#I end
      fun {V I} v#{Ind I} end
      fun {L I} l#I end
   in
      VVLD = {D 4}#{V 1}#{V 2}#{L 3}
      VVD = {D 3}#{V 1}#{V 2}
      VV = {V 1}#{V 2}
      VLD = {D 3}#{V 1}#{L 2}
      VXLD = {D ignore(2 4)}#{V 1}#{L 3}
      VD = {D 2}#{V 1}
      VXLLD = {D ignore(2 5)}#{V 1}#{L 3}#{L 4}
      XD = '#'({D ignore(1 2)})
   end

   MemoFactory = {Memo.new IndexTypes}
   
   proc {Mem IndexDefs Precheck Feat}
      {MemoFactory.add Feat PW.Feat IndexDefs Precheck}
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
   NewMemo = {MemoFactory.compile}
end

