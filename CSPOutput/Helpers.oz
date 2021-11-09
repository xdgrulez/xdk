%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Open(file)
   OS(stat)
   Resolve(handler pickle native)
export
   FileExists
   AllButLast
   ChangeSuffix
   GetS
   GetLines
   Spec2Is
   UnPickleRec
prepare
   ListTake = List.take
   RecordMap = Record.map
define
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
   %% AllButLast: Xs -> Ys
   %% Takes all but the last element of a list Xs.
   fun {AllButLast Xs} {ListTake Xs {Length Xs}-1} end
   %%
   V2S = VirtualString.toString
   %%
   %% ChangeSuffix: V1 V2 -> S
   %% Changes the suffix of filename V1 to V2, and returns the changed string S.
   %% E.g. {ChangeSuffix "bla.ozf" "txt"} -> "bla.txt".
   fun {ChangeSuffix V1 V2}
      S1 = {V2S V1}
      S2 = {V2S V2}
      Ss = {String.tokens S1 &.}
      Ss1 = {AllButLast Ss}
      S3 =
      {FoldR Ss1
       fun {$ S AccS} {Append S &.|AccS} end nil}
      S4 = {Append S3 S2}
   in
      S4
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
   %%
   fun {Spec2Is Spec}
      for X in Spec collect:Collect do
	 case X
	 of I1#I2 then
	    if I2-I1<1000 then
	       for I in I1..I2 do {Collect I} end
	    end
	 [] I then
	    {Collect I}
	 end
      end
   end
   %%
   fun {UnPickleRec LIss}
      if {Length LIss.1}==1 then
	 LIss.1.1
      else
	 LILIsTups = {Map LIss
		      fun {$ LI|LIs} LI#LIs end}
	 LILIssDict = {NewDictionary}
	 for LI#LIs in LILIsTups do
	    LIss = {CondSelect LILIssDict LI nil}
	 in
	    LILIssDict.LI := {Append LIss [LIs]}
	 end
	 LILIssRec = {Dictionary.toRecord o LILIssDict}
	 LILIssRec1 = {RecordMap LILIssRec UnPickleRec}
      in
	 LILIssRec1
      end
   end
end
