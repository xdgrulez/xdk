%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Inspector(inspect)
   Open(socket text)
   Tk(returnInt send)

   Parser(parser spaceManager) at 'x-oz://system/xml/Parser.ozf'
export
   ServerK

   Parse
   GetAttr

   AllEqual

   E2V

   X2A

   AppendList

   FillRec

   IsSubset

   MaxIs

   MaxSize
prepare
   RecordMapInd = Record.mapInd
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Mixin class for the server
   class ServerK from Open.socket Open.text end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% XML parser support
   class MyParserK from Parser.parser
      meth init
	 M = {New Parser.spaceManager init}
      in
	 {M stripSpace('*' '*')}
	 Parser.parser,init
	 {self setSpaceManager(M)}
      end
      meth onStartElement(Tag Alist Children)
	 {self append(
		  element(
		     name       : Tag.name
		     attributes : Alist
		     children   : Children
		     %%
		     coord      : Tag.coord))}
      end
      meth onAttribute(Tag Value)
	 {self attributeAppend(
		  attribute(
		     name  : Tag.name
		     value : Value
		     %%
		     coord : Tag.coord))}
      end
   end
   %%
   MyParserO = {New MyParserK init}
   %% Parse: V -> Elements
   %% Use the XML parser to parse virtual string V and return the XML
   %% elements Elements.
   fun {Parse V}
      Elements = {MyParserO parseVS(V $)}
   in
      Elements
   end
   %% GetAttr: Attrs NameA DefaultAttrA -> AttrA
   %% Get attribute with name NameA in Attrs, return DefaultAttrA if
   %% NameA not in Attrs. For obligatory attributes, use
   %% DefaultAttrA=noAttr (this triggers an exception if the
   %% obligatory attribute could not be found).
   fun {GetAttr Attrs NameA DefaultAttrA}
      AttrA =
      for Attr in Attrs default:DefaultAttrA return:Return do
	 if Attr.name==NameA then {Return Attr.value} end
      end
   in
      if AttrA==noAttr then
	 raise error1('functor':'Oracles/ManualOracle/Helpers.ozf' 'proc':'GetAttr' info:o(Attrs) msg:'Could not find obligatory attribute: '#NameA coord:noCoord file:noFile)
	 end
      end
      AttrA
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AllEqual: Xs -> B
   %% Returns true if all elements in Xs are equal, and false if not.
   fun {AllEqual Xs}
      Ys =
      {FoldL Xs
       fun {$ Acc X}
	  if {Member X Acc} then Acc
	  else X|Acc end
       end nil}
   in
      Ys==nil orelse {Length Ys}==1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %% E2V: E DebugB -> V
   %% Returns virtual string V corresponding to exception E.
   %% Inspects the entire exception if DebugB.
   fun {E2V E DebugB}
      if DebugB then {Inspector.inspect E} end
      %%
      V =
      case E
      of error1(msg: MsgA ...) then
	 MsgA
      [] error(url(_ File) ...) then
	 'Cannot open file: '#File
      [] xml(tokenizer ...) then
	 'XML tokenizer error '
      [] xml(parser:_ ...) then
	 MsgA = {Label E.parser}
      in
	 'XML parser error '#': '#MsgA
      [] system(module(notFound load A)) then
	 'Could not find functor '#A
      else
	 'unhandled error'
      end
   in
      V
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% X2V: X -> V
   %% Transforms value X into a virtual string V.
   fun {X2V X}
      V = {Value.toVirtualString X 10000 10000}
   in
      V
   end
   %% X2A: X -> A
   %% Transforms a value X into an atom A.
   V2A = VirtualString.toAtom
   %%
   fun {X2A X}
      V = {X2V X}
      A = {V2A V}
   in
      A
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% FillRec: Rec1 Rec2 -> Rec
   %% Recursively fills Rec1 with values from Rec2 for each field not
   %% present in Rec1. Can be used e.g. for filling options records
   %% (Rec1) with default values (Rec2).
   fun {FillRec Rec1 Rec2}
      {RecordMapInd Rec2
       fun {$ LI X}
	  if {HasFeature Rec1 LI} then
	     if {IsRecord X} andthen {Not {Arity X}==nil} then
		{FillRec Rec1.LI X}
	     else
		Rec1.LI
	     end
	  else
	     Rec2.LI
	  end
       end}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IsSubset: Xs Ys -> B
   %% Returns true if Xs denotes a subset of Ys, and false if not.
   fun {IsSubset Xs Ys}
      {All Xs
       fun {$ X} {Member X Ys} end}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MaxIs: Is -> I
   %% Get the maximum I in Is.
   fun {MaxIs Is}
      if {Length Is}==1 then
	 Is.1
      else
	 I1|Is1 = Is
      in
	 {FoldL Is1
	  fun {$ AccI I} {Max AccI I} end I1}
      end 
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MaxSize: W -> U
   %% Restrict the maximum size of Tk toplevel widget W to fit on the
   %% screen.
   proc {MaxSize W}
      %% get the width of the virtual root window (or the screen if
      %% there is none)
      VRootWidthI = {Tk.returnInt winfo(vrootwidth W)}
      %% get the height of the virtual root window (or the screen if
      %% there is none)
      VRootHeightI = {Tk.returnInt winfo(vrootheight W)}
      %%
      %% process pending events
      {Tk.send update}
      %% get the width
      WidthI = {Tk.returnInt winfo(width W)}
      %% get the height
      HeightI = {Tk.returnInt winfo(height W)}
      %%
      %% get the x coordinate of the window
      XI = {Tk.returnInt winfo(x W)}
      %% get the y coordinate of the window
      YI = {Tk.returnInt winfo(y W)}
      %%
      %% calculate new width
      NewWidthI = if VRootWidthI-XI-WidthI<0 then
		     VRootWidthI-XI
		  else
		     WidthI
		  end
      %% calculate new height
      NewHeightI = if VRootHeightI-YI-HeightI<0 then
		     VRootHeightI-YI
		  else
		     HeightI
		  end
   in
      %% set maximum size for window
      {Tk.send wm(geometry W '='#NewWidthI#'x'#NewHeightI)}
   end
end
