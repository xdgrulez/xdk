%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
declare
[Helpers] = {Module.link ['Helpers.ozf']}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {LemCollectInfo UrlV}
   fun {LemCollectInfo1 Ss AccRecs}
      case Ss
      of nil then AccRecs
      [] S|Ss1 then
	 Ss2 = {String.tokens S & }
      in
	 case Ss2
	 of "sent:"|LengthS|Ss3 then
	    LengthS1 = {List.take LengthS {Length LengthS}-1}
	    LengthI = {String.toInt LengthS1}
	    S1 = {FoldL Ss3
		  fun {$ AccS S} {Append AccS & |S} end ""}
	    S2 = {List.drop S1 1}
	    %%
	    S3 = {Nth Ss1 2}
	    Ss4 = {String.tokens S3 & }
	 in
	    if Ss4.1=="time(CPU):" then
	       S4 = {Nth Ss4 2}
	       F = {String.toFloat S4}
	       Rec = o(sentence: S2
		       length: LengthI
		       time: F)
	    in
	       {LemCollectInfo1 {List.drop Ss1 3} {Append AccRecs [Rec]}}
	    else
	       Rec = o(sentence: S2
		       length: LengthI
		       time: 0.0)
	    in
	       {LemCollectInfo1 {List.drop Ss1 1} {Append AccRecs [Rec]}}
	    end
	 else
	    {LemCollectInfo1 Ss1 AccRecs}
	 end
      end
   end
   %%
   Ss = {Helpers.getLines UrlV}
in
   {LemCollectInfo1 Ss nil}
end	  
LemUrlVs = [
	    'lem_evaluation/filter_none/wsj23_05-09_lem.txt'
	    'lem_evaluation/filter_none/wsj23_10-14_lem.txt'
	    'lem_evaluation/filter_none/wsj23_15-19_lem.txt'
	    'lem_evaluation/filter_none/wsj23_20-24_lem.txt'
	    'lem_evaluation/filter_none/wsj23_25-29_lem.txt'
	   ]
LemRecs1 =
for LemUrlV in LemUrlVs append:Append do
   LemRecs2 = {LemCollectInfo LemUrlV}
in
   {Append LemRecs2}
end
LemARecDict = {NewDictionary}
for LemRec in LemRecs1 do
   A = {String.toAtom LemRec.sentence}
in
   if {Not A=='the market seems increasingly disconnected from the rest of the nation .'} then
      LemARecDict.A := LemRec
   end
