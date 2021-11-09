declare
{Inspector.configure widgetShowStrings true}
[Helpers] = {Module.link ['Helpers.ozf']}
[Regex] = {Module.link ['x-oz://contrib/regex']}
[String1] = {Module.link ['x-oz://system/String.ozf']}
fun {EditLines Ss BeginPrefixS EndPrefixS IndentS EditProc}
   Ss1
   Ss2
   {List.takeDropWhile
    Ss
    fun {$ S} {Not {List.isPrefix BeginPrefixS S}} end
    Ss1
    Ss2}
   Ss11 = {Append Ss1 {List.take Ss2 1}}
   Ss21 = {List.drop Ss2 1}
   Ss3
   Ss4
   {List.takeDropWhile
    Ss21
    fun {$ S} {Not {List.isPrefix EndPrefixS S}} end
    Ss3
    Ss4}
   Ss31 =
   {Map Ss3
    fun {$ S} {String1.lstrip S unit} end}
   %%
   Ss32 = {EditProc Ss31}
   %%
   Ss33 = {Map Ss32
	   fun {$ S} {Append IndentS S} end}
   Ss5 = {Append Ss11 {Append Ss33 Ss4}}
in
   Ss5
end
fun {MakeAddLineProc LineS}
   fun {EditProc Ss}
      Ss1 = LineS|Ss
      Ss2 = {List.sort Ss1
	     fun {$ S1 S2}
		A1 = {String.toAtom S1}
		A2 = {String.toAtom S2}
	     in
		A1 < A2
	     end}
   in
      Ss2
   end
in
   EditProc
end
fun {MakeRemoveLineProc LineS}
   fun {EditProc Ss}
      Ss1 =
      {Filter Ss
       fun {$ S} {Not {List.isPrefix LineS S}} end}
   in
      Ss1
   end
in
   EditProc
end
fun {CompileDefFile DefFileS DefFunctorS ConstraintS}
   ListS
in
   try
      WriteSocketI
      TailX
   in
      {OS.pipe "PrincipleWriter/pw"
       ["-p" DefFileS
	"-e" DefFunctorS
	"-c" ConstraintS] _ _#WriteSocketI}
      {OS.read WriteSocketI 10000 ListS TailX _}
      TailX = nil
   catch E then
      {Inspect E}
   end
   ListS
end
fun {GetPrincipleID UrlV}
   S = {Helpers.getS UrlV}
   RE = {Regex.make "principle\\.[A-Za-z0-9]*"}
   MATCH = {Regex.search RE S}
in
   if MATCH==false then
      ""
   else
      BS = {ByteString.make S}
      BS1 = {ByteString.slice BS MATCH.0.1 MATCH.0.2}
      S1 = {ByteString.toString BS1}
   in
      S1
   end
end
%IDAs = ['principle.order4711']
IDAs = nil
proc {AddDef SourcePathS}
   IDS = {GetPrincipleID SourcePathS}
   IDSuffixS = {Helpers.getSuffix IDS}
   IDSuffixCh|IDSuffixS1 = IDSuffixS
   IDSuffixS2 = {Char.toUpper IDSuffixCh}|IDSuffixS1
   %%
   SuffixS = {Helpers.getSuffix SourcePathS}
   DestPathV =
   case SuffixS
   of "ul" then "Solver/Principles/Source/"#IDSuffixS2#".ul"
   [] "oz" then "Solver/Principles/"#IDSuffixS2#".oz"
   else raise unknown end
   end
   {Inspect destPathV#DestPathV}
   if {Helpers.fileExists DestPathV} then
      raise fileexists({VirtualString.toAtom DestPathV}y) end
   end
   IDA = {String.toAtom IDS}
   {Inspect IDA}
   if {Member IDA IDAs} then
      raise principleidexists(IDA) end
   end
in
   {Cp PathS DestPathV}
end
proc {Cp UrlV1 UrlV2}
   FileO1 = {New Open.file init(name: UrlV1
			       flags: [read])}
   S = {FileO1 read(list: $
		    size: all)}
   {FileO1 close}
   %%
   FileO2 = {New Open.file init(name: UrlV2
				flags: [create truncate write])}
in
   {FileO2 write(vs: S)}
   {FileO2 close}
end
PathS =
{Tk.return tk_getOpenFile(title: 'XDK: Principle Manager: Add principle...'
			  filetypes: q(q('Principle definition file/functor' '*.ul')
				       q('Principle definition functor' '*.oz')
				       q('All files' '*')))}
{AddDef PathS}
