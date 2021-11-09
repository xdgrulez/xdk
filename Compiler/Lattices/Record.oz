%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   Inspector(inspect)
%   System(show)
   
   Helpers(a2CIL cIL2A encode decode glb pretty multiply) at 'Helpers.ozf'
export
   Make
prepare
   ListToRecord = List.toRecord
   RecordFilter = Record.filter
   RecordFoldL = Record.foldL
   RecordMap = Record.map
   RecordMapInd = Record.mapInd
   RecordToListInd = Record.toListInd
define
   %% Make: Rec -> Lat
   %% Makes a record lattice with record ALatRec (where ALatRec maps
   %% atoms to lattices)
   %% SL = ASLRec (where ASLRec maps atoms to SL expressions)
   fun {Make ALatRec}
      As = {Arity ALatRec}
      for A in As do
	 if {Not {IsAtom A}} then
	    raise error1('functor':'Compiler/Lattices/Record.ozf' 'proc':'Make' msg:'Cannot make record lattice because the record arity contains a non-atom.' info:o(As A) coord:noCoord file:noFile) end
	 end
      end
      %% top
      Top = {RecordMap ALatRec
	     fun {$ Lat} Lat.top end}
      %% bot
      Bot = {RecordMap ALatRec
	     fun {$ Lat} Lat.bot end}
      %% glb
      fun {GlbProc ASLRec1 ASLRec2}
	 {RecordMapInd ALatRec
	  fun {$ A Lat}
	     SL1 = ASLRec1.A
	     SL2 = ASLRec2.A
	  in
	     {Lat.glb SL1 SL2}
	  end}
      end
      fun {Glb SL1 SL2}
	 {Helpers.glb SL1 SL2 Top GlbProc}
      end
      %% select
      fun {Select ASLRecs D}
	 {RecordMapInd ALatRec
	  fun {$ A Lat}
	     SLs = {Map ASLRecs
		    fun {$ ASLRec} ASLRec.A end}
	  in
	     {Lat.select SLs D}
	  end}
      end
      %% makeVar
      fun {MakeVar}
	 {RecordMap ALatRec
	  fun {$ Lat} {Lat.makeVar} end}
      end
      %% encode
      fun {EncodeProc IL Extra}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
	 ASLRecs =
	 case IL
	 of elem(tag: record
		 args: ILs ...) then
	    ASLRecss =
	    {Map ILs
	     fun {$ IL}
		ASLRecs = {Helpers.encode IL Lat Extra}
	     in
		ASLRecs
	     end}
	    ASLRecss1 = {Helpers.multiply ASLRecss}
	    ASLRecs =
	    {Map ASLRecss1
	     fun {$ ASLRecs}
		ASLDict = {NewDictionary}
		for ASLRec in ASLRecs do
		   ASLTups = {RecordToListInd ASLRec}
		in
		   for A#SL1 in ASLTups do
		      SL =
		      if {HasFeature ASLDict A} then
			 Lat = ALatRec.A
			 SL2 = ASLDict.A
			 SL = {Lat.glb SL1 SL2}
		      in
			 SL
		      else
			 SL1
		      end
		   in
		      ASLDict.A := SL
		   end
		end
		ASLRec = {Dictionary.toRecord o ASLDict}
	     in
		ASLRec
	     end}
	 in
	    ASLRecs
	 [] CIL#IL1 then
	    A = {Helpers.cIL2A CIL}
	    Lat = ALatRec.A
	    SLs = {Lat.encode IL1 Extra}
	    ASLRecs = {Map SLs
		       fun {$ SL} o(A:SL) end}
	 in
	    ASLRecs
	 else
	    raise error1('functor':'Compiler/Lattices/Record.ozf' 'proc':'EncodeProc' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
	 ASLRecs1 =
	 {Map ASLRecs
	  fun {$ ASLRec}
	     ASLRec1 =
	     if Extra.3 then
		ASLTups =
		{Map As
		 fun {$ A}
		    Lat = ALatRec.A
		    SL = {CondSelect ASLRec A Lat.top}
		 in
		    A#SL
		 end}
	     in
		ASLRec1 = {ListToRecord o ASLTups}
	     else
		ASLRec
	     end
	  in
	     ASLRec1
	  end}
      in
	 ASLRecs1
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc ASLRec}
	 AILRec = {RecordMapInd ASLRec
		   fun {$ A SL}
		      Lat = ALatRec.A
		   in
		      {Lat.decode SL}
		   end}
	 AILTups = {RecordToListInd AILRec}
	 ILs = {Map AILTups
		fun {$ A#IL}
		   CIL = {Helpers.a2CIL A}
		in
		   CIL#IL
		end}
      in
	 elem(tag: record
	      args: ILs)
      end
      DecodeNonDetProc = DecodeDetProc
      fun {Decode ASLRec}
	 {Helpers.decode ASLRec DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc ASLRec AbbrB}
	 AOLRec =
	 {RecordMapInd ASLRec
	  fun {$ A SL}
	     Lat = ALatRec.A
	  in
	     {Lat.pretty SL AbbrB}
	  end}
	 AOLRec1 =
	 if AbbrB then
	    {RecordFilter AOLRec
	     fun {$ OL} {Not OL==top} end}
	 else
	    AOLRec
	 end
      in
	 AOLRec1
      end
      PrettyNonDetProc = PrettyDetProc
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 FDI = {RecordFoldL ALatRec
		fun {$ AccI Lat} AccI+({Lat.count}.fd) end 0}
	 FSI = {RecordFoldL ALatRec
		fun {$ AccI Lat} AccI+({Lat.count}.fs) end 0}
      in
	 o(fd: FDI
	   fs: FSI)
      end
      %% build lattice
      Lat =
      elem(tag: record
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   record: ALatRec
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
end
