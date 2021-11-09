declare
{Inspector.configure widgetShowStrings true}
[Helpers] = {Module.link ['Helpers.ozf']}
[Regex] = {Module.link ['x-oz://contrib/regex']}
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
{Inspect {GetPrincipleID "test/OrderPW.oz"}}

