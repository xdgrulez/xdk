declare
{Inspector.configure widgetShowStrings true}
{Inspect 1#{OS.getCWD}}
{OS.chDir 'c:/cygwin/home/d050517/xdg/parser/xdk/'}
{Inspect 2#{OS.getCWD}}

declare
{Inspector.configure widgetShowStrings true}
try
   PidI
%   ReadSocketI
   WriteSocketI
   ListS
   TailX
%   ReadI
   FileNameS
   Pipe
in
   FileNameS = {OS.getCWD}
   {Inspect FileNameS}
   {OS.chDir 'Solver/Principles'}
%   {OS.chDir 'PrincipleWriter'}
%   {OS.pipe 'mspaint' nil _ _}
%   {OS.pipe 'pw' nil _ _}
%   {OS.pipe "pw" nil _ _#WriteSocketI}
%   {OS.pipe "ozc" ["-c" "Principles.oz"] _ _#WriteSocketI}
%%   {OS.pipe "ozc" ["-c" "Principles.oz"] PidI _#WriteSocketI}
%%   {OS.read WriteSocketI 10000 ListS TailX _}
   Pipe = {New Open.pipe init(cmd:"ozc" args:"-c Principles.oz")}
   {Pipe close}
   {OS.chDir FileNameS}
%%   TailX = nil
%%   {Inspect PidI}
%%   {Inspect ListS}
catch E then
   {Inspect E}
end
