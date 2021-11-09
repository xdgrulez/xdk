%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Tk(returnInt send)
export
   FillRec

   Sum
   SumI
   MaxIs   

   MaxSize
prepare
   ListTake = List.take
   RecordMapInd = Record.mapInd
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Sum: Is -> I
   %% Calculates the sum of all Is.
   fun {Sum Is}
      {FoldL Is fun {$ AccI I} AccI+I end 0}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% SumI: Is I -> I
   %% Calculates the sum of the first I Is.
   fun {SumI Is I}
      Is1 = {ListTake Is I}
   in
      {FoldL Is1 fun {$ AccI I} AccI+I end 0}
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
      {Tk.send update(idletasks)}
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
