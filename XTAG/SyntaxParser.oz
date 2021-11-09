%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(show)
   Inspector(inspect)

   Open(file text)
   Pickle(load saveCompressed)
   
   Helpers(mid fileExists) at 'Helpers.ozf'
export
   Parse
prepare
   ListLast = List.last
   ListTake = List.take
   ListZip = List.zip
define
   A2S = Atom.toString
   S2A = String.toAtom
   V2A = VirtualString.toAtom
   %%
   fun {GetValues1 S I AccIITups}
      case S
      of nil then
	 I1|AccIITups1 = AccIITups
      in
	 ((I1+1)#I)|AccIITups1
      [] &>|&>|S1 then
	 {GetValues1 S1 I+2 (I+2)|AccIITups}
      [] &<|&<|S1 then
	 if AccIITups==nil then
	    {GetValues1 S1 I+2 AccIITups}
	 else
	    I1|AccIITups1 = AccIITups
	 in
	    {GetValues1 S1 I+2 ((I1+1)#I)|AccIITups1}
	 end
      [] _|S1 then
	 {GetValues1 S1 I+1 AccIITups}
      end
   end
   fun {GetValues S}
      {Reverse {GetValues1 S 0 nil}}
   end
   %%
   fun {PurePosA PosA}
      PosS = {A2S PosA}
      PosS1 = if {Member {ListLast PosS} [&1 &2 &4]} then
		 {ListTake PosS {Length PosS}-1}
	      else
		 PosS
	      end
   in
      {S2A PosS1}
   end
   %%
   class TextFileK from Open.file Open.text end   
   %%
   fun {ParseUrl V}
      TextFileO = {New TextFileK init(url: V)}
      %%
      proc {Read}
	 S = {TextFileO getS($)}
      in
	 if {Not S==false} then
	    IITups = {GetValues S}
	    LastA = {S2A {Helpers.mid S {ListLast IITups}.1 {ListLast IITups}.2}}
	    IITups1 =
	    if {Member LastA ['unionizing ideology' 'The sun is scorching' 'scorching sun']} then
	       {ListTake IITups {Length IITups}-1}
	    elseif {IsEven {Length IITups}} then
	       {Append IITups [{Length IITups}#{Length IITups}]}
	    else
	       IITups
	    end
	    %%
	    IndexI1#IndexI2 = IITups1.1
	    IndexA = {S2A {Helpers.mid S IndexI1 IndexI2}}
	    %%
	    FeaturesI1#FeaturesI2 = {ListLast IITups1}
	    FeaturesS = {Helpers.mid S FeaturesI1 FeaturesI2}
	    FeaturesSs = {String.tokens FeaturesS & }
	    FeaturesAs = {Map FeaturesSs S2A}
	    %%
	    TreesI1#TreesI2 = {Nth IITups1 {Length IITups1}-1}
	    TreesS = {Helpers.mid S TreesI1 TreesI2}
	    TreesSs = {String.tokens TreesS & }
	    TreesSs1 = {Map TreesSs
			fun {$ S}
			   Ch|S1 = S
			   S2 = case Ch
				of &\002 then
				   {Append "alpha" S1}
				[] &\003 then
				   {Append "beta" S1}
				else
				   S
				end
			in
			   S2
			end}
	    TreesAs = {Map TreesSs1 S2A}
	    %%
	    EntryAs =
	    for I1#I2 in IITups1 I in 1..{Length IITups1} collect:Collect do
	       if {Member I [2 4 6 8 10]} andthen {Not I>({Length IITups1}-2)} then
		  EntryA = {S2A {Helpers.mid S I1 I2}}
	       in
		  {Collect EntryA}
	       end
	    end
	    %%
	    PosAs =
	    for I1#I2 in IITups1 I in 1..{Length IITups1} collect:Collect do
	       if {Member I [3 5 7 9 11]} andthen {Not I>({Length IITups1}-2)} then
		  PosA = {S2A {Helpers.mid S I1 I2}}
	       in
		  {Collect PosA}
	       end
	    end
	    %%
	    PosAEntryATups = {ListZip PosAs EntryAs
			      fun {$ PosA EntryA} PosA#EntryA end}
	    %%
	    PosAEntryATups1 =
	    if IndexA=='off' andthen PosAEntryATups==['Ad'#'off'] andthen
	       TreesAs==['Tnx0Px1'] then
	       ['P'#'off']
	    else
	       PosAEntryATups
	    end
	    %%
	    Rec = o(index: IndexA
		    anchors: PosAEntryATups1
		    trees: TreesAs
		    features: FeaturesAs)
	    %%
	    _|PosAEntryATups2 = PosAEntryATups1
	    %%
	    Recs = {CondSelect SyntaxDict IndexA nil}
	 in
	    SyntaxDict.IndexA := {Append Recs [Rec]}
	    %%
	    for PosA#EntryA in PosAEntryATups2 do
	       PosA1 = {PurePosA PosA}
	       Rec = o(index: EntryA
		       anchors: [PosA1#EntryA]
		       trees: [{V2A 'alpha'#PosA1}]
		       features: nil)
	       Recs = {CondSelect SyntaxDict EntryA nil}
	    in
	       if {Not {Member Rec Recs}} then
		  SyntaxDict.EntryA := {Append Recs [Rec]}
	       end
	    end
	    {Read}
	 end
      end
      %%
      SyntaxDict = {NewDictionary}
      {Read}
      SyntaxRec = {Dictionary.toRecord o SyntaxDict}
   in
      SyntaxRec
   end
   %%
   fun {Parse}
      SyntaxRec =
      if {Helpers.fileExists 'syntax.ozp'} then
	 {Pickle.load 'syntax.ozp'}
      else
	 {System.show start#'syntax'}
	 SyntaxRec1 = {ParseUrl 'Grammar/syntax.flat'}
      in
	 {Pickle.saveCompressed SyntaxRec1 'syntax.ozp' 9}
	 {System.show done}
	 SyntaxRec1
      end
   in
      SyntaxRec
   end
end
