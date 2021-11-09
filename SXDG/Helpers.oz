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

%% Some of this code was copied from XDG's Helpers.oz.  It should
%% eventually be merged back.

functor
import
   Open
   Log at 'Log.ozf'
export
   list:ListFunctions
   log:LogFunctions
   record:RecordFunctions
   string:StringFunctions
   xml:XML
   File
   RemovePunctuation
   StripPOSTags
define
   
   %% ----------------------------------------------------------------
   %% Common helper functions
   %% ----------------------------------------------------------------

   %% Compare realises an alternative interface to Value.'<'.  When
   %% called with two arguments X and Y, it will return the literals
   %% lt, gt, or eq, if X<Y, X>Y, or X==Y, respectively.  Note that
   %% Compare can be applied even to values that cannot be compared
   %% using Value.'<', because the first test is on equality.
   
   fun {Compare X Y} if X==Y then eq elseif X<Y then lt else gt end end

   %% ----------------------------------------------------------------
   %% File helper functions
   %% ----------------------------------------------------------------

   %% Mix-in class for text files
   class TextFile from Open.file Open.text end
   
   %% Read lines from FileName
   fun {FileGetLines FileName}
      FileIO = {New TextFile init(url:FileName)}
      fun {GetLinesAux Acc}
	 S = {FileIO getS($)}
      in
	 if S == false then %% EOF
	    {List.reverse Acc}
	 else
	    {GetLinesAux S|Acc}
	 end
      end
      Lines = {GetLinesAux nil}
   in
      {FileIO close} Lines
   end

   File = unit(getLines:FileGetLines)

   %% ----------------------------------------------------------------
   %% List helper functions
   %% ----------------------------------------------------------------

   %% Given two lists Xs and Ys, return the list of those elements of
   %% Ys not contained in Xs. This assumes that both Xs and Ys are
   %% sorted using the same order, and that all elements contained in
   %% Xs are also contained in Ys.
   
   fun {ListDiff Xs Ys}
      case Ys
      of nil then nil
      [] Y|R then
	 case Xs
	 of nil then Ys
	 [] X|L then if X == Y then {ListDiff L R} else Y|{ListDiff Xs R} end
	 end
      end
   end

   %% Terminate a list that ends in an undetermined variable.
   
   fun {ListTerminate Xs}
      if {Value.isDet Xs} then
	 case Xs
	 of nil then nil
	 [] H|T then H|{ListTerminate T}
	 end
      else
	 nil
      end
   end
	 
   ListFunctions = unit(diff:ListDiff terminate:ListTerminate)
   
   %% ----------------------------------------------------------------
   %% Log functions
   %% ----------------------------------------------------------------
   
   %% Return a new log object, propagating any information about the
   %% desired logging level contained in options.
   
   fun {LogMake Options Prefix}
      LogObject = {New Log.log init(Prefix)}
   in
      if {Value.hasFeature Options loggingLevel} then
	 {LogObject setLoggingLevel(Options.loggingLevel)}
      end
      LogObject
   end

   LogFunctions = unit(make:LogMake)

   %% ----------------------------------------------------------------
   %% Record helper functions
   %% ----------------------------------------------------------------

   %% The following helper function realises a simple sort predicate
   %% for records -- i.e., a function that returns true if its first
   %% argument is "smaller" according to some order than its second
   %% argument.  In this case, R1 is considered smaller if either its
   %% literal is smaller than R2's literal (with respect to Compare),
   %% its width is less than R2's width, or if R1 is pointwise smaller
   %% than R2 at any of its components.
   
   fun {RecordSortP R1 R2}
      fun {RecordSortPAux R1 R2 F Fs}
	 case {Compare R1.F R2.F}
	 of lt then true
	 [] gt then false
	 [] eq then
	    case Fs
	    of nil then true
	    [] H|T then {RecordSortPAux R1 R2 H T}
	    end
	 end
      end
   in
      case {Compare {Record.label R1} {Record.label R2}}
      of lt then true
      [] gt then false
      [] eq then As = {List.sort {Record.arity R1} Value.'<'} in
	 case As
	 of nil then true
	 [] H|T then {RecordSortPAux R1 R2 H T}
	 end
      end
   end

   RecordFunctions = unit(sortP:RecordSortP)

   %% ----------------------------------------------------------------
   %% String helper functions
   %% ----------------------------------------------------------------
   
   fun {StringConcatWith S Xs}
      {VirtualString.toString
       {List.foldL Xs
	fun {$ A X} case A of "" then X else A#S#X end end ""}}
   end
   fun {StringConcat Xs}
      {StringConcatWith "" Xs}
   end
   fun {StringPad S N}
      Padding =
      {StringConcat {List.map {List.number 1 N 1} fun {$ I} " " end}}
   in
      {VirtualString.toString Padding#S#Padding}
   end

   StringFunctions = unit(concat:StringConcat
			  concatWith:StringConcatWith
			  pad:StringPad)

   %% ----------------------------------------------------------------
   %% XML helper functions
   %% ----------------------------------------------------------------

   %% The Element class provides a simple abstract data type for XML
   %% elements.

   class Element
      attr name attributes children
      meth init(TagName)
	 name <- TagName
	 attributes <- nil
	 children <- nil
      end
      meth addAttribute(AttributeName AttributeValue)
	 attributes <- (AttributeName#AttributeValue)|@attributes
      end
      meth addChild(ChildElement)
	 %% Note that children are added in reverse order, but that
	 %% the list of children is reversed again when calling
	 %% toString.
	 children <- ChildElement|@children
      end
      meth addChildString(ChildString)
	 children <- string(ChildString)|@children
      end
      meth toString($)
	 LPart =
	 {List.foldL @attributes fun {$ VS A#V} VS#" "#A#"=\""#V#"\"" end @name}
	 CPart =
	 {List.foldL {List.reverse @children}
	  fun {$ VS C}
	     case C
	     of string(S) then VS#S
	     else VS#{C toString($)} end
	  end ""}
	 RPart = @name
      in
	 case @children
	 of nil then {VirtualString.toString "<"#LPart#" />"}
	 else {VirtualString.toString "<"#LPart#">"#CPart#"</"#RPart#">"}
	 end
      end
   end

   XML = unit(element:Element)

   %% ----------------------------------------------------------------
   %% Other helper functions
   %% ----------------------------------------------------------------
   
   %% removePunctuation : string -> atom list
   %%
   %% Remove punctuation from Sentence, and return the rest as a list
   %% of atoms.

   fun {RemovePunctuation Sentence}
      {List.reverse
       {List.foldL {String.tokens Sentence 32}
	fun {$ Acc T}
	   case {String.tokens T &_}
	   of nil then Acc
	   [] [ _ "."] then Acc
	   [] [ _ ":"] then Acc
	   [] [ _ ","] then Acc
	   [] ["``" _] then Acc
	   [] ["''" _] then Acc
	   [] [_ "COMMA"] then Acc
	   [] [_ "-LRB-"] then Acc
	   [] [_ "-NONE-"] then Acc
	   [] [_ "-RRB-"] then Acc
	   else
	      {VirtualString.toAtom T}|Acc
	   end
	end nil}}
   end

   fun {StripPOSTags Words}
      {List.map Words
       fun {$ W}
	  {VirtualString.toAtom
	   {String.tokens {VirtualString.toString W} &_}.1}
       end}
   end
   
end
