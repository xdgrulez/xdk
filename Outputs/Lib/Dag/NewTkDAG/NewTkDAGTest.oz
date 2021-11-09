declare
[NewTkDAG] = {Link ['../../../../Outputs/Lib/Dag/NewTkDAG/NewTkDAG.ozf']}
%%
Nodes = [
	 o(index: 1
	   depth: 3
	   string: o(text: 'node1')
	   label: o(text: 'label1')
	   info1: 'Knoten 1')
	 o(index: 2
	   string: o(text: 'node2')
	   label: o(text: 'label2'
		    family: 'Courier'
		    size: 20)
	   info1: 'Knoten 2, info1'
	   info2: 'Knoten 2, info2'
	   info3: 'Knoten 2, info3')
	 o(index: 3
	   string: o(text: 'node3'
		     fill: 'Gray')
	   label: o(text: 'label3'
		    fill: 'Black')
	   line: o(fill: 'Red'
		   width: 2)
	   info1: 'Knoten 3, info1'
	   info2: 'Knoten 3, info2'
	   info3: 'Knoten 3, info3')
	]
Edges = [
	 o(index1: 2
	   index2: 3
	   label: o(text: 'edge1'))
	 o(index1: 3
	   index2: 1
	   label: o(text: 'edge2'
		    fill: 'Pink')
	   line: o(fill: 'Red')
	   width: 4
	  )
	]
%%
OptRec = o(hstep: 40
	   vstep: 20
	   minnodewidth: 20
	   minnodeheight: 20
	   hdist: 50
	   vdist: 60
	   edge: o(line: o(arrow: last)))
%%

/*

declare
ToplevelW1 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}

ToplevelW2 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW3 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW4 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW5 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW6 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW7 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW8 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}
ToplevelW9 = {NewTkDAG.makeToplevel Nodes Edges 'NewTkDAG Window' OptRec}

*/

/*

declare
ToplevelW = {NewTkDAG.makeToplevelLr [id#Nodes#Edges lp#Nodes#Edges] 'NewTkDAG Window' OptRec}

*/

/*

declare
ToplevelW = {New Tk.toplevel tkInit(title:'NewTkDAG Window')}
FrameW = {NewTkDAG.makeFrameLr [id#Nodes#Edges lp#Nodes#Edges] ToplevelW OptRec}
{Tk.batch [
	   grid(rowconfigure ToplevelW 0 weight:1)
	   grid(columnconfigure ToplevelW 0 weight:1)
	   grid(FrameW row:0 column:0 sticky:nswe)
	  ]}

*/

/*

declare
ToplevelW = {New Tk.toplevel tkInit(title:'NewTkDAG Window')}
FrameW = {NewTkDAG.makeFrameTd [id#Nodes#Edges lp#Nodes#Edges] ToplevelW OptRec}
{Tk.batch [
	   grid(rowconfigure ToplevelW 0 weight:1)
	   grid(columnconfigure ToplevelW 0 weight:1)
	   grid(FrameW row:0 column:0 sticky:nswe)
	  ]}

*/
