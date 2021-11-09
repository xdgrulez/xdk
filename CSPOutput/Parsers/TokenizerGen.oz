%% Copyright 2002-2011
%% by Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans)
%%
functor
import
   System(show)

   Open(file:File)
   URL(resolve:URLResolve
       toAtom:URLToAtom)
export
   NewTokenizer NewTokenizerConstructor
prepare
   IsPrefix = List.isPrefix
   IsAlNum = Char.isAlNum
   IsDigit = Char.isDigit
   IsSpace = Char.isSpace
   IsAlpha = Char.isAlpha
   BSMake = ByteString.make
   %%
   ListToRecord = List.toRecord
   ListTakeDropWhile = List.takeDropWhile
define
   %%
   fun {IsIDChar C}
      {IsAlNum C} orelse C==&_
   end
   %%
   fun {TryEolComments Ps L}
      case Ps
      of nil then no
      [] H|T then
	 if {IsPrefix H L} then some(L) else
	    {TryEolComments T L}
	 end
      end
   end
   fun {SkipToEOL L N}
      case L
      of nil then N#nil
      [] &\n|L then N+1#L
      [] _|L then {SkipToEOL L N} end
   end
   %%
   fun {TryBalancedComments Cs L}
      case Cs
      of nil then no
      [] (B#E)|Cs then
	 if {IsPrefix B L} then some(E L) else
	    {TryBalancedComments Cs L}
	 end
      end
   end
   %%
   %% SkipToEOC
   %%
   %% Skip to (e)nd (o)f balanced (c)omment
   %%
   %% Inputs:
   %%  E - token expected to finish the comment (e.g. "*)")
   %%  L - current input
   %%  N - current line
   %%  N1 - line on which the comment started
   %%  F - file in which the comment started
   %%
   %% Outputs:
   %%  N#L where N is the current line and L the current input
   %%
   fun {SkipToEOC E L N N1 F}
      if {IsPrefix E L} then N#{Append E $ L}
      elsecase L of H|L then {SkipToEOC E L if H==&\n then N+1 else N end N1 F}
      else raise tokenizer(nonTerminatedComment N1 F E) end
      end
   end
   %%
   fun {TryIncludes Is L}
      case Is
      of nil then no
      [] H|T then
	 if {IsPrefix H L} then some({Append H $ L}) else
	    {TryIncludes T L}
	 end
      end
   end
   fun {SkipToEOLGetString L N F}
      case L
      of nil then N#nil#nil
      [] &\n|T then N+1#T#nil
      [] &'|T then
	 OUT NOUT
      in
	 NOUT#OUT#{SQString T N N F OUT NOUT}
      [] &"|T then
	 OUT NOUT
      in
	 NOUT#OUT#{DQString T N N F OUT NOUT}
      [] &«|T then
	 OUT NOUT
      in
	 NOUT#OUT#{GQString T N N F OUT NOUT}
      [] H|T andthen {IsSpace H} then {SkipToEOLGetString T N F}
      [] _|T then {SkipToEOLGetString T N F}
      end
   end
   %%
   fun {TryOperators Os L}
      case Os
      of nil then no
      [] (S#A)|Os then
	 if {IsPrefix S L} then some(A {Append S $ L}) else
	    {TryOperators Os L}
	 end
      end
   end
   %%
   %% SQString
   %%
   %% Tokenize a (s)ingle (q)uoted string
   %%
   %% Inputs:
   %%  L - current input
   %%  N - current line
   %%  N1 - line on which the sqstring started
   %%  F - file in which the sqstring started
   %%
   %% Outputs:
   %%  OUT - current input (after sqstring ended)
   %%  NOUT - current line (after sqstring ended)
   %%
   fun {SQString L N N1 F OUT NOUT}
      case L
      of nil then raise tokenizer(unbalancedSingleQuotes N1 F) end
      [] &'|L then OUT=L NOUT=N nil
      [] H|T then H|{SQString T if H==&\n then N+1 else N end N1 F OUT NOUT} end
   end
   %%
   %% DQString
   %%
   %% Tokenize a (d)ouble (q)uoted string
   %%
   %% Inputs:
   %%  L - current input
   %%  N - current line
   %%  N1 - line on which the dqstring started
   %%  F - file in which the dqstring started
   %%
   %% Outputs:
   %%  OUT - current input (after dqstring ended)
   %%  NOUT - current line (after dqstring ended)
   %%
   fun {DQString L N N1 F OUT NOUT}
      case L
      of nil then raise tokenizer(unbalancedDoubleQuotes N1 F) end
      [] &"|L then OUT=L NOUT=N nil
      [] H|T then H|{DQString T if H==&\n then N+1 else N end N1 F OUT NOUT} end
   end
   %%
   %% GQString
   %%
   %% Tokenize a (g)uillemet (q)uoted string
   %%
   %% Inputs:
   %%  L - current input
   %%  N - current line
   %%  N1 - line on which the gqstring started
   %%  F - file in which the gqstring started
   %%
   %% Outputs:
   %%  OUT - current input (after gqstring ended)
   %%  NOUT - current line (after gqstring ended)
   %%
   fun {GQString L N N1 F OUT NOUT}
      case L
      of nil then raise tokenizer(unbalancedDoubleQuotes N1 F) end
      [] &»|L then OUT=L NOUT=N nil
      [] H|T then H|{GQString T if H==&\n then N+1 else N end N1 F OUT NOUT} end
   end
   %%
   fun {TokNum1 N L F}
      case L
      of nil then some(int({StringToInt {Reverse N}}) nil)
      [] H|T then
	 if {IsDigit H} then {TokNum1 H|N T F}
%% disable support for floats
%	 elseif H==&. then {TokNum2 H|N T F}
	 else some(int({StringToInt {Reverse N}}) L) end
      end
   end
   fun {TokNum2 N L F}
      case L
      of nil then some(float({StringToFloat {Reverse N}}) nil)
      [] H|T then
	 if {IsDigit H} then {TokNum2 H|N T F}
	 elseif H==&e orelse H==&E then {TokNum3 &e|N T F}
	 else some(float({StringToFloat N}) L) end
      end
   end
   fun {TokNum3 N L F}
      case L
      of nil then raise tokenizer(floatEOF N F) end
      [] &+|T then {TokNum4 N T F}
      [] &-|T then {TokNum4 &~|N T F}
      else {TokNum4 N L F} end
   end
   fun {TokNum4 N L F}
      case L
      of nil then raise tokenizer(floatEOF N F) end
      [] H|T andthen {IsDigit H} then {TokNum5 H|N T F}
      else raise tokenizer(floatTooShort N F text:L) end
      end
   end
   fun {TokNum5 N L F}
      case L
      of nil then some(float({StringToFloat {Reverse N}}) nil)
      [] H|T andthen {IsDigit H} then {TokNum5 H|N T F}
      else some(float({StringToFloat {Reverse N}}) L) end
   end
   %%
   fun {LazyRead O}
      fun lazy {More}
	 L T N
      in
	 {O read(list:L tail:T size:1024 len:N)}
	 T = if N==0 then {O close} nil else {More} end
	 L
      end
   in
      {More}
   end
   %%
   fun {NewTokenizer DESC}
      {{NewTokenizerConstructor DESC} File}
   end
   fun {NewTokenizerConstructor DESC}
      OperatorPrefixes =
      {Map {Sort {Map {Map {CondSelect DESC 'operators' nil}
		       VirtualString.toString}
		  fun {$ O} {Length O}#O end}
	    fun {$ N1#_ N2#_} N1>N2 end}
       fun {$ _#S} S#{VirtualString.toAtom S} end}
      %%
      KeywordTable =
      {ListToRecord o
       {Map {CondSelect DESC 'keywords' nil}
	fun {$ K} {VirtualString.toAtom K}#true end}}
      %%
      BalancedComments =
      {Map {CondSelect DESC balancedComments nil}
       fun {$ Beg#End}
	  {VirtualString.toString Beg}#
	  {VirtualString.toString End}
       end}
      %%
      EolComments =
      {Map {CondSelect DESC eolComments nil}
       VirtualString.toString}
      %%
      Includes =
      {Map {CondSelect DESC includes nil}
       VirtualString.toString}
      %%
   in
      fun {$ File}
	 fun {Tokenize L N F}
	    case L
	    of nil then nil
	    [] &'|T then OUT NOUT in
	       token(sym   : '<sstring>'
		     sem   : {BSMake {SQString T N N F OUT NOUT}}
		     coord : N
		     file  : F)
	       |{Tokenize OUT NOUT F}
	    [] &"|T then OUT NOUT in
	       token(sym   : '<dstring>'
		     sem   : {BSMake {DQString T N N F OUT NOUT}}
		     coord : N
		     file  : F)
	       |{Tokenize OUT NOUT F}
	    [] &«|T then OUT NOUT in
	       token(sym   : '<gstring>'
		     sem   : {BSMake {GQString T N N F OUT NOUT}}
		     coord : N
		     file  : F)
	       |{Tokenize OUT NOUT F}
	    [] H|T andthen {IsSpace H} then
	       {Tokenize T if H==&\n then N+1 else N end F}
	    [] H|_ andthen {IsAlpha H} then L1 L2 ID in
	       {ListTakeDropWhile L IsIDChar L1 L2}
	       {StringToAtom L1 ID}
	       token(sym   : if {HasFeature KeywordTable ID}
			     then ID else '<id>' end
		     sem   : ID
		     coord : N
		     file  : F)
	       |{Tokenize L2 N F}
	    [] H|_ andthen {IsDigit H} then
	       case {TokNum1 nil L F}
	       of some(T L) then
		  case T
		  of int(V)   then token(sym   : '<int>'
					 sem   : V
					 coord : N
					 file  : F)
		  [] float(V) then token(sym   : '<float>'
					 sem   : V
					 coord : N
					 file  : F)
		  end
		  |{Tokenize L N F}
	       end
	    elsecase {TryEolComments EolComments L}
	    of some(L) then
	       case {SkipToEOL L N} of N#L then {Tokenize L N F} end
	    elsecase {TryBalancedComments BalancedComments L}
	    of some(E L) then
	       case {SkipToEOC E L N N F} of N#L then {Tokenize L N F} end
	    elsecase {TryIncludes Includes L}
	    of some(L) then
	       case {SkipToEOLGetString L N F}
	       of N2#L#I then
		  if I==nil then raise tokenizer(includeError N F) end else
		     UA = {URLToAtom {URLResolve F I}}
		  in
		     {Append {TokenizeFromURL UA} {Tokenize L N2 F}}
		  end
	       end
	    elsecase {TryOperators OperatorPrefixes L}
	    of some(O L) then
	       token(sym   : O
		     sem   : O
		     coord : N
		     file  : F)
	       |{Tokenize L N F}
	    else
	       Ch = L.1
	       A = {Char.toAtom Ch}
	    in
	       raise tokenizer(cannotTokenize N F A) end
	    end
	 end
	 fun {TokenizeFromURL U}
	    UA = {URLToAtom U}
	 in
	    {Tokenize {LazyRead {New File init(url:U)}} 1 UA}
	 end
	 fun {TokenizeFromString S}
	    {Tokenize S 1 'FromString'}
	 end
      in
	 tokenizer(
	    fromString : TokenizeFromString
	    fromURL    : TokenizeFromURL)
      end
   end
end
