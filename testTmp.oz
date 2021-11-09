declare
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
{Inspect {FileV2TmpUrlV 'Hallo'}}
