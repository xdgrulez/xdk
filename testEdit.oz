declare
{Inspector.configure widgetShowStrings true}
proc {Edit FileS}
   try
      {OS.pipe "emacs" [FileS] _ _#_}
   catch E then
      {Inspect E}
   end
end
{Edit "Solver/Principles/Tree.oz"}
