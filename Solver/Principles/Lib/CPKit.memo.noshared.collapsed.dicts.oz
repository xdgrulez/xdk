%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show:Show)
   RecUtils(mkF2I:MkF2I) at 'RecUtils.ozf'
   FD at 'FD.ozf'
   FS at 'FS.ozf'
   PW at 'PW.base.ozf'
   Memo(mkNew:MkNewMemo dict keyChangeDict:KeyChangeDict) at 'Memoizer.ozf'
%   Prechk(decheckOff:DecheckOff decheckOn:DecheckOn) at 'PW.prechecked.ozf'
   Prechk(decheckOff:DecheckOff) at 'PW.prechecked.ozf'
   System(onToplevel:OnToplevel)
   Matrix(new:NewMatrix dict:DictMatrix) at 'Matrix.ozf'
   ListUtils(union:ListUnion) at 'ListUtils.ozf'
export
   Prepare
   New
   Option
   Abstract
prepare
   Reset = {NewName}
   RForAll = Record.forAll
   RMap = Record.map
   RMapInd = Record.mapInd
define

   Option = 'noshared-collapsed-dicts'
   Abstract = 'not shared - collapsed keys - dicts (for high determinacy)'

   Prechecked = true

   fun {Id X} X end

   local
      fun {DotConstants X} X.constants end
      fun {MkDict Dims KeyChange}
	 {KeyChangeDict {NewMatrix Dims KeyChange DictMatrix}.k2I}
      end
      fun {MkVVDict NodesI} {MkDict NodesI#NodesI Id#Id} end
   in
      fun {Prepare G}
	 DIDA2LabelLat = G.dIDA2LabelLat
	 DIDAs = G.usedDIDAs
	 LabelLats = {Map DIDAs DIDA2LabelLat}
	 AllLabels = {FoldL {Map LabelLats DotConstants} ListUnion nil}
	 L2I = {MkF2I {MakeRecord o AllLabels}}
	 D2I = {MkF2I {MakeRecord o DIDAs}}
	 DsI = {Length DIDAs}
	 LsI = {Length AllLabels}
      in
	 o(d:Memo.dict
	   vv:MkVVDict
	   dvv: fun {$ NsI} {MkDict DsI#NsI#NsI D2I#Id#Id} end
	   dvlv:fun {$ NsI} {MkDict DsI#NsI#LsI#NsI D2I#Id#L2I#Id} end
	   dlv:fun {$ NsI} {MkDict DsI#LsI#NsI D2I#L2I#Id} end
	   dv:fun {$ NsI} {MkDict DsI#NsI D2I#Id} end
	   dllv:fun {$ NsI} {MkDict DsI#LsI#LsI#NsI D2I#L2I#L2I#Id} end)
      end
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
   
   proc {MkPW DictDefs NodesI MemoPW}
      NewMemos = {RMap DictDefs
		  fun {$ DictDef}
		     {MkNewMemo if {IsProcedure DictDef} then {DictDef NodesI}
				else DictDef end}
		  end}
      Memos = {RMap MemoFacsRec fun {$ Proc#DictId#IDefs#Prechk}
				   {NewMemos.DictId Proc IDefs Prechk}
				end}
      Proxies = {RMapInd Memos fun {$ F Memo} Memo.proxy end}
      proc {ResetProc} {RForAll Memos CallReset} end
   in
      MemoPW = {AdjoinAt {Adjoin PW Proxies} Reset ResetProc}
   end
   
   local
      fun {DotIndex X} X.index end
      fun {Ind I} app(DotIndex I) end
   in
      VVLD = dvlv#(4#{Ind 1}#3#{Ind 2})
      VVD = dvv#(3#{Ind 1}#{Ind 2})
      VV = vv#({Ind 1}#{Ind 2})
      VLD = dlv#(3#2#{Ind 1})
      VXLD = dlv#(ignore(2 4)#3#{Ind 1})
      VD = dv#(2#{Ind 1})
      VXLLD = dllv#(ignore(2 5)#4#3#{Ind 1})
      XD = d#(ignore(1 2))
   end

   MemoFacs = {NewCell nil}
   
   proc {Mem DictId#IndexDefs Precheck Feat}
      MemoFac = (PW.Feat#DictId#IndexDefs#Precheck)
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
   MemoFacsRec = {List.toRecord 'exports' @MemoFacs}
end

