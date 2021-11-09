%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Inspector(inspect)

   Open(file text)
   OS(system)
   
   Helpers(fileV2TmpUrlV toEntry) at 'Helpers.ozf'
export
   Make
prepare
   ListLast = List.last
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
define
   V2A = VirtualString.toAtom
   %%
   SuperTaggerOutputUrlV = {Helpers.fileV2TmpUrlV 'superTaggerOutput.txt'}
   %%
   OldTreeATreeARec = o('alphaCONJ': 'alphaConj')
   %%
   class TextFileK from Open.file Open.text end   
   %%
   fun {ReadSuperTaggerOutput UrlV}
      TextFileO = {New TextFileK init(url: UrlV)}
      fun {Read AccSs}
	 S = {TextFileO getS($)}
      in
	 if S==false then
	    AccSs
	 else
	    if {Not S=="...EOS...//...EOS..."} then
	       {Read {Append AccSs [S]}}
	    else
	       {Read AccSs}
	    end
	 end
      end
      Ss = {Read nil}
      {TextFileO close}
   in
      Ss
   end
   %%
   fun {Make BaseAs TreeAPosARec}
      EntryAs = {Map BaseAs Helpers.toEntry}
      EntryV =
      {FoldL EntryAs
       fun {$ AccV EntryA} AccV#' '#EntryA end ''}
      _ = {OS.system 'echo "'#EntryV#'" | '#'$COREF/../bin/freqtritag.perl >'#SuperTaggerOutputUrlV}
      SuperTaggedSs = {ReadSuperTaggerOutput SuperTaggerOutputUrlV}
      ITreeATups =
      {ListMapInd SuperTaggedSs
       fun {$ I SuperTaggedS}
	  Ss = {String.tokens SuperTaggedS &/}
	  TreeS = {ListLast Ss}
	  TreeSs = {String.tokens TreeS &_}
	  TreeV = case TreeSs.1
		  of "A" then "alpha"#{Nth TreeSs 2}
		  [] "B" then "beta"#{Nth TreeSs 2}
		  end
	  OldTreeA = {V2A TreeV}
	  TreeA = {CondSelect OldTreeATreeARec OldTreeA OldTreeA}
       in
	  I#TreeA
       end}
      ITreeARec = {ListToRecord o ITreeATups}
      %%
      FilterProc =
      fun {$ BaseA BaseAs I _}
	 TreeA = ITreeARec.I
	 PosA = TreeAPosARec.TreeA
	 TreeAAnchorsTups1 = [TreeA#[PosA#BaseA]]
      in
	 TreeAAnchorsTups1
      end
   in
      FilterProc
   end
end
