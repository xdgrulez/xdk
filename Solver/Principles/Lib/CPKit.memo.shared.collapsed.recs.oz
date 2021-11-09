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
   Prechk(decheckOn:DecheckOn) at 'PW.prechecked.ozf'
   System(onToplevel:OnToplevel)
   RecUtils(newFactory:NewRecFactory) at 'RecUtils.ozf'
   Matrix(new:NewMatrix) at 'Matrix.ozf'
export
   Prepare
   New
   Option
   Abstract
prepare
   Reset = {NewName}
   RForAllInd = Record.forAllInd
   RMapInd = Record.mapInd
   RMap = Record.map
   fun {Id X} X end
define

   Option = 'shared-collapsed-recs'
   Abstract = 'shared - collapsed keys - recs'
   
   Prechecked = false
   MatrixBase = o
   
   fun {Prepare G}
      MkDIDARec = {NewRecFactory o G.usedDIDAs}
      MkLabelRec = {MkDIDARec}
   in
      {RForAllInd MkLabelRec
       fun {$ DIDA} {NewRecFactory o {G.dIDA2LabelLat DIDA}.constants} end}
      o(mkDIDARec:MkDIDARec
	dIDA2Info:{RMapInd {MkDIDARec}
		   fun {$ DIDA _}
		      LLat = {G.dIDA2LabelLat DIDA}
		      LCard = LLat.card
		   in
		      o(labelsI:LCard
			l2I: LLat.aI2I)
		   end}
	mkLabelRec:MkLabelRec
       )
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
      VV = {NewMatrix NodesI#NodesI Id#Id MatrixBase}
      DIDA2Info = {RMap MemoSupport0.dIDA2Info
		   fun {$ Info}
		      LblsI = Info.labelsI
		      L2I = Info.l2I
		   in
		      o(vl:{NewMatrix NodesI#LblsI Id#L2I MatrixBase}
			vvl:{NewMatrix NodesI#NodesI#LblsI Id#Id#L2I MatrixBase}
			vll:{NewMatrix NodesI#LblsI#LblsI Id#L2I#L2I MatrixBase})
		   end}
      MemoSupport = {AdjoinList MemoSupport0
		     [ vv#VV
		       dIDA2Info#DIDA2Info
		       nodesI#NodesI
		     ]}
      Memo = {NewMemo MemoSupport}
   in
      MemoPW = {AdjoinAt {Adjoin PW Memo.memos} Reset Memo.reset}
   end

   local
      fun {RecDot _ _ R _ F} R.F end
      fun {DIDANew Support Type K _} {Support.dIDA2Info.(K.1).Type.new} end
      fun {GlobalNew Support Type _ _} {Support.Type.new} end
      fun {NewDIDARec Support _ _ _} {Support.mkDIDARec} end
      fun {DIDADot Support Type D K KI} {Support.dIDA2Info.(K.1).Type.dot D KI} end
      fun {GlobalDot Support Type D _ KI} {Support.Type.dot D KI} end
      GlobalDef = o(dot:GlobalDot
		    new:GlobalNew)
      DIDADef = o(dot:DIDADot
		  new:DIDANew)
   in
      IndexTypes =
      o(d:o(dot:RecDot
	    new:NewDIDARec)
	v:o(dot:RecDot
	    new:fun {$ Support _ _ _} {MakeTuple '#' Support.nodesI} end)
	l:o(dot:RecDot
	    new:fun {$ Support _ K _} {Support.mkLabelRec K.1} end)
	vv:GlobalDef
	vl:DIDADef
	vvl:DIDADef
	vll:DIDADef
       )
   end
   
   local
      fun {DotIndex X} X.index end
      fun {Ind I} app(DotIndex I) end
      fun {D I} d#I end
      fun {V I} v#{Ind I} end
%      fun {L I} l#I end
      fun {VVL V1 V2 L}
	 vvl#({Ind V1}#{Ind V2}#L)
      end
      fun {VV_ V1 V2}
	 vv#({Ind V1}#{Ind V2})
      end
      fun {VL V L}
	 vl#({Ind V}#L)
      end
      fun {VLL V L1 L2}
	 vll#({Ind V}#L1#L2)
      end
   in
      VVLD = {D 4}#{VVL 1 2 3}
      VVD = {D 3}#{VV_ 1 2}
      VV = '#'({VV_ 1 2})
      VLD = {D 3}#{VL 1 2}
      VXLD = {D ignore(2 4)}#{VL 1 3}
      VD = {D 2}#{V 1}
      VXLLD = {D ignore(2 5)}#{VLL 1 3 4}
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

