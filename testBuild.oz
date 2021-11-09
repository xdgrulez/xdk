declare
{Inspector.configure widgetShowStrings true}
[Helpers] = {Module.link ['Helpers.ozf']}
fun {CompileDefFile DefFileS DefFunctorS ConstraintS}
   Ss
in
   try
      PidI
      WriteSocketI
   in
      {OS.pipe "PrincipleWriter/pw"
       ["-p" DefFileS
	"-e" DefFunctorS
	"-c" ConstraintS] PidI _#WriteSocketI}
      Ss = {Helpers.readFromSocket WriteSocketI}
   catch E then
      {Inspect E}
   end
   Ss
end
Ss =
{CompileDefFile
 "Solver/Principles/Source/orderPW.ul"
 "Solver/Principles/OrderPW.oz"
 "Solver/Principles/Lib/OrderPW.oz"}
for S in Ss do
   {Inspect S}
end

declare
fun {CompileOz FileS}
   Ss
in
   try
      WriteSocketI
   in
      {OS.pipe "ozc"
       ["-c" FileS#2 "-o" FileS#"f"] _ _#WriteSocketI}
      Ss = {Helpers.readFromSocket WriteSocketI}
   catch E then
      {Inspect E}
   end
   Ss
end
Ss1 =
{CompileOz "Solver/Principles/Principles.oz"}
for S in Ss1 do
   {Inspect {S2A S}}
end
