%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   System(show)
%   Inspector(inspect)

   Module(link)
   Pickle(load saveCompressed)
   
   Helpers(getSuffix putV) at 'Helpers.ozf'

   IL2UL(convert) at 'UL/IL2UL.ozf'
   ULParser(parseUrl) at 'UL/Parser.ozf'
   UL2IL(convert) at 'UL/UL2IL.ozf'

   IL2XML(convert) at 'XML/IL2XML.ozf'
   XMLParser(parseUrl) at 'XML/Parser.ozf'
   XML2IL(convert) at 'XML/XML2IL.ozf'
export
   Convert
define
   V2A = VirtualString.toAtom
   %% Convert: FromV ToV PrintProc -> U
   %% Converts grammar file at URL FromV to grammar file at URL ToV.
   %% Chooss the the grammar file language of the destination grammar
   %% file depending on the suffix of ToV.
   proc {Convert FromV ToV PrintProc}
      %% get suffix
      FromSuffixS = {Helpers.getSuffix FromV}
      %% convert to IL
      IL =
      case FromSuffixS
      of "ul" then {ULFile2IL FromV}
      [] "xml" then {XMLFile2IL FromV}
      [] "ilp" then {ILPickle2IL FromV}
      [] "ozf" then {ILFunctor2IL FromV}
      [] "slp" then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Cannot convert compiled grammars.' info(FromV ToV) coord:noCoord file:noFile) end 
      [] "slp_db" then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Cannot convert compiled grammars.' info(FromV ToV) coord:noCoord file:noFile) end 
      else
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Source file: unsupported conversion suffix: '#FromSuffixS info:o(FromV ToV) coord:noCoord file:noFile) end
      end
      %% get suffix
      ToSuffixS = {Helpers.getSuffix ToV}
   in
      %% convert from IL
      case ToSuffixS
      of "ul" then {SaveULFile IL ToV}
      [] "xml" then {SaveXMLFile IL ToV}
      [] "ilp" then {SaveILPickle IL ToV}
      [] "ozf" then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Cannot convert to Oz functor.' info(FromV ToV) coord:noCoord file:noFile) end
      [] "slp" then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Cannot convert to compiled grammar.' info(FromV ToV) coord:noCoord file:noFile) end
      [] "slp_db" then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Cannot convert to compiled grammar.' info(FromV ToV) coord:noCoord file:noFile) end
      else
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'Convert' msg:'Destination file: unsupported conversion suffix: '#ToSuffixS info:o(FromV ToV) coord:noCoord file:noFile) end
      end
      %%
      {PrintProc {V2A 'Successfully converted '#FromV#' to '#ToV#' ('#FromSuffixS#' to '#ToSuffixS#').'}}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% ULFile2IL: V -> IL
   %% Converts UL grammar file at URL V to IL grammar IL.
   fun {ULFile2IL V}
      UL = {ULParser.parseUrl V}
      IL = {UL2IL.convert UL}
   in
      IL
   end
   %% XMLFile2IL: V -> IL
   %% Converts XML grammar file at URL V to IL grammar IL.
   fun {XMLFile2IL V}
      Elements = {XMLParser.parseUrl V}
      IL = {XML2IL.convert Elements}
   in
      IL
   end
   %% ILPickle2IL: V -> IL
   %% Converts IL pickle at URL V to IL grammar IL.
   fun {ILPickle2IL V}
      IL = {Pickle.load V}
   in
      IL
   end
   %% ILFunctor2IL: V -> IL
   %% Converts IL functor at URL V to IL grammar IL.
   fun {ILFunctor2IL V}
      [Functor] = {Module.link [V]}
      if {Not {HasFeature Functor grammar}} then
	 raise error1('functor':'Compiler/Converter.ozf' 'proc':'ILFunctor2IL' msg:'Oz functor is no IL functor: it does not export the grammar under the key grammar' info:o(V) coord:noCoord file:noFile) end
      end
      IL = Functor.grammar
   in
      IL
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% SaveULFile: IL V -> U
   %% Saves IL grammar IL into a UL grammar file at URL V
   proc {SaveULFile IL V}
      UL = {IL2UL.convert IL}
   in
      {Helpers.putV UL V}
   end
   %% SaveXMLFile: IL V -> U
   %% Saves IL grammar IL into a XML grammar file at URL V
   proc {SaveXMLFile IL V}
      XML = {IL2XML.convert IL}
   in
      {Helpers.putV XML V}
   end
   %% SaveILPickle: IL V -> U
   %% Saves IL grammar IL into an IL pickle at URL V.
   proc {SaveILPickle IL V}
      {Pickle.saveCompressed IL V 9}
   end
end
