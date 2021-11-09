%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD(reflect)
   FS(include)
   Open(file)
   OS(stat)
export
   PosSort

   Vs2S
   
   Sum
   Average
   Min1
   Max1
   
   AppendList

   IsPair
   Paths2Rec

   RemoveSuffix
   ToEntry

   FileExists
   FileV2TmpUrlV
   PutV
prepare
   ListLast = List.last
   ListTake = List.take
   RecordMap = Record.map
define
   S2A = String.toAtom
   V2S = VirtualString.toString
   %%
   %% PosSort: Node1 Node2 -> B
   %% Returns true if the position of Node1 < position of Node2, and
   %% false if not.
   fun {PosSort Node1 Node2}
      M1 = Node1.pos
      M2 = Node2.pos
      D1 = {FS.include $ M1}
      D2 = {FS.include $ M2}
      I1 = {FD.reflect.min D1}
      I2 = {FD.reflect.min D2}
   in
      I1<I2
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Vs2S: Vs -> S
   %% Converts a list of virtual strings Vs into a single string.
   fun {Vs2S Vs}
      if Vs==nil then
	 ""
      else
	 V1|Vs1 = Vs
	 V = {FoldL Vs1
	      fun {$ AccV V} AccV#","#V end V1}
	 S = {V2S V}
      in
	 S
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Sum: Is -> I
   %% Calculates the sum of Is.
   fun {Sum Is}
      {FoldL Is fun {$ AccI I} AccI+I end 0}
   end
   %% Average: Is -> F
   %% Calculates the average of Is.
   fun {Average Is}
      {Int.toFloat {Sum Is}}/{Int.toFloat {Length Is}}
   end
   %% Min1: Is -> I
   %% Calculates the minimum of Is.
   fun {Min1 Is}
      if {Length Is}==1 then
	 Is.1
      else
	 I1|Is1 = Is
      in
	 {FoldL Is1
	  fun {$ AccI I} {Min AccI I} end I1}
      end 
   end
   %% Max1: Is -> I
   %% Calculates the maximum of Is.
   fun {Max1 Is}
      if {Length Is}==1 then
	 Is.1
      else
	 I1|Is1 = Is
      in
	 {FoldL Is1
	  fun {$ AccI I} {Max AccI I} end I1}
      end 
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IsPair X -> B
   %% Tests whether X is a pair Y#Z
   fun {IsPair X}
      {IsTuple X} andthen
      {Label X}=='#' andthen
      {Width X}==2
   end
   %% Paths2Rec: Paths -> Rec
   %% Create record from list of binary path tuples. E.g.:
   %% {Paths2Rec [a#(b#(c#d)) a#(b#(c#f)) a#(c#(d#e)) a#(b#(d#f))]}
   %% results in:
   %%   o(a: o(b: o(c: [f d]
   %%               d: [f])
   %%          c: o(d: [e]))
   fun {Paths2Rec Paths}
      if {Length Paths}>0 andthen {IsPair Paths.1} then
	 Dict = {NewDictionary}
	 for Path in Paths do
	    LI#X = Path
	 in
	    Dict.LI := X|{CondSelect Dict LI nil}	    	 
	 end      
	 Rec = {Dictionary.toRecord o Dict}
      in
	 {RecordMap Rec Paths2Rec}
      else
	 Paths
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% RemoveSuffix: V SeparatorCh -> S
   %% Removes suffix from virtual string V, separated by separator
   %% character SeparatorCh. E.g. {RemoveSuffix "hallo#20" &#} returns
   %% "hallo".
   fun {RemoveSuffix V SeparatorCh}
      S = {V2S V}
      Ss = {String.tokens S SeparatorCh}
   in
      if {Length Ss}>1 then
	 LastS = {ListLast Ss}
	 S1 = {ListTake S {Length S}-({Length LastS}+1)}
      in
	 S1
      else
	 S
      end
   end
   %% ToEntry: A -> A
   %% Makes input word A suitable for lexical lookup in the XTAG
   %% grammar.
   fun {ToEntry A}
      S = {RemoveSuffix A &#}
   in
      {S2A S}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% FileExists: V -> B
   %% Returns true if the file with path V exists, and false if not.
   fun {FileExists V}
      B
      try
	 _ = {OS.stat V}
	 B = true
      catch _ then
	 B = false
      end
   in
      B
   end
   %% FileV2TmpUrlV: FileV -> TmpUrlV
   %% Prefixes file name FileV with a temporary directory.
   fun {FileV2TmpUrlV FileV}
      WindowsTmpV1 = 'C:/WINDOWS/TEMP'
      WindowsTmpV2 = 'C:/temp'
      WindowsTmpV3 = 'C:/tmp'
      UnixTmpV = '/tmp'
   in
      if {FileExists WindowsTmpV1} then WindowsTmpV1
      elseif {FileExists WindowsTmpV2} then WindowsTmpV2
      elseif {FileExists WindowsTmpV3} then WindowsTmpV3
      elseif {FileExists UnixTmpV} then UnixTmpV
      else ''
      end#'/'#FileV
   end
   %% PutV: V UrlV -> U
   %% Writes the virtual string V into a file with URL UrlV.
   proc {PutV V UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [create truncate write text])}
   in
      {FileO write(vs: V)}
      {FileO close}
   end
end
