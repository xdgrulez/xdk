%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Inspector(inspect)

   Open1(file) at 'x-oz://system/Open.ozf'
   OS(chDir getCWD getEnv kill pipe)
   
   Helpers(fileV2TmpUrlV isWindows putV) at 'Helpers.ozf'
export
   Open
   Close
define
   %% keeps track of forked processes for showing trees
   PidIsCe = {NewCell nil}
   proc {AddPidI PidI}
      PidIs = {Access PidIsCe}
      PidIs1 = {Append PidIs [PidI]}
   in
      {Assign PidIsCe PidIs1}
   end
   proc {KillPidIs}
      PidIs = {Access PidIsCe}
   in
      for PidI in PidIs do
	 _ = {OS.kill PidI 'SIGTERM'}
      end
      {Assign PidIsCe nil}
   end
   %% Open: DIDA I OutputRec -> U
   proc {Open DIDA I OutputRec}
      NodeOLs = OutputRec.nodeOLs
      RootOL = {CondSelect
		{Filter NodeOLs
		 fun {$ NodeOL} NodeOL.id.model.mothers==nil end} 1 noRoot}
      fun {Traverse NodeOL}
	 LabelV = if NodeOL.id.model.labels==nil then
		     ''
		  else
		     '<'#NodeOL.id.model.labels.1#'>'
		  end
      in
	 if NodeOL.id.model.daughters\=nil then '( ' else '' end#
	 NodeOL.lex.entry.tree#'['#NodeOL.lex.entry.word#']'#LabelV#
	 if NodeOL.id.model.daughters==nil then
	    ''
	 else
	    {FoldL NodeOL.id.model.daughters
	     fun {$ AccV I}
		NodeOL1 = {Nth NodeOLs I}
	     in
		AccV#' '#{Traverse NodeOL1}
	     end ''}
	 end#if NodeOL.id.model.daughters\=nil then ' )' else '' end
      end
   in
      if {Not RootOL==noRoot} then
	 LEMHOMEBS = {OS.getEnv 'LEMHOME'}
	 if LEMHOMEBS==false then
	    raise error1('functor':'Outputs/Lib/XTAGDerivation.ozf' 'proc':'Open' msg:'Cannot find environment variable "LEMHOME". Please set this variable to the location where the lem parser is installed.' info:o(LEMHOMEBS) coord:noCoord file:noFile) end
	 end
	 %%
	 V = {Traverse RootOL}
	 FileV = 'derivation'#DIDA#I
	 UrlV = {Helpers.fileV2TmpUrlV FileV}
	 {Helpers.putV V UrlV}
	 FileNameS = {OS.getCWD}
	 PidI
      in
	 try
	    {OS.chDir LEMHOMEBS}
	    {OS.chDir 'bin'}
	    _#_ = {OS.pipe 'sh' ['showtrees' UrlV] PidI}
	    {AddPidI PidI}
	 catch _ then
	    raise error1('functor':'Outputs/Lib/XTAGDerivation.ozf' 'proc':'Open' msg:'Cannot execute command: "sh.exe showtrees '#UrlV#'" from the "bin" directory of LEMHOME ('#LEMHOMEBS#').' info:o(V FileV UrlV LEMHOMEBS) coord:noCoord file:noFile) end
	 finally
	    {OS.chDir FileNameS}
	 end
      end
   end
   %% Close: DIDA -> U
   proc {Close _}
      {KillPidIs}
   end
end
