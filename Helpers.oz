%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Inspector(inspect)

   FD(sup)
   Open(file)
   OS(localTime)
   Resolve(handler native pickle)
   Tk(batch checkbutton entry frame image label message return toplevel variable)
   TkTools(dialog error)
   URL(make)
export
   CIL2A
   IIL2I

   GetLines
   GetS
   PutV
   
   AllButLast
   MemberInd
   X2V
   Vs2S
   Vs2A
   
   GetTime

   Normalize
   Segment
   GetWords
   
   GetFilePart
   ChangeSuffix
   GetSuffix
   
   TkDialog
   TkDialogImage
   TkDialog2
   TkError
   TkProgress
   TkGetS
   TkGetI
   TkGetSublist
   TkGetOpenFiles
   
   CoordFile2V
   E2V

   AddHandlers
prepare
   ListLast = List.last
   ListMapInd = List.mapInd
   ListTake = List.take
   %%
   I2S = Int.toString
   S2A = String.toAtom
   S2I = String.toInt
   V2S = VirtualString.toString
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into the corresponding atom A.
   fun {CIL2A CIL} CIL.data end
   %% IIL2I: IIL -> I
   %% Transforms an IL integer IIL into the corresponding integer I.
   fun {IIL2I IIL}
      I = IIL.data
      I1 = if I==infty then FD.sup else I end
   in
      I1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetLines: UrlV -> Ss
   %% Reads the lines of the file with URL UrlV into the list of
   %% strings Ss.
   fun {GetLines UrlV}
      S = {GetS UrlV}
      Ss = {String.tokens S &\n}
   in
      Ss
   end
   %% GetS: UrlV -> S
   %% Reads the contents of the file with URL UrlV into string S.
   fun {GetS UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [read text])}
      S
      {FileO read(list: S
		  size: all)}
      {FileO close}
   in
      S
   end
   %% PutV: V UrlV -> U
   %% Writes the virtual string V into a file with URL UrlV.
   proc {PutV V UrlV}
      FileO = {New Open.file init(name: UrlV
				  flags: [create truncate write text])}
   in
      {FileO write(vs: V)}
      {FileO close}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AllButLast: Xs -> Ys
   %% Takes all but the last element of a list Xs.
   fun {AllButLast Xs} {ListTake Xs {Length Xs}-1} end
   %% MemberInd: X Xs -> I
   %% If X is in Xs, then returns the first position (from the start of
   %% the list) where it could be found.  If X not in Xs, then returns 0.
   fun {MemberInd X Xs}
      fun {MemberInd1 I X Xs}
	 case Xs
	 of nil then 0
	 [] Y|Ys then
	    if X==Y then I else {MemberInd1 I+1 X Ys} end
	 end
      end
      I = {MemberInd1 1 X Xs}
   in
      I
   end
   %% X2V: X -> V
   %% Transforms value X into a virtual string V.
   fun {X2V X}
      V = {Value.toVirtualString X 10000 10000}
   in
      V
   end
   %% Vs2S: Vs -> S
   %% Converts a list of virtual strings Vs into a single string.
   fun {Vs2S Vs}
      if Vs==nil then
	 ""
      else
	 V1|Vs1 = Vs
	 V = {FoldL Vs1
	      fun {$ AccV V} AccV#","#V end V1}
	 S = {V2S V}
      in
	 S
      end
   end
   %% Vs2A: Vs -> A
   %% Converts a list of virtual strings Vs into an atom.
   fun {Vs2A Vs}
      S = {Vs2S Vs}
      A = {S2A S}
   in
      A
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetTime: U -> V
   %% Get virtual string V containing the current local time.
   fun {GetTime}
      LocalTime = {OS.localTime}
      MonthI = LocalTime.mon
      MonthA = case MonthI
	       of 0 then 'Jan'
	       [] 1 then 'Feb'
	       [] 2 then 'Mar'
	       [] 3 then 'Apr'
	       [] 4 then 'May'
	       [] 5 then 'Jun'
	       [] 6 then 'Jul'
	       [] 7 then 'Aug'
	       [] 8 then 'Sep'
	       [] 9 then 'Oct'
	       [] 10 then 'Nov'
	       [] 11 then 'Dec'
	       end
      DayI = LocalTime.mDay
      YearI = LocalTime.year
      YearI1 = YearI+1900
      HoursI = LocalTime.hour
      MinutesI = LocalTime.min
      MinutesV = if MinutesI<10 then
		    0#MinutesI
		 else
		    MinutesI
		 end
      SecondsI = LocalTime.sec
      SecondsV = if SecondsI<10 then
		    0#SecondsI
		 else
		    SecondsI
		 end
   in
      MonthA#' '#DayI#', '#YearI1#' '#HoursI#':'#MinutesV#':'#SecondsV
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Normalize: S -> S
   %% Removes superfluous spaces.
   fun {Normalize S}
      case S
      of nil then nil
      [] & |& |S1 then {Normalize & |S1}         %% 2 spaces -> 1 space
      []    Ch|S1 then Ch|{Normalize S1}         %% recurse
      end
   end
   %% Segment: S -> As
   %% Breaks up a string into a list of atoms.
   fun {Segment S}
      %% normalize
      S1 = {Normalize S}
      %% remove leading space if there is any
      S2 = case S1 
	   of & |S3 then S3
	   else S1
	   end
      %% tokenize into strings separated by spaces
      Ss = {String.tokens S2 & }
      As = {Map Ss S2A}
   in
      As
   end
   %% GetWords: W -> WordAs
   %% Gets a list of atoms from a Tk.entry-widget.
   fun {GetWords W}
      S = {W tkReturnString(get $)}
      As = {Segment S}
   in
      As
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetFilePart: V -> S
   %% Gets the file part of a path.
   fun {GetFilePart V}
      Url = {URL.make V}
      Ss = Url.path
      S = {ListLast Ss}
   in
      S
   end
   %% ChangeSuffix: V1 V2 -> S
   %% Changes the suffix of filename V1 to V2, and returns the changed string S.
   %% E.g. {ChangeSuffix "bla.ozf" "txt"} -> "bla.txt".
   fun {ChangeSuffix V1 V2}
      S1 = {V2S V1}
      S2 = {V2S V2}
      Ss = {String.tokens S1 &.}
      Ss1 = {AllButLast Ss}
      S3 =
      {FoldR Ss1
       fun {$ S AccS} {Append S &.|AccS} end nil}
      S4 = {Append S3 S2}
   in
      S4
   end
   %% GetSuffix: V -> S
   %% Gets the suffix of a filename.
   fun {GetSuffix V}
      S = {V2S V}
      Ss = {String.tokens S &.}
      S1 = {ListLast Ss}
   in
      S1
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% TkDialog: TitleV TextV -> U
   %% Displays a TkTools.dialog with title TitleV, text TextV and one
   %% button labeled 'Okay'
   proc {TkDialog TitleV TextV}
      DialogW = {New TkTools.dialog
		 tkInit(title: TitleV
			buttons: ['Okay'#tkClose]
			default: 1)}
      FrameW = {New Tk.frame tkInit(parent: DialogW)}
      MessageW = {New Tk.message tkInit(parent: FrameW
					text: TextV
					justify: center
					aspect: 400)}
   in
      {Tk.batch [pack(DialogW FrameW)
		 grid(MessageW row:0)]}
      {Wait DialogW.tkClosed}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% TkDialogImage: TitleV TextV ImagePathV -> U
   %% Displays a TkTools.dialog with title TitleV, the image at path
   %% ImagePathV, text TextV and one button labeled 'Okay'
   proc {TkDialogImage TitleV TextV ImagePathV}
      DialogW = {New TkTools.dialog
		 tkInit(title: TitleV
			buttons: ['Okay'#tkClose]
			default: 1)}
      FrameW = {New Tk.frame tkInit(parent: DialogW)}
      TextLabelW = {New Tk.label tkInit(parent: FrameW
					text: TextV)}
      ImageW = {New Tk.image tkInit(type: photo
				    format: gif
				    file: ImagePathV)}
      ImageLabelW = {New Tk.label tkInit(parent: FrameW
					 image: ImageW)}
   in
      {Tk.batch [pack(DialogW FrameW)
		 grid(ImageLabelW row:0)
		 grid(TextLabelW row:1)]}
      {Wait DialogW.tkClosed}
   end
   %% TkDialog2: TitleV TextV -> B
   %% Displays a TkTools.dialog with title TitleV, text TextV and two
   %% buttons labeled 'Okay' and 'Cancel'. Returns true if the user
   %% has chosen 'Okay', and false if the user has chosen 'Cancel'.
   fun {TkDialog2 TitleV TextV}
      OkayCancelB
      DialogW = {New TkTools.dialog
		 tkInit(title: TitleV
			buttons: ['Okay'#
				  proc {$}
				     OkayCancelB=true
				     {DialogW tkClose}
				  end
				  'Cancel'#
				  proc {$}
				     OkayCancelB=false
				     {DialogW tkClose}
				  end]
			default: 1)}
      FrameW = {New Tk.frame tkInit(parent: DialogW)}
      MessageW = {New Tk.message tkInit(parent: FrameW
					text: TextV
					justify: center
					aspect: 400)}
   in
      {Tk.batch [pack(DialogW FrameW)
		 grid(MessageW row:0)]}
      {Wait DialogW.tkClosed}
      OkayCancelB
   end
   %% TkError: TitleV TextV -> U
   %% Displays an error dialog with title TitleV and text TextV.
   proc {TkError TitleV TextV}
      DialogW =
      {New TkTools.error
       tkInit(title: TitleV
	      text: TextV)}
   in
      {Wait DialogW.tkClosed}
   end
   %% TkProgress: TitleV TextV -> W
   %% Displays a window with title TitleV and text TextV.
   %% Returns the window widget (to be able to close it later on).
   fun {TkProgress TitleV TextV}
      TopW = {New Tk.toplevel tkInit(title: TitleV)}
      FrameW = {New Tk.frame tkInit(parent: TopW)}
      LabelW = {New Tk.label tkInit(parent: FrameW
				    text: TextV)}
   in
      {Tk.batch [pack(FrameW) grid(LabelW row:0)]}
      TopW
   end
   %% TkGetS: TitleV TextV DefaultS -> S
   %% Gets a string S using a TkTools.dialog with title TitleV, text
   %% TextV and default DefaultS.
   fun {TkGetS TitleV TextV DefaultS}
      S
      DialogW = {New TkTools.dialog
		 tkInit(title: TitleV
			buttons: ['Okay'#
				  proc {$}
				     S = {EntryW tkReturn(get $)}
				     {DialogW tkClose}
				  end]
			default: 1)}
      LabelW = {New Tk.label tkInit(parent: DialogW
				    text: TextV)}
      EntryW = {New Tk.entry tkInit(parent: DialogW
				    text: "9999")}
      {EntryW tk(delete 0 'end')}
      {EntryW tk(insert 'end' DefaultS)}
   in
      {Tk.batch [pack(LabelW EntryW) focus(EntryW)]}
      {Wait DialogW.tkClosed}
      S
   end
   %% TkGetI: TitleV TextV DefaultI -> I
   %% Gets an integer I using a TkTools.dialog with title TitleV, text
   %% TextV and default DefaultI.
   fun {TkGetI TitleV TextV DefaultI}
      DefaultS = {I2S DefaultI}
      S = {TkGetS TitleV TextV DefaultS}
      I = {S2I S}
   in
      I
   end
   %% TkGetSublist: TitleV LabelTextV As OnAs GhostAs -> As1
   %% Gets a sublist As1 of the list of atoms As using checkbuttons.
   %% OnAs are the checkbuttons which are already switched on, and
   %% GhostAs are the checkbuttons ghosted when the dialog comes up.
   %% The dialog has title TitleV and label text LabelTextV.
   fun {TkGetSublist TitleV LabelTextV As OnAs GhostAs}
      DialogW = {New TkTools.dialog
		 tkInit(title: TitleV
			buttons: ['Okay'#tkClose]
			default: 1)}
      LabelW = {New Tk.label tkInit(parent: DialogW
				    text: LabelTextV)}
      Tkvars = {Map As
		fun {$ A}
		   OnB = {Member A OnAs}
		in
		   {New Tk.variable tkInit(OnB)}
		end}
      CheckButtonWs = {ListMapInd As
		       fun {$ I A}
			  StateA =
			  if {Member A GhostAs} then
			     disabled
			  else
			     normal
			  end
		       in
			  {New Tk.checkbutton
			   tkInit(parent: DialogW
				  variable: {Nth Tkvars I}
				  text: A
				  state: StateA)}
		       end}
      {Tk.batch [pack(LabelW)
		 pack(b(CheckButtonWs))]}
      {Wait DialogW.tkClosed}
      As1 =
      for Tkvar in Tkvars I in 1..{Length Tkvars} collect:Collect do
	 B = {Tkvar tkReturnInt($)}==1
      in
	 if B then {Collect {Nth As I}} end
      end
   in
      As1
   end
   %%
   fun {ParseGetOpenFileS S WithinBracketsB AccS AccSs}
      case S
      of nil then
	 {Append AccSs [AccS]}
      [] Ch|S1 then
	 case Ch
	 of &{ then {ParseGetOpenFileS S1 true AccS AccSs}
	 [] &} then {ParseGetOpenFileS S1 false AccS AccSs}
	 [] &  then
	    if WithinBracketsB then
	       {ParseGetOpenFileS S1 WithinBracketsB {Append AccS [Ch]} AccSs}
	    else
	       {ParseGetOpenFileS S1 WithinBracketsB nil {Append AccSs [AccS]}}
	    end
	 else
	    {ParseGetOpenFileS S1 WithinBracketsB {Append AccS [Ch]} AccSs}
	 end
      end
   end
   %% TkGetOpenFiles: TitleV FiletypesRec -> Ss
   %% Gets a list of files Ss using a file dialog.
   fun {TkGetOpenFiles TitleV FiletypesRec}
      S = {Tk.return tk_getOpenFile(title: TitleV
				    filetypes: FiletypesRec
				    multiple: true)}
      Ss =
      if S=="" then
	 nil
      else
	 {ParseGetOpenFileS S false nil nil}
      end
   in
      Ss
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CoordFile2V: Coord File -> V
   %% Transforms a coordinate Coord and file File into a virtual
   %% string V.
   fun {CoordFile2V Coord File}
      CoordV =
      case Coord
      of I1#I2 then
	 if I1==I2 then
	    I1
	 else
	    I1#'-'#I2
	 end
      [] noCoord then noCoord
      elseif {IsInt Coord} then Coord
      else
	 raise error1('functor':'Helpers.ozf' 'proc':'CoordFile2V' msg:'Illformed coordinate.' info:o(Coord) coord:noCoord file:noFile) end
      end
      CoordV1 = if CoordV==noCoord then
		   'no line'
		else
		   'line: '#CoordV
		end
      FileV = if File==noFile then
		 'no file'
	      else
		 'file: '#File
	      end
      V = if CoordV1=='no line' andthen FileV=='no file' then ''
	  else '('#CoordV1#', '#FileV#')'
	  end
   in
      V
   end
   %% E2V: E -> V
   %% Returns virtual string V corresponding to exception E.
   fun {E2V E}
      V =
      case E
      of error1(msg: MsgA
		coord: Coord
		file: File ...) then
	 CoordFileV = {CoordFile2V Coord File}
      in
	 MsgA#' '#CoordFileV
      [] error(kernel(stringNoInt S) ...) then
	 'Could not convert string to integer: "'#S#'"'
      [] tokenizer(MsgA Coord File ...) then
	 CoordFileV = {CoordFile2V Coord File}
      in
	 'UL tokenizer error '#CoordFileV#': '#MsgA
      [] error(url(_ File) ...) then
	 'Cannot open file: '#File
      [] parser(input:token(coord:Coord file:File ...)|_
		...) then
	 CoordV = {CoordFile2V Coord File}
      in
	 'UL parser error '#CoordV
      [] parser(input:token(sem:_ sym:_)|_
		stack:_|token(coord:Coord file:File ...)|_ ...) then
	 CoordV = {CoordFile2V Coord File}
      in
	 'UL parser error '#CoordV
      [] xml(tokenizer(line:Coord file:File ...) ...) then
	 CoordV = {CoordFile2V Coord File}
      in
	 'XML tokenizer error '#CoordV
      [] xml(parser:_ ...) then
	 MsgA = {Label E.parser}
	 File = E.parser.coord.1
	 Coord = E.parser.coord.2
	 CoordFileV = {CoordFile2V Coord File}
      in
	 'XML parser error '#CoordFileV#': '#MsgA
      [] system(module(notFound load A)) then
	 'Could not find functor "'#A#'"'
      [] system(os(os "connect" _ "Connection refused")
		debug:d(info:fapply(_
				    [_ _ PortI] ...)|_ ...)) then
	 'Socket error: Connection to port '#PortI#' refused (hint: check whether the server is running or choose another port).'
      [] system(os(os "open" _ "No such file or directory")
		debug:d(info:[fapply(_
				     [UrlS _ _] 1)] ...)) then
	 'Open file error: Cannot open file "'#UrlS#'".'		
      [] system(os(os "CreateProcess" _ "Cannot create process.")
		debug:d(info:[fapply(_
				     [UrlS _] _)] ...)) then
	 'Cannot launch shell command "'#UrlS#'".'
      else
	 'unhandled error'
      end
   in
      V
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AddHandlers: U -> U
   %% Add resolve handlers for finding native functors.
   proc {AddHandlers}
      Handler = {Resolve.handler.prefix "x-ozlib://debusmann/xdk/" "./"}
   in
      {Resolve.pickle.addHandler front(Handler)}
      {Resolve.native.addHandler front(Handler)}
   end
end