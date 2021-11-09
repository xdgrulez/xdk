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

   Open(socket text file)
   OS(stat)
export
   FillRec

   ServerK

   Mid
   GetSuffix
   RemoveSuffix

   ToEntry
   
   Collect
   NoDoubles
   Multiply
   
   FileExists
   FileV2TmpUrlV
   PutV
   GetS
   GetLines
   
   Gorn2A
   A2Gorn
   GornLessThan
   GornDom

   GetNodesOfTypes
   IsInitial
prepare
   ListDrop = List.drop
   ListIsPrefix = List.isPrefix
   ListLast = List.last
   ListTake = List.take
   RecordMapInd = Record.mapInd
define
   A2S = Atom.toString
   S2A = String.toAtom
   S2I = String.toInt
   V2A = VirtualString.toAtom
   V2S = VirtualString.toString
   %%
   %% FillRec: Rec1 Rec2 -> Rec
   %% Recursively fills Rec1 with values from Rec2 for each field not
   %% present in Rec1. Can be used e.g. for filling options records
   %% (Rec1) with default values (Rec2).
   fun {FillRec Rec1 Rec2}
      {RecordMapInd Rec2
       fun {$ LI X}
	  if {HasFeature Rec1 LI} then
	     if {IsRecord X} andthen {Not {Arity X}==nil} then
		{FillRec Rec1.LI X}
	     else
		Rec1.LI
	     end
	  else
	     Rec2.LI
	  end
       end}
   end
   %%
   class ServerK from Open.socket Open.text end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Mid: S I1 I2 -> S
   %% Returns the string of characters I1 to I2 in S, e.g. {Mid
   %% "abcdefg" 3 5} returns "cde".
   fun {Mid S I1 I2}
      S1 = {ListDrop S I1-1}
      S2 = {ListTake S1 (I2-I1)+1}
   in
      S2
   end
   %% GetSuffix: V SeparatorCh -> S
   %% Gets suffix from virtual string V, separated by separator
   %% character SeparatorCh. E.g. {GetSuffix "hallo#20" &#} returns
   %% "20".
   fun {GetSuffix V SeparatorCh}
      S = {V2S V}
      Ss = {String.tokens S SeparatorCh}
   in
      if {Length Ss}>1 then
	 LastS = {ListLast Ss}
	 S1 = {ListDrop S {Length S}-{Length LastS}}
      in
	 S1
      else
	 S
      end
   end
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
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ToEntry: A -> A
   %% Makes input word A suitable for lexical lookup in the XTAG
   %% grammar.
   fun {ToEntry A}
      S = {RemoveSuffix A &#}
   in
      {S2A S}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Collect: Xs X2AsProc A2YProc -> Ys
   %% Collects all unique elements contained in list Xs.  X2AsProc is
   %% a procedure mapping elements X of Xs to lists of atoms As to be
   %% collected, and then to be converted to elements of type Y by
   %% procedure A2YProc.
   fun {Collect Xs X2AsProc A2YProc}
      ABDict = {NewDictionary}
      for X in Xs do
	 As = {X2AsProc X}
      in
	 for A in As do
	    if {Not {HasFeature ABDict A}} then
	       ABDict.A := true
	    end
	 end
      end
      As = {Dictionary.keys ABDict}
      Ys = {Map As A2YProc}
   in
      Ys
   end
   %% NoDoubles: Xs -> Ys
   %% Removes double elements from list Xs.
   fun {NoDoubles Xs}
      {FoldL Xs fun {$ AccXs X}
		   if {Member X AccXs} then
		      AccXs
		   else
		      {Append AccXs [X]}
		   end
		end nil}
   end
   %% Multiply: Xss -> Xss
   fun {Multiply Xss}
      Xss1 =
      if Xss==nil then
	 [nil]
      else
	 Xs1|Xss1 = Xss
	 Xss2 = {Map Xs1
		 fun {$ X} [X] end}
      in
	 {FoldL Xss1
	  fun {$ AccXss Xs}
	     for AccXs in AccXss collect:Collect do
		for X in Xs do
		   Xss = {Append AccXs [X]}
		in
		   {Collect Xss}
		end
	     end
	  end Xss2}
      end
   in
      Xss1
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
   %% GetS: UrlV -> S
   %% Reads the contents of the file with URL UrlV into string S.
   fun {GetS UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [read text])}
      S
      {FileO read(list: S
		  size: all)}
      {FileO close}
   in
      S
   end
   %% GetLines: UrlV -> Ss
   %% Reads the lines of the file with URL UrlV into the list of
   %% strings Ss.
   fun {GetLines UrlV}
      S = {GetS UrlV}
      Ss = {String.tokens S &\n}
   in
      Ss
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Gorn2A: Gorn -> A
   %% Encodes Gorn address Gorn into atom A, e.g. {Gorn2A [1 2 3]}
   %% returns '123', and {Gorn2A nil} returns '0'.
   fun {Gorn2A Gorn}
      V = if Gorn==nil then
	     0
	  else
	     {FoldL Gorn
	      fun {$ AccV I} AccV#I end ''}
	  end
   in
      {V2A V}
   end
   %% A2Gorn: A -> Gorn
   %% Returns Gorn address Gorn encoded in atom A.
   fun {A2Gorn A}
      S = {A2S A}
      Is = {Map S
	    fun {$ Ch} {S2I [Ch]} end}
   in
      if Is==[0] then nil else Is end
   end
   %% GornLessThan Gorn1 Gorn2 -> B
   %% Does Gorn address Gorn1 precede Gorn address Gorn2?
   fun {GornLessThan Gorn1 Gorn2}
      if Gorn1==nil orelse Gorn2==nil then
	 false
      elseif Gorn1.1==Gorn2.1 then
	 {GornLessThan {ListDrop Gorn1 1} {ListDrop Gorn2 1}}
      else
	 Gorn1.1<Gorn2.1
      end
   end
   %% GornDom Gorn1 Gorn2 -> B
   %% Does Gorn address Gorn1 dominate Gorn address Gorn2?
   fun {GornDom Gorn1 Gorn2}
      {ListIsPrefix Gorn1 Gorn2} andthen {Not Gorn1==Gorn2}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetNodesOfTypes: Node TypeAs -> Nodes
   %% Gets list of nodes of type in TypeAs in tree with root node Node.
   fun {GetNodesOfTypes Node TypeAs}
      if {Member Node.type TypeAs} then
	 Node|for Node in Node.daughters append:Append do
		 Nodes = {GetNodesOfTypes Node TypeAs}
	      in
		 {Append Nodes}
	      end
      else
	 for Node in Node.daughters append:Append do
	    Nodes = {GetNodesOfTypes Node TypeAs}
	 in
	    {Append Nodes}
	 end
      end
   end
   %% IsInitial: TreeA -> B
   %% Is the tree with tree name TreeA an initial tree?
   fun {IsInitial TreeA}
      %% exceptions
      case TreeA
      of 'alphaW0s0Vs1' then false
      [] 'alphas0Vs1' then false
      [] 'betaCONJs' then true
      else
	 TreeS = {A2S TreeA}
      in
	 TreeS.1==&a
      end
   end
end
