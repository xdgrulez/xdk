declare
{Inspector.configure widgetShowStrings true}
[Helpers] = {Module.link ['Helpers.ozf']}
[Regex] = {Module.link ['x-oz://contrib/regex']}
fun {GetPrincipleIDs UrlV}
   S = {Helpers.getS UrlV}
   RE = {Regex.make "principle\\.[A-Za-z0-9]*"}
   MATCHES = {Regex.allMatches RE S}
   BS = {ByteString.make S}
   Ss =
   {Map MATCHES
    fun {$ MATCH}
       BS1 = {ByteString.slice BS MATCH.0.1 MATCH.0.2}
       S1 = {ByteString.toString BS1}
    in
       S1
    end}
in
   Ss
end
Ss = {GetPrincipleIDs "Grammars/CSDPW.ul"}
for S in Ss do {Inspect S} end
