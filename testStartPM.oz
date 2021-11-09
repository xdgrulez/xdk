declare
{Inspector.configure widgetShowStrings true}
proc {StartPrincipleManager FileV}
   try
      {OS.pipe "xdkpm" ["-g" FileV] _ _#_}
   catch E then
      {Inspect E}
   end
end
{StartPrincipleManager "Grammars/Acl01.ul"}