end
LemARecRec = {Dictionary.toRecord lem LemARecDict}
LemRecs = {Record.toList LemARecRec}
%%
fun {LemGetStats LemRecs XDKARecRec GecodeARecRec MinLengthI MaxLengthI}
   LemRecs1 = {Filter LemRecs
	       fun {$ Rec}
		  A = {String.toAtom Rec.sentence}
	       in
		  {HasFeature GecodeARecRec A} andthen
		  Rec.length>=MinLengthI andthen
		  Rec.length=<MaxLengthI
	       end}
   TimeoutLemRecs =
   {Filter LemRecs1
    fun {$ Rec} Rec.time==0.0 end}
   NotimeoutLemRecs =
   {Filter LemRecs1
    fun {$ Rec} {Not Rec.time==0.0} end}
   CommonXDKTimeoutLemRecs =
   {Filter TimeoutLemRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       ({HasFeature XDKARecRec A} andthen
	XDKARecRec.A.time>=1800.0) orelse
       ({HasFeature GecodeARecRec A} andthen
	GecodeARecRec.A.time>=1800.0)
    end}
   CommonGecodeTimeoutLemRecs =
   {Filter TimeoutLemRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       {HasFeature GecodeARecRec A} andthen
       GecodeARecRec.A.time>=1800.0
    end}
   CommonXDKGecodeTimeoutLemRecs =
   {Filter TimeoutLemRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       ({HasFeature XDKARecRec A} andthen
	XDKARecRec.A.time>=1800.0) orelse
       ({HasFeature GecodeARecRec A} andthen
	GecodeARecRec.A.time>=1800.0)
    end}
   CommonXDKGecodeNotimeoutLemRecs =
   {Filter NotimeoutLemRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       {HasFeature XDKARecRec A} andthen
       {HasFeature GecodeARecRec A} andthen
       {Not
	XDKARecRec.A.time>=1800.0 orelse
	GecodeARecRec.A.time>=1800.0}
    end}
   AverageLengthI =
   {Int.toFloat
    {FoldL LemRecs1
     fun {$ AccI Rec}
	Rec.length+AccI
     end 0}}/{Int.toFloat {Length LemRecs1}}
   AverageLengthCommonXDKGecodeNotimeoutI =
   {Int.toFloat
    {FoldL CommonXDKGecodeNotimeoutLemRecs
     fun {$ AccI Rec}
	Rec.length+AccI
     end 0}}/{Int.toFloat {Length CommonXDKGecodeNotimeoutLemRecs}}
   Rec =
   lem(sentences: {Length LemRecs1}
       minlength: MinLengthI
       maxlength: MaxLengthI
       averageLength: AverageLengthI
       averageLengthCommonXDKGecodeNotimeout: AverageLengthCommonXDKGecodeNotimeoutI
       timeouts: {Length TimeoutLemRecs}
       timeoutsPercent:
	  {Int.toFloat {Length TimeoutLemRecs}}/{Int.toFloat {Length LemRecs1}}
       notimeouts: {Length NotimeoutLemRecs}
       commonXDKTimeouts: {Length CommonXDKTimeoutLemRecs}
       commonGecodeTimeouts: {Length CommonGecodeTimeoutLemRecs}
       commonXDKGecodeTimeouts: {Length CommonXDKGecodeTimeoutLemRecs}
       commonXDKGecodeNotimeouts: {Length CommonXDKGecodeNotimeoutLemRecs}
       averageNotimeout:
	  {FoldL NotimeoutLemRecs
	   fun {$ AccF Rec} AccF+Rec.time end 0.0}/
       {Int.toFloat {Length NotimeoutLemRecs}}
       averageCommonXDKGecodeNotimeout:
	  {FoldL CommonXDKGecodeNotimeoutLemRecs
	   fun {$ AccF Rec} AccF+Rec.time end 0.0}/
       {Int.toFloat {Length CommonXDKGecodeNotimeoutLemRecs}})
