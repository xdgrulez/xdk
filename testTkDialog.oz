declare
proc {TkDialog TitleV TextV}
   DialogW = {New TkTools.dialog
	      tkInit(title: TitleV
		     buttons: ['Okay'#tkClose]
		     default: 1)}
   FrameW = {New Tk.frame tkInit(parent: DialogW)}
   TextLabelW = {New Tk.message tkInit(parent: FrameW
				       text: TextV
				       justify: left
				       aspect: 500)}
in
   {Tk.batch [pack(DialogW FrameW)
	      grid(TextLabelW row:0)]}
   {Wait DialogW.tkClosed}
end
{TkDialog 'Title' 'This is a long text and it has no line breaks and I hope Tk will do its work... This is a long text and it has no line breaks and I hope Tk will do its work...'}
[Helpers] = {Module.link ['Helpers.ozf']}
{Helpers.tkError 'Bla' 'This is a long text and it has no line breaks and I hope Tk will do its work... This is a long text and it has no line breaks and I hope Tk will do its work...'}
