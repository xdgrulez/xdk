%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:23 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

%% This functor provides an externaliser for CLLS search problems, as
%% they are used in the various solvers written in the context of the
%% CHORUS project.  In the current setup, only dominance, labelling,
%% and inequality literals are externalised; however, the externaliser
%% could easily be adapted to include more information.

functor
import
   CLLS at 'x-ozlib://chorus/clls/clls.ozf'

   Externaliser at 'Externaliser.ozf'
   Helpers at 'Helpers.ozf'
export
   externaliser: KMExternaliser
define
   LogPrefix = "KMExternaliser"
   
   class KMExternaliser from Externaliser.externaliser
      %% initialisation
      meth init Externaliser.externaliser,init end

      %% Produce a description of the CLLS fragment of an RCLLS
      %% constraint (the root variable of an RCLLS search problem).
      %% This returns a sorted list of literals.
      meth describe(Literals $)
	 fun {FilterP L}
	    case L
	    of ana(...) then true
	    [] dom(...) then true
	    [] label(...) then true
	    [] lam(...) then true
	    [] lamInv(...) then true
	    [] notEqual(...) then true
	    else false end
	 end
	 
	 %% Filter out the interesting literals from the snapshot of
	 %% the CLLS constraint.
	 {self log(LogPrefix "before list.terminate")}
	 Literals2 = {CLLS.filter {Helpers.list.terminate Literals} FilterP}
	 {self log(LogPrefix "before list.terminate")}
      in
	 {self log(LogPrefix "method call: describe")}
	 {List.sort Literals2 Helpers.record.sortP}
      end

      %% Compute the diff between two descriptions.
      meth diff(Description1 Description2 $)
	 {self log(LogPrefix "method call: diff")}
	 {Helpers.list.diff Description1 Description2}
      end

      %% Externalise a description.
      meth externalise(Description $)
	 %% Externalise a single CLLS literal.  This returns a string
	 %% containing XML according to the DomML DTD.
	 fun {ExternaliseLiteral Literal}
	    LiteralElement

	    %% auxiliary procedures
	    proc {NewVariableElement Id VariableElement}
	       {New Helpers.xml.element init("var") VariableElement}
	       {VariableElement addAttribute("id" Id)}
	    end
	    proc {NewLiteralElement Id Vs LiteralElement}
	       {New Helpers.xml.element init(Id) LiteralElement}
	       for V in Vs do
		  {LiteralElement addChild({NewVariableElement V})}
	       end
	    end
	 in
	    case Literal
	    of ana(V1 V2) then
	       {NewLiteralElement "ana" [V1 V2] LiteralElement}
	    [] dom(V1 V2) then
	       {NewLiteralElement "dom" [V1 V2] LiteralElement}
	    [] label(V T) then
	       L = case {Record.label T} of '\&' then 'AND'
		   [] L then L
		   end
	    in
	       {NewLiteralElement "label" V|{Record.toList T} LiteralElement}
	       {LiteralElement addAttribute("label" L)}
	    [] lam(V1 V2) then
	       {NewLiteralElement "lam" [V1 V2] LiteralElement}
	    [] lamInv(V Vs) then
	       {NewLiteralElement "lamInv" V|Vs LiteralElement}
	    [] notEqual(V1 V2) then
	       {NewLiteralElement "notEqual" [V1 V2] LiteralElement}
	    else
	       raise unexpectedLiteral(Literal) end
	    end
	    {LiteralElement toString($)}
	 end
      in
	 {self log(LogPrefix "method call: externalise")}
	 {Helpers.string.concat {List.map Description ExternaliseLiteral}}
      end
   end
end