in
   Rec
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {GecodeCollectInfo UrlV}
   fun {GecodeCollectInfo1 Ss AccRecs}
      case Ss
      of nil then AccRecs
      [] S|Ss1 then
	 if {Length S}>=5 then
	    S1 = {List.take S 5}
	 in
	    if {Member S1 ["05-09" "10-14" "15-19" "20-24" "25-29"]} then
	       SentenceS = Ss1.1
	       LengthI = {Length {String.tokens SentenceS & }}
	       %%
	       LinesI =
	       for S2 in Ss1 I in 1..{Length Ss1} return:Return default:1 do
		  if {Length S2}>=5 then
		     S3 = {List.take S2 5}
		  in
		     if {Member S3 ["05-09" "10-14" "15-19" "20-24" "25-29"]} then
			{Return I}
		     end
		  end
	       end
	    in
	       if LinesI==2 then
		  {GecodeCollectInfo1 {List.drop Ss1 1} AccRecs}
	       else
		  RuntimeI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\truntime:" then
			   RuntimeS = {List.last Ss2}
			   RuntimeSs = {String.tokens RuntimeS &e}
			   RuntimeI =
			   if {Length RuntimeSs}==1 then
			      {String.toInt RuntimeS}
			   else
			      RuntimeSs1 = {String.tokens RuntimeSs.1 &.}
			      RuntimeS1 = {Append RuntimeSs1.1 {Nth RuntimeSs1 2}}
			      RuntimeS2 = {Append RuntimeS1
					   case {Length {Nth RuntimeSs1 2}}
					   of 4 then "00"
					   [] 5 then "0"
					   end}
			   in
			      {String.toInt RuntimeS2}
			   end
			in
			   {Return RuntimeI}
			end
		     end
		  end
		  RuntimeF = {Int.toFloat RuntimeI}/1000.0
		  %%
		  SolutionsI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tsolutions:" then
			   SolutionsS = {List.last Ss2}
			   SolutionsI = {String.toInt SolutionsS}
			in
			   {Return SolutionsI}
			end
		     end
		  end
		  %%
		  PropagatorsI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tpropagators:" then
			   PropagatorsS = {List.last Ss2}
			   PropagatorsI = {String.toInt PropagatorsS}
			in
			   {Return PropagatorsI}
			end
		     end
		  end
		  %%
		  PropagationsI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tpropagations:" then
			   PropagationsS = {List.last Ss2}
			   PropagationsI = {String.toInt PropagationsS}
			in
			   {Return PropagationsI}
			end
		     end
		  end
		  %%
		  FailuresI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tfailures:" then
			   FailuresS = {List.last Ss2}
			   FailuresI = {String.toInt FailuresS}
			in
			   {Return FailuresI}
			end
		     end
		  end
		  %%
		  ClonesI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tclones:" then
			   ClonesS = {List.last Ss2}
			   ClonesI = {String.toInt ClonesS}
			in
			   {Return ClonesI}
			end
		     end
		  end
		  %%
		  CommitsI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tcommits:" then
			   CommitsS = {List.last Ss2}
			   CommitsI = {String.toInt CommitsS}
			in
			   {Return CommitsI}
			end
		     end
		  end
		  %%
		  PeakI =
		  for S2 in Ss1 return:Return default:0 do
		     Ss2 = {String.tokens S2 & }
		  in
		     if {Length Ss2}>0 then
			if Ss2.1=="\tpeak" then
			   PeakS = {Nth Ss2 {Length Ss2}-1}
			   PeakI = {String.toInt PeakS}
			in
			   {Return PeakI}
			end
		     end
		  end
		  %%
		  Rec = o(sentence: SentenceS
			  length: LengthI
			  time: RuntimeF
			  solutions: SolutionsI
			  propagators: PropagatorsI
			  propagations: PropagationsI
			  failures: FailuresI
			  clones: ClonesI
			  commits: CommitsI
			  peak: PeakI)
	       in
		  {GecodeCollectInfo1
		   {List.drop Ss1 LinesI-1} {Append AccRecs [Rec]}}
	       end
	    else
	       {GecodeCollectInfo1 Ss1 AccRecs}
	    end
	 else
	    {GecodeCollectInfo1 Ss1 AccRecs}
	 end
      end
   end
   Ss = {Helpers.getLines UrlV}
in
   {GecodeCollectInfo1 Ss nil}
end
%%
GecodeUrlVs = [
	       'gecode_evaluation/filter_none_new/wsj23_05-09_gecode.txt'
	       'gecode_evaluation/filter_none_new/wsj23_10-14_gecode.txt'
	       'gecode_evaluation/filter_none_new/wsj23_15-19_gecode.txt'
	       'gecode_evaluation/filter_none_new/wsj23_20-24_gecode.txt'
	       'gecode_evaluation/filter_none_new/wsj23_25-29_gecode.txt'
	       'gecode_evaluation/filter_none_new1/wsj23_05-09_gecode.txt'
	       'gecode_evaluation/filter_none_new1/wsj23_10-14_gecode.txt'
	       'gecode_evaluation/filter_none_new1/wsj23_15-19_gecode.txt'
	       'gecode_evaluation/filter_none_new1/wsj23_20-24_gecode.txt'
	       'gecode_evaluation/filter_none_new1/wsj23_25-29_gecode.txt'
	       'gecode_evaluation/filter_none_new2/wsj23_10-14_gecode.txt'
	       'gecode_evaluation/filter_none_new2/wsj23_15-19_gecode.txt'
	      ]
