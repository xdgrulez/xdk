%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Parser at 'x-oz://system/xml/Parser.ozf'
export
   ParseUrl
   ParseV
define
   class MyParser from Parser.parser
      meth init
	 M = {New Parser.spaceManager init}
      in
	 {M stripSpace('*' '*')}
	 Parser.parser,init
	 {self setSpaceManager(M)}
      end
      meth onStartElement(Tag Alist Children)
	 {self append(
		  element(
		     name       : Tag.name
		     attributes : Alist
		     children   : Children
		     %%
		     coord      : Tag.coord))}
      end
      meth onAttribute(Tag Value)
	 {self attributeAppend(
		  attribute(
		     name  : Tag.name
		     value : Value
		     %%
		     coord : Tag.coord))}
      end
   end
   %% ParseUrl: V -> Elements
   %% Use Denys' XML parser to parse the file at URL V,
   %% and return its corresponding XML representation Elements.
   fun {ParseUrl V}
      MyParserObj = {New MyParser init}
      Elements = {MyParserObj parseURL(V $)}
   in
      Elements
   end
   %% ParseV: V -> Elements
   %% Use Denys' XML parser to parse the virtual string V, and return
   %% its corresponding XML representation Elements.
   fun {ParseV V}
      MyParserObj = {New MyParser init}
      Elements = {MyParserObj parseVS(V $)}
   in
      Elements
   end
end
