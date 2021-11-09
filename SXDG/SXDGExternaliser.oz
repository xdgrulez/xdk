%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:24 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

%% This functor provides the externaliser used in the standard SXDG
%% setup.  It should eventually become part of a more generic approach
%% to externalising XDG grammars (see XDGExternaliser.oz).

functor
import
   FD FS
   Externaliser at 'Externaliser.ozf'
   Helpers at 'Helpers.ozf'
export
   externaliser: SXDGExternaliser
define
   LogPrefix = "SXDGExternaliser"
   
   class SXDGExternaliser from Externaliser.externaliser
      attr grammar

      %% initialisation
      meth init(Grammar)
	 Externaliser.externaliser,init
	 {self log(LogPrefix "method call: init")}
	 grammar <- Grammar
      end

      %% Produce an SXDG description of the root variable of an XDG
      %% search problem.  This returns a sorted list of records.
      meth describe(Nodes $)
	 {self log(LogPrefix "method call: describe")}

	 LabelLat = {@grammar.dIDA2LabelLat id}
	 
	 Description =
	 {List.map Nodes
	  fun {$ Node}
	     Model = Node.id.model
	     Word = Node.lex.entry.word
	     Entries = {List.toTuple unit @grammar.aEntriesRec.Word}
	     
	     %% mothers for Node, sorted by their labels
	     MyMothersByLabel =
	     {List.sort
	      {List.foldL {FS.reflect.upperBoundList Model.labels}
	       fun {$ Acc LI}
		  L = {LabelLat.i2AI LI}
	       in
		  {List.append Acc
		   {List.map {FS.reflect.upperBoundList Model.mothersL.L}
		    fun {$ MI}
		       %% Note that we choose the feature 'mother' here
		       %% so that the sort predicate (which sorts
		       %% lexicographically) will sort by label.
		       unit(label:L mother:MI)
		    end}}
	       end nil}
	      Helpers.record.sortP}
	     
	     %% lexical entries for Node
	     MyEntries =
	     {List.sort
	      {List.map {FD.reflect.domList Node.entryIndex}
	       fun {$ EI}
		  Entry = Entries.EI.lex
		  POS = {Value.condSelect Entry pos 'DUMMY'}
		  Tree = {Value.condSelect Entry lexentry 0}
	       in
		  unit(word:Entry.word pos:POS et:Tree)
	       end}
	      Helpers.record.sortP}
	  in
	     unit(id: Node.index
		  mothersByLabel: MyMothersByLabel
		  entries: MyEntries)
	  end}
      in
	 Description
      end

      %% Compute the diff between two descriptions.
      meth diff(Description1 Description2 $)
	 {self log(LogPrefix "method call: diff")}
	 Diff =
	 {List.map {List.zip Description1 Description2 fun {$ X Y} X#Y end}
	  fun {$ D1#D2}
	     MothersByLabel =
	     {Helpers.list.diff D1.mothersByLabel D2.mothersByLabel}
	     Entries =
	     {Helpers.list.diff D1.entries D2.entries}
	  in
	     unit(id: D1.id
		  mothersByLabel: MothersByLabel
		  entries: Entries)
	  end}
      in
	 Diff
      end

      %% Externalise a description.
      meth externalise(Description $)
	 Result = {Cell.new ""}
      in
	 for D in Description do
	    Old = {Cell.access Result}
	    NodeElement = {New Helpers.xml.element init("node")}
	 in
	    {NodeElement addAttribute("id" D.id)}

	    %% Externalise the mothers, sorted by label.
	    for M in D.mothersByLabel do
	       MotherByLabelElement = {New Helpers.xml.element init("mother")}
	    in
	       {MotherByLabelElement addAttribute("id" M.mother)}
	       {MotherByLabelElement addAttribute("label" M.label)}
	       {NodeElement addChild(MotherByLabelElement)}
	    end

	    %% Externalise the entries.
	    for E in D.entries do
	       EntryElement = {New Helpers.xml.element init("entry")}
	    in
	       {EntryElement addAttribute("id" E.word#"_"#E.pos#"_"#E.et)}
	       {NodeElement addChild(EntryElement)}
	    end

	    {Cell.assign Result Old#{NodeElement toString($)}}
	 end

	 {Cell.access Result}
      end
   end
end