GecodeRecs1 =
for GecodeUrlV in GecodeUrlVs append:Append do
   GecodeRecs2 = {GecodeCollectInfo GecodeUrlV}
in
   {Append GecodeRecs2}
end
GecodeARecDict = {NewDictionary}
for GecodeRec in GecodeRecs1 do
   A = {String.toAtom GecodeRec.sentence}
in
   GecodeARecDict.A := GecodeRec
end
GecodeARecRec = {Dictionary.toRecord 'gecode' GecodeARecDict}
GecodeRecs = {Record.toList GecodeARecRec}
%%
Gecode100UrlVs = [
		  'gecode_evaluation/filter_none_new/wsj23_05-09_gecode100.txt'
		  'gecode_evaluation/filter_none_new/wsj23_10-14_gecode100.txt'
		  'gecode_evaluation/filter_none_new/wsj23_15-19_gecode100.txt'
		  'gecode_evaluation/filter_none_new/wsj23_20-24_gecode100.txt'
		  'gecode_evaluation/filter_none_new/wsj23_25-29_gecode100.txt'
		  'gecode_evaluation/filter_none_new1/wsj23_05-09_gecode100.txt'
		  'gecode_evaluation/filter_none_new1/wsj23_10-14_gecode100.txt'
		  'gecode_evaluation/filter_none_new1/wsj23_15-19_gecode100.txt'
		  'gecode_evaluation/filter_none_new1/wsj23_20-24_gecode100.txt'
		  'gecode_evaluation/filter_none_new1/wsj23_25-29_gecode100.txt'
		  'gecode_evaluation/filter_none_new2/wsj23_10-14_gecode100.txt'
		  'gecode_evaluation/filter_none_new2/wsj23_15-19_gecode100.txt'
	      ]
Gecode100Recs1 =
for Gecode100UrlV in Gecode100UrlVs append:Append do
   Gecode100Recs2 = {GecodeCollectInfo Gecode100UrlV}
in
   {Append Gecode100Recs2}
end
Gecode100ARecDict = {NewDictionary}
for Gecode100Rec in Gecode100Recs1 do
   A = {String.toAtom Gecode100Rec.sentence}
in
   Gecode100ARecDict.A := Gecode100Rec
end
for GecodeRec in GecodeRecs do
   A = {String.toAtom GecodeRec.sentence}
in
   if {Not {HasFeature Gecode100ARecDict A}} then
      Gecode100ARecDict.A := o(sentence: GecodeRec.sentence
			       length: GecodeRec.length
			       time: 1800.1)
   end
end
Gecode100ARecRec = {Dictionary.toRecord 'gecode100' Gecode100ARecDict}
Gecode100Recs = {Record.toList Gecode100ARecRec}
%%
Gecode1000UrlVs = [
		   'gecode_evaluation/filter_none_new/wsj23_05-09_gecode1000.txt'
		   'gecode_evaluation/filter_none_new/wsj23_10-14_gecode1000.txt'
		   'gecode_evaluation/filter_none_new/wsj23_15-19_gecode1000.txt'
		   'gecode_evaluation/filter_none_new/wsj23_20-24_gecode1000.txt'
		   'gecode_evaluation/filter_none_new/wsj23_25-29_gecode1000.txt'
		   'gecode_evaluation/filter_none_new1/wsj23_05-09_gecode1000.txt'
		   'gecode_evaluation/filter_none_new1/wsj23_10-14_gecode1000.txt'
		   'gecode_evaluation/filter_none_new1/wsj23_15-19_gecode1000.txt'
		   'gecode_evaluation/filter_none_new1/wsj23_20-24_gecode1000.txt'
		   'gecode_evaluation/filter_none_new1/wsj23_25-29_gecode1000.txt'
		   'gecode_evaluation/filter_none_new2/wsj23_10-14_gecode1000.txt'
		   'gecode_evaluation/filter_none_new2/wsj23_15-19_gecode1000.txt'
		  ]
