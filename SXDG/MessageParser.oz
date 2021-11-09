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

%% This functor provides a parser for the messages that the remote
%% oracle sends.  It uses Denys Duchier's XML parser, which (since
%% Mozart 1.3.0) is contained in the system library.

functor
import
   Parser at 'x-oz://system/xml/Parser.ozf'
%   Parser at 'x-ozlib://duchier/xml/Parser.ozf'
export
   MessageParser
define
   class MessageParser from Parser.parser
      meth init
	 SpaceManager = {New Parser.spaceManager init}
      in
	 Parser.parser,init
	 {SpaceManager stripSpace('*' '*')}
	 {self setSpaceManager(SpaceManager)}
      end
      meth onAttribute(Tag Value)
	 N = attribute(name:Tag.name value:Value)
      in
	 {self attributeAppend(N)}
      end
      meth onStartElement(Tag AList Children)
	 N = element(name:Tag.name attributes:AList children:Children)
      in
	 {self append(N)}
      end
   end
end
