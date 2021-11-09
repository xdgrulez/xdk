declare
{Inspector.configure widgetShowStrings true}
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
fun {IsSubstring SubS S}
   Ss = {String1.splitAtMost S SubS 1}
in
   {Length Ss}==2
end
[Path] = {Module.link ['x-oz://system/os/Path.ozf']}
[String1] = {Module.link ['x-oz://system/String.ozf']}
fun {GetFileNames DirS ExcludeFileNameSs ExtensionS SubS}
   OldCDS = {OS.getCWD}
   {OS.chDir DirS}
   FileNameSs = {OS.getDir '.'}
   ExcludeFileNameSs1 = {Append ExcludeFileNameSs ["." ".."]}
   FileNameSs1 = {Filter FileNameSs
		  fun {$ FileNameS}
		     {Not {Member FileNameS ExcludeFileNameSs1}} andthen
		     {Path.extension FileNameS}==ExtensionS andthen
		     {IsSubstring SubS {GetS FileNameS}}
		  end}
   {OS.chDir OldCDS}
in
   FileNameSs1
end
FileNameSs = {GetFileNames
	      "Solver/Principles"
	      ["makefile.oz" "Helpers.oz" "Principles.oz"]
	      "oz"
	      "principle.barriersPW"}
{Inspect FileNameSs}
FileNameSs1 = {GetFileNames
	      "Solver/Principles/Source"
	      nil
	      "ul"
	      "principle.barriersPW"}
{Inspect FileNameSs1}