Gecode1000Recs1 =
for Gecode1000UrlV in Gecode1000UrlVs append:Append do
   Gecode1000Recs2 = {GecodeCollectInfo Gecode1000UrlV}
in
   {Append Gecode1000Recs2}
end
Gecode1000ARecDict = {NewDictionary}
for Gecode1000Rec in Gecode1000Recs1 do
   A = {String.toAtom Gecode1000Rec.sentence}
in
   Gecode1000ARecDict.A := Gecode1000Rec
end
for GecodeRec in GecodeRecs do
   A = {String.toAtom GecodeRec.sentence}
in
   if {Not {HasFeature Gecode1000ARecDict A}} then
      Gecode1000ARecDict.A := o(sentence: GecodeRec.sentence
			       length: GecodeRec.length
			       time: 1800.1)
   end
end
Gecode1000ARecRec = {Dictionary.toRecord 'gecode1000' Gecode1000ARecDict}
Gecode1000Recs = {Record.toList Gecode1000ARecRec}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {XDKCollectInfo UrlV}
   fun {XDKCollectInfo1 Ss AccRecs}
      case Ss
      of nil then AccRecs
      [] S|Ss1 then
	 Ss2 = {String.tokens S & }
      in
	 if {Length Ss2}>=3 then
	    if {Nth Ss2 3}=="<string" then
	       S1 = {Nth Ss1 2}
	       S2 = {List.drop S1 4}
	       LengthI = {Length {String.tokens S2 & }}
	       Ss3 =
	       for S3 in Ss collect:Collect break:Break do
		  Ss4 = {String.tokens S3 & }
	       in
		  if {Length Ss4}>=3 then
		     if {Nth Ss4 3}=="</string>" then
			{Collect S3}
			{Break}
		     else
			{Collect S3}
		     end
		  else
		     {Collect S3}
		  end
	       end
	       %%
	       TimeI =
	       for S3 in Ss3 return:Return default:0 do
		  Ss4 = {String.tokens S3 & }
	       in
		  case Ss4
		  of nil|nil|nil|nil|"<time"|TimeS|nil then
		     TimeS1 = {List.drop TimeS 6}
		     TimeS2 = {List.take TimeS1 {Length TimeS1}-3}
		     TimeI = {String.toInt TimeS2}
		  in
		     {Return TimeI}
		  else
		     skip
		  end
	       end
	       TimeF = {Int.toFloat TimeI}/1000.0
	       %%
	       FailedI =
	       for S3 in Ss3 return:Return default:0 do
		  Ss4 = {String.tokens S3 & }
	       in
		  case Ss4
		  of nil|nil|nil|nil|"<failed"|FailedS|nil then
		     FailedS1 = {List.drop FailedS 6}
		     FailedS2 = {List.take FailedS1 {Length FailedS1}-3}
		     FailedI = {String.toInt FailedS2}
		  in
		     {Return FailedI}
		  else
		     skip
		  end
	       end
	       %%
	       SucceededI =
	       for S3 in Ss3 return:Return default:0 do
		  Ss4 = {String.tokens S3 & }
	       in
		  case Ss4
		  of nil|nil|nil|nil|"<succeeded"|SucceededS|nil then
		     SucceededS1 = {List.drop SucceededS 6}
		     SucceededS2 = {List.take SucceededS1 {Length SucceededS1}-3}
		     SucceededI = {String.toInt SucceededS2}
		  in
		     {Return SucceededI}
		  else
		     skip
		  end
	       end
	       %%
	       FDFSI#PrI#EntriesF =
	       for S3 in Ss3 return:Return default:0#0#0.0 do
		  Ss4 = {String.tokens S3 & }
	       in
		  case Ss4
		  of nil|nil|nil|nil|"<sprofile"|_|_|FDFSS|PrS|EntriesS|_|nil then
		     FDFSS1 = {List.drop FDFSS 6}
		     FDFSS2 = {List.take FDFSS1 {Length FDFSS1}-1}
		     FDFSI = {String.toInt FDFSS2}
		     %%
		     PrS1 = {List.drop PrS 4}
		     PrS2 = {List.take PrS1 {Length PrS1}-1}
		     PrI = {String.toInt PrS2}
		     %%
		     EntriesS1 = {List.drop EntriesS 9}
		     EntriesS2 = {List.take EntriesS1 {Length EntriesS1}-1}
		     EntriesF = {String.toFloat EntriesS2}
		  in
		     {Return FDFSI#PrI#EntriesF}
		  else
		     skip
		  end
	       end
	       %%
	       Rec = o(sentence: S2
		       length: LengthI
		       time: TimeF
		       failed: FailedI
		       succeeded: SucceededI
		       entries: EntriesF
		       variables: FDFSI
		       propagators: PrI)
	    in
	       {XDKCollectInfo1
		{List.drop Ss1 {Length Ss3}-1} {Append AccRecs [Rec]}}
	    else
	       {XDKCollectInfo1 Ss1 AccRecs}
	    end
	 else
	    {XDKCollectInfo1 Ss1 AccRecs}
	 end
      end
   end
   Ss = {Helpers.getLines UrlV}
in
   {XDKCollectInfo1 Ss nil}
end
%%
XDKUrlVs = [
	    'XDK_evaluation/filter_none/wsj23_05-09_XDK_new.xml'
	    'XDK_evaluation/filter_none/wsj23_10-14_XDK_new.xml'
	    'XDK_evaluation/filter_none/wsj23_15-19_XDK_new.xml'
	    'XDK_evaluation/filter_none/wsj23_20-24_XDK_new.xml'
	    'XDK_evaluation/filter_none/wsj23_25-29_XDK_new.xml'
	    'XDK_evaluation/filter_none/wsj23_05-09_XDK_new1.xml'
	    'XDK_evaluation/filter_none/wsj23_10-14_XDK_new1.xml'
	    'XDK_evaluation/filter_none/wsj23_15-19_XDK_new1.xml'
	    'XDK_evaluation/filter_none/wsj23_20-24_XDK_new1.xml'
	    'XDK_evaluation/filter_none/wsj23_25-29_XDK_new1.xml'
	   ]
XDKRecs1 =
for XDKUrlV in XDKUrlVs append:Append do
   XDKRecs2 = {XDKCollectInfo XDKUrlV}
in
   {Append XDKRecs2}
end
XDKARecDict = {NewDictionary}
for XDKRec in XDKRecs1 do
   A = {String.toAtom XDKRec.sentence}
in
   XDKARecDict.A := XDKRec
end
for GecodeRec in GecodeRecs do
   A = {String.toAtom GecodeRec.sentence}
in
   if {Not {HasFeature XDKARecDict A}} then
      XDKARecDict.A := o(sentence: GecodeRec.sentence
			 length: GecodeRec.length
			 time: 1800.1)
   end
end
XDKARecRec = {Dictionary.toRecord 'XDK' XDKARecDict}
XDKRecs = {Record.toList XDKARecRec}
%%
XDK100UrlVs = [
	       'XDK_evaluation/filter_none_100/wsj23_05-09_XDK_new.xml'
	       'XDK_evaluation/filter_none_100/wsj23_10-14_XDK_new.xml'
	       'XDK_evaluation/filter_none_100/wsj23_15-19_XDK_new.xml'
	       'XDK_evaluation/filter_none_100/wsj23_20-24_XDK_new.xml'
	       'XDK_evaluation/filter_none_100/wsj23_25-29_XDK_new.xml'
	       'XDK_evaluation/filter_none_100/wsj23_05-09_XDK_new1.xml'
	       'XDK_evaluation/filter_none_100/wsj23_10-14_XDK_new1.xml'
	       'XDK_evaluation/filter_none_100/wsj23_15-19_XDK_new1.xml'
	       'XDK_evaluation/filter_none_100/wsj23_20-24_XDK_new1.xml'
	       'XDK_evaluation/filter_none_100/wsj23_25-29_XDK_new1.xml'
	      ]
XDK100Recs1 =
for XDK100UrlV in XDK100UrlVs append:Append do
   XDK100Recs2 = {XDKCollectInfo XDK100UrlV}
in
   {Append XDK100Recs2}
end
XDK100ARecDict = {NewDictionary}
for XDK100Rec in XDK100Recs1 do
   A = {String.toAtom XDK100Rec.sentence}
in
   XDK100ARecDict.A := XDK100Rec
end
for GecodeRec in GecodeRecs do
   A = {String.toAtom GecodeRec.sentence}
in
   if {Not {HasFeature XDK100ARecDict A}} then
      XDK100ARecDict.A := o(sentence: GecodeRec.sentence
			    length: GecodeRec.length
			    time: 1800.1)
   end
end
XDK100ARecRec = {Dictionary.toRecord 'XDK100' XDK100ARecDict}
XDK100Recs = {Record.toList XDK100ARecRec}
%%
XDK1000UrlVs = [
		'XDK_evaluation/filter_none_1000/wsj23_05-09_XDK_new.xml'
		'XDK_evaluation/filter_none_1000/wsj23_10-14_XDK_new.xml'
		'XDK_evaluation/filter_none_1000/wsj23_15-19_XDK_new.xml'
		'XDK_evaluation/filter_none_1000/wsj23_20-24_XDK_new.xml'
		'XDK_evaluation/filter_none_1000/wsj23_25-29_XDK_new.xml'
		'XDK_evaluation/filter_none_1000/wsj23_05-09_XDK_new1.xml'
		'XDK_evaluation/filter_none_1000/wsj23_10-14_XDK_new1.xml'
		'XDK_evaluation/filter_none_1000/wsj23_15-19_XDK_new1.xml'
		'XDK_evaluation/filter_none_1000/wsj23_20-24_XDK_new1.xml'
		'XDK_evaluation/filter_none_1000/wsj23_25-29_XDK_new1.xml'
	       ]
XDK1000Recs1 =
for XDK1000UrlV in XDK1000UrlVs append:Append do
   XDK1000Recs2 = {XDKCollectInfo XDK1000UrlV}
in
   {Append XDK1000Recs2}
end
XDK1000ARecDict = {NewDictionary}
for XDK1000Rec in XDK1000Recs1 do
   A = {String.toAtom XDK1000Rec.sentence}
in
   XDK1000ARecDict.A := XDK1000Rec
end
for GecodeRec in GecodeRecs do
   A = {String.toAtom GecodeRec.sentence}
in
   if {Not {HasFeature XDK1000ARecDict A}} then
      XDK1000ARecDict.A := o(sentence: GecodeRec.sentence
			    length: GecodeRec.length
			    time: 1800.1)
   end
end
XDK1000ARecRec = {Dictionary.toRecord 'XDK1000' XDK1000ARecDict}
XDK1000Recs = {Record.toList XDK1000ARecRec}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {GetStats LabelA Recs LemARecRec OtherARecRec XDK1000ARecRec MinLengthI MaxLengthI}
   Recs1 = {Filter Recs
	    fun {$ Rec}
	       Rec.length>=MinLengthI andthen
	       Rec.length=<MaxLengthI
	    end}
   TimeoutRecs =
   {Filter Recs1
    fun {$ Rec}
       Rec.time>=1800.0
    end}
   NotimeoutRecs =
   {Filter Recs1
    fun {$ Rec}
       {Not Rec.time>=1800.0}
    end}
   CommonLemTimeoutRecs =
   {Filter TimeoutRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       LemARecRec.A.time==0.0
    end}
   CommonOtherTimeoutRecs =
   {Filter TimeoutRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       OtherARecRec.A.time>=1800.0 orelse
       ({HasFeature XDK1000ARecRec A} andthen
	XDK1000ARecRec.A.time>=1800.0)
    end}
   CommonLemOtherTimeoutRecs =
   {Filter TimeoutRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       LemARecRec.A.time==0.0 orelse
       OtherARecRec.A.time>=1800.0 orelse
       ({HasFeature XDK1000ARecRec A} andthen
	XDK1000ARecRec.A.time>=1800.0)
    end}
   CommonLemOtherNotimeoutRecs =
   {Filter NotimeoutRecs
    fun {$ Rec}
       A = {String.toAtom Rec.sentence}
    in
       {Not
	LemARecRec.A.time==0.0 orelse
	OtherARecRec.A.time>=1800.0 orelse
	({HasFeature XDK1000ARecRec A} andthen
	 XDK1000ARecRec.A.time>=1800.0)}
    end}
   AverageLengthI =
   {Int.toFloat
    {FoldL Recs1
     fun {$ AccI Rec}
	Rec.length+AccI
     end 0}}/{Int.toFloat {Length Recs1}}
   AverageLengthCommonLemOtherNotimeoutI =
   {Int.toFloat
    {FoldL CommonLemOtherNotimeoutRecs
     fun {$ AccI Rec}
	Rec.length+AccI
     end 0}}/{Int.toFloat {Length CommonLemOtherNotimeoutRecs}}
   %%
   Rec =
   LabelA(sentences: {Length Recs1}
	  minlength: MinLengthI
	  maxlength: MaxLengthI
	  averageLength: AverageLengthI
	  averageLengthCommonLemOtherNotimeout: AverageLengthCommonLemOtherNotimeoutI
	  timeouts: {Length TimeoutRecs}
	  timeoutsPercent:
	     {Int.toFloat {Length TimeoutRecs}}/{Int.toFloat {Length Recs1}}
	  notimeouts: {Length NotimeoutRecs}
	  commonLemTimeouts: {Length CommonLemTimeoutRecs}
	  commonOtherTimeouts: {Length CommonOtherTimeoutRecs}
	  commonLemOtherTimeouts: {Length CommonLemOtherTimeoutRecs}
	  commonLemOtherNotimeouts: {Length CommonLemOtherNotimeoutRecs}
	  averageNotimeout:
	     {FoldL NotimeoutRecs
	      fun {$ AccF Rec} AccF+Rec.time end 0.0}/
	  {Int.toFloat {Length NotimeoutRecs}}
	  averageCommonLemGecodeNotimeout:
	     {FoldL CommonLemOtherNotimeoutRecs
	      fun {$ AccF Rec} AccF+Rec.time end 0.0}/
	  {Int.toFloat {Length CommonLemOtherNotimeoutRecs}})
in
   Rec
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
{Property.put 'print.depth' 10000}
{Property.put 'print.width' 10000}
I = 1
J = 15
{Inspect {LemGetStats LemRecs XDK1000ARecRec Gecode1000ARecRec I J}}
{Inspect {GetStats 'Gecode' GecodeRecs LemARecRec XDKARecRec XDK1000ARecRec I J}}
{Inspect {GetStats 'XDK' XDKRecs LemARecRec GecodeARecRec XDK1000ARecRec I J}}
{Inspect {GetStats 'Gecode100' Gecode100Recs LemARecRec XDK100ARecRec XDK1000ARecRec I J}}
{Inspect {GetStats 'XDK100' XDK100Recs LemARecRec Gecode100ARecRec XDK1000ARecRec I J}}
{Inspect {GetStats 'Gecode1000' Gecode1000Recs LemARecRec XDK1000ARecRec XDK1000ARecRec I J}}
{Inspect {GetStats 'XDK1000' XDK1000Recs LemARecRec Gecode1000ARecRec XDK1000ARecRec I J}}
