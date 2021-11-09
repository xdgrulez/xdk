%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Open(file text)
   OS(read stat unlink)
   Resolve(handler native pickle)
   Tk(batch entry frame image label message)
   TkTools(dialog error)
   
   String1(splitAtMost) at 'x-oz://system/String.ozf'
export
   CoordFile2V
   E2V

   TkError
   TkDialog2
   TkDialogImage
   TkGetS
   
   AddHandlers

   NoDoubles

   ReadFromSocket

   Dup
   FileExists
   GetLines
   GetS
   Mv
   PutLines

   IsSubstring

   GetSuffix
   RemoveSuffix
prepare
   ListLast = List.last
define
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
      [] error(url(_ File) ...) then
	 'Cannot open file: '#File
      [] system(module(notFound load A)) then
	 'Could not find functor "'#A#'"'
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
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AddHandlers: U -> U
   %% Add resolve handlers for finding native functors.
   proc {AddHandlers}
      Handler = {Resolve.handler.prefix "x-ozlib://debusmann/xdk/" "./"}
   in
      {Resolve.pickle.addHandler front(Handler)}
      {Resolve.native.addHandler front(Handler)}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% NoDoubles: Xs -> Ys
   %% Removes double elements from list Xs.
   fun {NoDoubles Xs}
      {FoldL Xs fun {$ AccXs X}
		   if {Member X AccXs} then
		      AccXs
		   else
		      {Append AccXs [X]}
		   end
		end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ReadFromSocket: SocketI -> Ss
   %% Reads list of strings from socket SocketI.
   fun {ReadFromSocket SocketI}
      fun {ReadFromSocket1 SocketI AccS}
	 S
	 TailX
	 ReadI
      in
	 {OS.read SocketI 10000 S TailX ReadI}
	 TailX = nil
	 if ReadI==0 then
	    Ss = {String.tokens AccS &\n}
	    Ss1 = {Map Ss
		       fun {$ S}
			  {Filter S
			   fun {$ Ch} {Not Ch==&\r} end}
		       end}
	 in
	    Ss1
	 else
	    {ReadFromSocket1 SocketI {Append AccS S}}
	 end
      end
   in
      {ReadFromSocket1 SocketI nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Dup: V1 V2 -> U
   %% Duplicates file with URL UrlV1 as file with URL UrlV2.
   proc {Dup UrlV1 UrlV2}
      S1 = {V2S UrlV1}
      S2 = {V2S UrlV2}
      if  S1==S2 then
	 raise error1('functor':'Compiler/Helpers.ozf' 'proc':'Cp' msg:'"'#S1#'" and "'#S2#'" are the same file.' info:o(S1 S2) coord:noCoord file:noFile) end
      end
      FileO1 = {New Open.file init(name: S1)}
      DataS1 = {FileO1 read(list: $
			    size: all)}
      {FileO1 close}
      FileO2 = {New Open.file init(name: S2
				   flags: [create truncate write])}
   in
      {FileO2 write(vs: DataS1)}
      {FileO2 close}
   end
   %% FileExists: V -> B
   %% Returns true if the file with path V exists, and false if not.
   fun {FileExists V}
      B
      try
	 _ = {OS.stat V}
	 B = true
      catch _ then
	 B = false
      end
   in
      B
   end
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
   %% Mv: UrlV1 UrlV2 -> U
   %% Moves file with URL UrlV1 to file with URL UrlV2.
   proc {Mv UrlV1 UrlV2}
      {Dup UrlV1 UrlV2}
      {OS.unlink UrlV1}
   end
   %% PutLines: Vs UrlV -> U
   %% Creates a file with URL UrlV and fills it with the lines Vs.
   class TextFileK from Open.file Open.text end
   %%
   proc {PutLines Vs UrlV}
      FileO = {New TextFileK init(name: UrlV
				  flags: [create truncate write text])}
   in
      for V in Vs do {FileO putS(V)} end
      {FileO close}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IsSubstring: SubS S -> B
   %% Checks whether SubS is a substring of S.
   fun {IsSubstring SubS S}
      Ss = {String1.splitAtMost S SubS 1}
   in
      {Length Ss}==2
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% GetSuffix: V -> S
   %% Gets the suffix of a filename.
   V2S = VirtualString.toString
   %%
   fun {GetSuffix V}
      S = {V2S V}
      Ss = {String.tokens S &.}
      S1 = {ListLast Ss}
   in
      S1
   end
   %% RemoveSuffix: V SeparatorCh -> S
   %% Removes suffix from virtual string V, separated by separator
   %% character SeparatorCh. E.g. {RemoveSuffix "hallo#20" &#} returns
   %% "hallo".
   fun {RemoveSuffix V SeparatorCh}
      S = {V2S V}
      Ss = {String.tokens S SeparatorCh}
   in
      if {Length Ss}>1 then
	 LastS = {List.last Ss}
	 S1 = {List.take S {Length S}-({Length LastS}+1)}
      in
	 S1
      else
	 S
      end
   end
end
