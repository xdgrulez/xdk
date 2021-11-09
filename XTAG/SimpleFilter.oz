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

   Regex at 'x-oz://contrib/regex'

   Helpers(toEntry) at 'Helpers.ozf'
export
   Make
prepare
   ListMapInd = List.mapInd
   ListToRecord = List.toRecord
define
   fun {RegexMatch V RE}
      {Not {Regex.search RE V}==false}
   end
   %%
   fun {Make BaseAs}
      WhpatRE = {Regex.make 'wh[a-z]*'}
      HasWhBCe = {NewCell false}
      BaseIHasWhBTups =
      {ListMapInd BaseAs
       fun {$ BaseI BaseA}
	  EntryA = {Helpers.toEntry BaseA}
	  if {RegexMatch EntryA WhpatRE} then
	     HasWhBCe := true
	  end
	  HasWhB = {Access HasWhBCe}
       in
	  BaseI#HasWhB
       end}
      BaseIHasWhBRec = {ListToRecord o BaseIHasWhBTups}
      %%
      FilterProc =
      fun {$ BaseA BaseAs BaseI TreeAAnchorsTups}
	 WhtreepatRE = {Regex.make 'alphaW'}
	 DeletePatsRE = {Regex.make
			 'alphaG'#'|'#
			 'alphaWA'#'|'#
			 'Ax1'#'|'#
			 'Px1'#'|'#
			 'N1'#'|'#
			 'nx0nx1ARB'#'|'#
			 'nx0ARB'#'|'#
			 'nx0A1'#'|'#
			 's0Pnx1'#'|'#
			 'alphaI'#'|'#
			 'betaI'#'|'#
			 'betaNc'#'|'#
			 'Vtransn'#'|'#
			 'Vintransn'#'|'#
			 'alphaInv'}
	 TreeAAnchorsTups1 =
	 {Filter TreeAAnchorsTups
	  fun {$ TreeA#_}
	     HasWhB = BaseIHasWhBRec.BaseI
	  in
	     if {Not HasWhB} andthen {RegexMatch TreeA WhtreepatRE} then
		false
	     else
		if {RegexMatch TreeA DeletePatsRE} then
		   false
		else
		   true
		end
	     end
	  end}
      in      
	 TreeAAnchorsTups1
      end
   in
      FilterProc
   end
end
