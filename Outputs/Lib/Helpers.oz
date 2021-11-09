%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
   Open(file)
   OS(stat)
   Property(get)
export
   CIL2A

   X2V

   AppendList

   DiffOLs

   PutV
   FileExists
   FileV2TmpUrlV
prepare
   ListToRecord = List.toRecord
   ListZip = List.zip
   RecordToListInd = Record.toListInd
   RecordZip = Record.zip
define
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into the corresponding atom A.
   fun {CIL2A CIL} CIL.data end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% X2V: X -> V
   %% Transforms value X into a virtual string V.
   fun {X2V X}
      V = {Value.toVirtualString X 10000 10000}
   in
      V
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %%
   fun {DiffOLs OLs1 OLs2}
      fun {DiffOL1 X Y}
	 if X==Y then '=' else
	    if {IsRecord X} andthen {IsRecord Y} andthen
	       {Arity X}=={Arity Y} andthen
	       {Width X}>0 andthen
	       {Not {Label X}=='|'} andthen
	       {Not {Label X}=='_'} then
	       {RecordZip X Y DiffOL1}
	    else
	       o('OLD': X
		 'NEW': Y)
	    end
	 end
      end
      %%
      fun {DiffOL2 Rec}
	 AXTups =
	 for A#X in {RecordToListInd Rec} collect:Collect do
	    if X=='=' then
	       skip
	    elseif {IsRecord X} andthen
	       {Width X}>0 andthen
	       {Not {Label X}=='|'} andthen
	       {Not {Label X}=='_'} then
	       {Collect A#{DiffOL2 X}}
	    else
	       {Collect A#X}
	    end
	 end
      in
	 {ListToRecord o AXTups}
      end
      %%
      OLs3 = {ListZip OLs1 OLs2 DiffOL1}
      OLs4 = {Map OLs3 DiffOL2}
   in
      OLs4
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% PutV: V UrlV -> U
   %% Writes the virtual string V into a file with URL UrlV.
   proc {PutV V UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [create truncate write text])}
   in
      {FileO write(vs: V)}
      {FileO close}
   end
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
end
