%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   Inspector(inspect)
%   System(show)
export
   Check
prepare
   RecordForAllInd = Record.forAllInd
   RecordToList = Record.toList
define
   A2S = Atom.toString
   %%
   %% IsDescRef: Desc -> B
   %% Returns true if Desc is a description reference, and false if not.
   fun {IsDescRef Desc}
      B =
      {IsAtom Desc} andthen {Char.isUpper {A2S Desc}.1} andthen
      {Not {Member Desc ['ID' 'IDREF' 'CDATA' 'ATOM' 'INT']}}
   in
      B
   end
   %% IsComplexDesc: Desc -> B
   %% Returns true if Desc is a complex description, and false if not.
   fun {IsComplexDesc Desc}
      B = {Label Desc}==elem andthen {HasFeature Desc tag}
   in
      B
   end
   %%
   proc {Check Term DescRec StartDesc}
      %%
      %% Check: Term Desc -> Unit
      %%
      %% Checks whether term Term matches description Desc.
      proc {Check1 Term Desc}
	 Coord = if {IsInt Term} then noCoord
		 else {CondSelect Term coord noCoord}
		 end
	 File = if {IsInt Term} then noCoord
		else {CondSelect Term file noFile}
		end
      in
	 %% (handle description constructors)
	 %% description constructors can be either of:
	 %%  1) Desc_1#...#Desc_n (tuple)
	 %%  2) '*'(Desc) (list)
	 %%  3) '?'(Desc) (optional)

	 %% desconstruct description constructors
	 case Desc
	 of '?'(Desc1) then
	    {Check1 Term Desc1}
	 [] '*'(Desc1) then
	    if {Not {IsList Term}} then
	       raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'List expected.' info:o(Term) coord:Coord file:File) end
	    end
	    for Term1 in Term do
	       {Check1 Term1 Desc1}
	    end
	 elseif {IsTuple Desc} andthen {Label Desc}=='#' then
	    if {Not {IsTuple Term}} then
	       raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Tuple expected.' info:o(Term) coord:Coord file:File) end
	    end
	    if {Not {Label Term}=='#'} then
	       raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Tuple label # expected.' info:o(Term) coord:Coord file:File) end
	    end
	    TermI = {Width Term}
	    DescI = {Width Desc}
	 in
	    if {Not TermI==DescI} then
	       raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Width of term and description tuples do not match: '#TermI#' not equal '#DescI info:o(DescI Term Desc) coord:Coord file:File) end
	    end
	    {RecordForAllInd Desc
	     proc {$ I Desc1}
		{Check1 Term.I Desc1}
	     end}
	 else
	    %% (handle descriptions)
	    %% a description is either:
	    %%  1) a reference to a description
	    %%  2) a disjunction of descriptions
	    %%  3) a complex description (an element)
	    %%  4) a simple description
	    %%    a) ID (an atom referring to a unique identifier)
	    %%    b) IDREF (an atom referencing to an ID)
	    %%    c) CDATA (character data)
	    %%    d) ATOM (an atom)
	    %%    e) INT (an integer)
	    %%    f) a list of alternatives (atoms)
	    
	    %% 1) handle references to descriptions
	    Desc1 =
	    if {IsDescRef Desc} then
	       if {Not {HasFeature DescRec Desc}} then
		  raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Referring to undefined description.' info:o(Desc) coord:Coord file:File) end
	       end
	       DescRec.Desc
	    else
	       Desc
	    end
	 in
	    %% 2) handle disjunctions of descriptions
	    case Desc1
	    of disj(...) then
	       Descs = {RecordToList Desc1}
	       B =
	       for Desc2 in Descs return:Return default:false do
		  Good =
		  try
		     {Check1 Term Desc2}
		     true
		  catch _ then
		     false
		  end
	       in
		  if Good then {Return true} end
	       end
	    in
	       if {Not B} then
		  raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Term does not match any of a disjunction of descriptions.' info:o(Term Descs) coord:Coord file:File) end
	       end
	    else
	       %% 3) handle complex descriptions
	       if {IsComplexDesc Desc1} then
		  if {Not {HasFeature Term tag}} then
		     raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Tag expected for complex description.' info:o(Term) coord:Coord file:File) end
		  end
		  if {Not Term.tag==Desc1.tag} then
		     raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Tags of term and description do not match: '#Term.tag#' not equal '#Desc1.tag info:o(Term Desc1) coord:Coord file:File) end
		  end
		  for LI in {Arity Term} do
		     case LI
		     of coord then skip
		     [] file then skip
		     else
			if {Not {HasFeature Desc1 LI}} then
			   raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Term includes a field which is not in the arity of the description: '#LI info:o(Desc1 Term) coord:Coord file:File) end
			end
		     end
		  end
		  {RecordForAllInd Desc1
		   proc {$ LI Desc2}
		      if {Not {HasFeature Term LI}} then
			 case Desc2
			 of '?'(_) then %% optional feature
			    skip
			 [] '*'(_) then %% list feature (should be assumed to be nil)
			    skip
			 else
			    raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Term lacks a field which is obligatory in the description: '#LI info:o(Desc2 Term) coord:Coord file:File) end
			 end
		      else
			 Term1 = Term.LI
		      in
			 case LI
			 of tag then
			    skip
			 else
			    {Check1 Term1 Desc2}
			 end
		      end
		   end}
	       else
		  %% 4) handle simple descriptions
		  case Desc1
		  of 'ID' then
		     if {Not {IsAtom Term}} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'ID must be an atom.' info:o(Term) coord:Coord file:File) end
		     end
		  in
		     if {HasFeature IDACoordFileTupDict Term} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'ID is already defined.' info:o(Term) coord:Coord file:File) end
		     end
		     IDACoordFileTupDict.Term := Coord#File
		  [] 'IDREF' then
		     if {Not {IsAtom Term}} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'IDREF must be an atom.' info:o(Term) coord:Coord file:File) end
		     end
		  in
		     IDACoordFileTupDict1.Term := Coord#File
		  [] 'CDATA' then
		     if {Not {IsString Term}} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Character data (string) expected.' info:o(Term) coord:Coord file:File) end
		     end
		  [] 'ATOM' then
		     if {Not {IsAtom Term}} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Atom expected.' info:o(Term) coord:Coord file:File) end
		     end
		  [] 'INT' then
		     if {Not {IsInt Term}} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Int expected.' info:o(Term) coord:Coord file:File) end
		     end
		  elseif {IsAtom Desc1} then
		     if {Not Term==Desc1} then
			raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Term does not match atomic description.' info:o(Term Desc1) coord:Coord file:File) end
		     end
		  else
		     raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check1' msg:'Illformed description.' info:o(Desc1) coord:Coord file:File) end
		  end
	       end
	    end    
	 end
      end
      IDACoordFileTupDict = {NewDictionary} %% ID 
      IDACoordFileTupDict1 = {NewDictionary} %% IDREF
      Desc = DescRec.StartDesc
   in
      {Check1 Term Desc}
      %%
      for IDA in {Dictionary.keys IDACoordFileTupDict1} do
	 if {Not {HasFeature IDACoordFileTupDict IDA}} then
	    Coord = IDACoordFileTupDict1.IDA.1
	    File = IDACoordFileTupDict1.IDA.2
	 in
	    raise error1('functor':'Compiler/SyntaxChecker.ozf' 'proc':'Check' msg:'Referring to undefined ID: '#IDA info:o coord:Coord file:File) end
	 end
      end
   end
end
