%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Tk(font)
export
   GetFont
   MeasureText
define
   V2S = VirtualString.toString
   S2A = String.toAtom
   %%
   fun {V2A V} {S2A {V2S V}} end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetFont: TextRec -> FontW
   %% Get font widget FontW described by TextRec. Uses FontCacheDict
   %% to speed things up.
   %%
   %% TextRec is a record as follows:
   %% o(family: V
   %%   weight: V
   %%   size: I
   %%   fill: V
   %%   text: V)
   %% where "family" is the font family (e.g. 'helvetica'), "weight"
   %% is the font weight (e.g. 'bold'), "size" the font size
   %% (e.g. 10), "fill" the text color (e.g. 'Black'), and "text" any
   %% virtual string.
   FontCacheDict = {NewDictionary}
   fun {GetFont TextRec}
      FamilyV = TextRec.family
      WeightV = TextRec.weight
      SizeI = TextRec.size
      FontKeyV = FamilyV#WeightV#SizeI
      FontKeyA = {V2A FontKeyV}
   in
      if {HasFeature FontCacheDict FontKeyA} then
	 FontCacheDict.FontKeyA
      else
	 FontW = {New Tk.font tkInit(family: FamilyV
				     weight: WeightV
				     size: SizeI)}
      in
	 FontCacheDict.FontKeyA := FontW
	 FontW
      end
   end
   %% MeasureText: TextRec -> I
   %% Measures the text described by TextRec. Uses MeasureCacheDict
   %% to speed things up. I is in pixels.
   MeasureCacheDict = {NewDictionary}
   fun {MeasureText TextRec}
      FontW = {GetFont TextRec}
      FamilyV = TextRec.family
      WeightV = TextRec.weight
      SizeI = TextRec.size
      TextV = TextRec.text
      MeasureKeyV = FamilyV#WeightV#SizeI#TextV
      MeasureKeyA = {V2A MeasureKeyV}
   in
      if {HasFeature MeasureCacheDict MeasureKeyA} then
	 MeasureCacheDict.MeasureKeyA
      else
	 TextI = {FontW tkReturnInt(measure TextV $)}
      in
	 MeasureCacheDict.MeasureKeyA := TextI
	 TextI
      end
   end
end
