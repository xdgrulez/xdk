%% Copyright 2002-2011
%% by Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans)
%%
%% mostly lifted from the Dragon book
functor
export
   Make Epsilon Accept Begin GetConflicts MakeParser Preprocess
   MakeLALR MakeLR GetDetailedConflicts
prepare
   %% a grammar is given by a record:
   %% grammar(tokens:[Atom|Atom#PREC]
   %%         rules :[rule(head:Atom body:[Atom])]
   %%         start :Atom)
   %% PREC ::= left(N)|right(N)|nonassoc(N) is a precedence declaration
   %% where N is an integer representing the precedence strength
   %% a rule may also have an optional action:
   %% action:Fun which takes as argument a list of the semantic values
   %% of the elements of the rule's body.
   %% a rule may also have an optional prec:PREC

   Epsilon = {NewName}
   Accept  = {NewName}
   Begin   = {NewName}
   EOF     = {NewName}

   ToTuple      = List.toTuple
   MapInd       = List.mapInd
   ToRecord     = List.toRecord
   DictToRecord = Dictionary.toRecord
   ForAllTail   = List.forAllTail
   ValueLT      = Value.'<'
   VS2A         = VirtualString.toAtom
   DictItems    = Dictionary.items
   DictKeys     = Dictionary.keys
   RecToList    = Record.toList
   RecToListInd = Record.toListInd
   RecMap       = Record.map
   ListToTuple  = List.toTuple

   fun {RET L}
      value(sem:L coord:{CoordExtent L unit} file:{FileExtent L unit})
   end
   %fun {NIL _} value(sem:nil coord:unit) end
   fun {CONS [H T]}
      value(sem:(H|T.sem) coord:{CoordMerge H.coord T.coord} file:H.file)
   end
   %fun {LAB N} fun {$ L} {ListToTuple N L} end end

   fun {ToIndEntry Ind Key} Key#Ind end

   fun {TwoExp N}
      if N==0 then 1 else 2*{TwoExp N-1} end
   end

   fun {DictToTable D} {DictToRecord table D} end

   fun {NoDups L}
      case L
      of nil then nil
      [] H|T then
	 if {Member H T} then {NoDups T} else H|{NoDups T} end
      end
   end

   proc {Incr C} N1 N2 in {Exchange C N1 N2} N2=N1+1 end

   fun {Make Grammar}

      %% construct a table that let's us quickly distinguish
      %% between terminals and non-terminals

      PREC_TABLE  = {NewDictionary}
      TOKENS      = Accept
      |for T in Grammar.tokens collect:Collect do
	  case T
	  of T#P then PREC_TABLE.T := P {Collect T}
	  else {Collect T} end
       end
      TOKEN_TABLE = {ToRecord token {MapInd TOKENS ToIndEntry}}
      TOKEN_COUNT = {Width TOKEN_TABLE}

      fun {IsToken T} {HasFeature TOKEN_TABLE T} end

      %% support for creating the internal representation of rules

      fun {GetBodyPrec Body Prec}
	 case Body
	 of nil then Prec
	 [] H|T then {GetBodyPrec T {CondSelect PREC_TABLE H Prec}}
	 end
      end
      fun {ToRule I R} Head=R.head in
	 rule(num    : I
	      head   : Head
	      body   : R.body
	      len    : {Length R.body}
	      %% the default action is represented by the label
	      %% it needs to tack on
	      action : if {HasFeature R action} then R.action else Head end
	      prec   :
		 if {HasFeature R prec} then R.prec
		 else {GetBodyPrec R.body unit} end
	     )
      end

      %% now a table of rules:
      %% note that we augment the grammar with an additional
      %% initial production

      RULE_INIT  = rule(head:Begin body:[Grammar.start] action:1)
      RULES      = {MapInd RULE_INIT|Grammar.rules ToRule}
      RULE_TABLE = {ToTuple rules RULES}
      RULE_COUNT = {Width RULE_TABLE}

      %% {PUT Table Key Value}
      %%     Table maps keys to lists of values. Value is put at
      %% the front of the list associated with Key iff it is not
      %% already present in this list.  When this happens, the
      %% global switch Again is set to true: this will be used
      %% for various iterations.

      Again = {NewCell true}
      fun {AGAIN} {Exchange Again $ false} end
      proc {PUT Table Key Value}
	 L={CondSelect Table Key nil}
      in
	 if {Member Value L} then skip else
	    Table.Key := Value|L
	    {Assign Again true}
	 end
      end

      %% Now let's compute the FIRST table

      SYMBOLS
      FIRST_TABLE
      local TAB={NewDictionary} in
	 for T in TOKENS do
	    if {HasFeature TAB T} then
	       raise lalr(duplicatetoken(T)) end
	    else
	       TAB.T := [T]
	    end
	 end
	 %% check that no head of a rule is a token
	 for R in RULES do H=R.head in
	    if {HasFeature TAB H} then
	       raise lalr(bothtandnt(H)) end
	    end
	 end
	 %% creates entries for them as well
	 for R in RULES do TAB.(R.head) := nil end
	 %% now check that no non-terminal has been forgotten
	 for R in RULES do
	    for B in R.body do
	       if {Not {HasFeature TAB B}} then
		  raise lalr(norulefor(B)) end
	       end
	    end
	 end
	 %% take note of all grammar symbols
	 !SYMBOLS = {DictKeys TAB}
	 %% seed the algorithm
	 for R in RULES do
	    case R.body
	    of nil then {PUT TAB R.head Epsilon}
	    [] H|_ then
	       if {IsToken H} then {PUT TAB R.head H} end
	    end
	 end
	 %% iterate
	 for break:Break1 do
	    if {AGAIN} then
	       for R in RULES do H=R.head N=R.len in
		  for Y in R.body I in 1;I+1 break:Break2 do
		     HaveEps
		  in
		     for Z in TAB.Y do
			if Z==Epsilon then HaveEps=unit
			else {PUT TAB H Z} end
		     end
		     if {IsDet HaveEps} then
			if I==N then {PUT TAB N Epsilon} end
		     else {Break2} end
		  end
	       end
	    else {Break1} end
	 end
	 !FIRST_TABLE = {DictToRecord table TAB}
      end

      %% {First +IN ?OUT}
      %%     IN is a grammar symbol or a list of grammar symbols
      %% OUT is the set of "first" tokens for this sequence.

      fun {First IN}
	 case IN
	 of [H] then FIRST_TABLE.H
	 [] _|_ then N={Length IN} D={NewDictionary} in
	    for Y in IN I in 1;I+1 break:Break do HaveEps in
	       for Z in FIRST_TABLE.Y do
		  if Z==Epsilon then HaveEps=unit else D.Z := unit end
	       end
	       if {IsDet HaveEps} then
		  if I==N then D.Epsilon := unit end
	       else {Break} end
	    end
	    {DictKeys D}
	 else FIRST_TABLE.IN end
      end

      %% compute the FOLLOW table

      FOLLOW_TABLE
      local TAB={NewDictionary} in
	 %% seed the algorithm
	 {PUT TAB Grammar.start Accept}
	 %% iterate
	 for break:Break do
	    if {AGAIN} then
	       for R in RULES do
		  {ForAllTail R.body
		   proc {$ H|T}
		      if {IsToken H} then skip else
			 if T\=nil then Zs={First T} HaveEps in
			    for Z in Zs do
			       if Z==Epsilon then HaveEps=unit
			       else {PUT TAB H Z} end
			    end
			    if {IsDet HaveEps} then
			       for X in {CondSelect TAB (R.head) nil} do
				  {PUT TAB H X}
			       end
			    end
			 else
			    for X in {CondSelect TAB (R.head) nil} do
			       {PUT TAB H X}
			    end
			 end
		      end
		   end}
	       end
	    else {Break} end
	 end
	 !FOLLOW_TABLE = {DictToRecord table TAB}
      end

      %% {Follow +IN ?OUT}
      %%     IN is a grammar symbol and OUT is the list
      %% of tokens that may "follow" this one

      fun {Follow H} FOLLOW_TABLE.H end

      %% an LR(1) item has the form:
      %% item(rule:RULE dot:DOT tail:TAIL look:TOKEN)
      %% a set of items will be interned in a table so
      %% that it can be represented uniquely.
      %% each item can be represented uniquely by an integer:
      %% the lower bits are for the lookeahead token, the
      %% next higher bits for the rule, and the highest bits
      %% for the dot position.

      BITS_TOKENS = {FloatToInt {Ceil {Log {IntToFloat TOKEN_COUNT+1}}/{Log 2.0}}}
      BITS_RULES  = {FloatToInt {Ceil {Log {IntToFloat  RULE_COUNT+1}}/{Log 2.0}}}
      FACT_TOKENS = {TwoExp BITS_TOKENS}
      FACT_RULES  = {TwoExp BITS_RULES}
      
      fun {ItemToKey I}
	 TOKEN_TABLE.(I.look) + I.rule.num*FACT_TOKENS + I.dot*FACT_TOKENS*FACT_RULES
      end
      fun {ItemToCoreKey I}
	 I.rule.num + I.dot*FACT_RULES
      end
      fun {KeysToKeyVS L}
	 case L
	 of nil  then nil
	 [] [K]  then K
	 [] K|Ks then K#'/'#{KeysToKeyVS Ks} end
      end
      fun {KeysToKey L} {VS2A {KeysToKeyVS L}} end

      SET_TABLE = {NewDictionary}
      fun {Intern Items}
	 Key = {KeysToKey {Sort {Map Items ItemToKey} ValueLT}}
	 CoreKey = {KeysToKey {Sort {NoDups {Map Items ItemToCoreKey}} ValueLT}}
	 Set = {CondSelect SET_TABLE Key unit}
      in
	 if Set==unit then
	    Set = set(
		     key     : Key
		     corekey : CoreKey
		     items   : Items
		     goto    : {NewDictionary})
	 in
	    SET_TABLE.Key     := Set
	    SET_TABLE.CoreKey := Set
	    Set
	 else Set end
      end

      %% {Closure +Items ?Set}
      %%     given a list of items returns the set of items
      %% that represents its closure.

      fun {Closure Items}
	 D={NewDictionary}
	 S={NewCell Items}
      in
	 for break:Break do L in
	    case {Exchange S $ L}
	    of nil then L=nil {Break}
	    [] I|Is then Key={ItemToKey I} in
	       L=Is
	       if {HasFeature D Key} then skip else
		  D.Key := I
		  case I.tail
		  of B|Beta andthen {Not {IsToken B}} then
		     Fs = {First {Append Beta [I.look]}}
		  in
		     for R in RULES do
			if R.head==B then
			   for F in Fs do L in
			      {Exchange S L item(rule:R dot:0 tail:R.body look:F)|L}
			   end
			end
		     end
		  else skip end
	       end
	    end
	 end
	 {Intern {DictItems D}}
      end

      %% {Goto +Set +Sym ?Set2}
      %%     given a set of items and a grammar symbol, returns the
      %% set of items that results from moving the dot forward
      %% over the given symbol.  We also cache all computed gotos.

      fun {Goto Set Sym}
	 Set2={CondSelect Set.goto Sym unit}
      in
	 if Set2==unit then
	    Set2={Closure
		  for I in Set.items collect:Collect do
		     case I.tail
		     of H|T andthen H==Sym then
			{Collect
			 item(rule:I.rule dot:I.dot+1 tail:T look:I.look)}
		     else skip end
		  end}
	 in
	    Set.goto.Sym := Set2
	    Set2
	 else Set2 end
      end

      %% now we are ready to compute the LR(1) sets of items
      LR1_TABLE
      INIT_STATE_KEY
      INIT_STATE_COREKEY
      local
	 TAB      = {NewDictionary}
	 InitRule = RULE_TABLE.1
	 InitSet  = {Closure [item(rule:InitRule dot:0 tail:InitRule.body look:Accept)]}
	 S={NewCell [InitSet]}
      in
	 !INIT_STATE_KEY     = InitSet.key
	 !INIT_STATE_COREKEY = InitSet.corekey
	 TAB.(InitSet.key) := InitSet
	 for break:Break do L in
	    case {Exchange S $ L}
	    of nil then L=nil {Break}
	    [] Set|Sets then L=Sets
	       for X in SYMBOLS do Set2={Goto Set X} in
		  if Set2.items\=nil andthen {Not {HasFeature TAB Set2.key}}
		  then L in
		     TAB.(Set2.key) := Set2
		     {Exchange S L Set2|L}
		  end
	       end
	    end
	 end
	 !LR1_TABLE = {DictToRecord table TAB}
      end

      %% Action is known not to occur in Actions
      %% use precedence information to possibly simplify
      
      fun {EnterAction Action Actions}
	 if Action.prec==unit then Action|Actions else
	    {EnterActionLoop Action Actions}
	 end
      end

      fun {EnterActionLoop Action Actions}
	 case Actions
	 of nil then [Action]
	 [] H|T then Hprec=H.prec in
	    if Hprec==unit then H|{EnterActionLoop Action T}
	    else
	       Hprio=Hprec.1
	       Aprec=Action.prec
	       Aprio=Aprec.1
	    in
	       if {Label Action}=={Label H} then
		  %% reduce/reduce or shift/shift
		  H|{EnterActionLoop Action T}
	       elseif Aprio > Hprio then {EnterActionLoop Action T}
	       elseif Aprio < Hprio then Actions
	       elsecase {Label Aprec}#{Label Hprec}
	       of left #left  then %% prefer to reduce
		  if {Label Action}==reduce
		  then {EnterActionLoop Action T}
		  else Actions end
	       [] right#right then %% prefer to shift
		  if {Label Action}==shift
		  then {EnterActionLoop Action T}
		  else Actions end
	       else H|{EnterActionLoop Action T}
	       end
	    end
	 end
      end

      %% create a LR/LALR parsing table
      %%     KEY=key     for LR(1)
      %%     KEY=corekey for LALR

      fun {MakeParsingTables KEY}
	 ACTION={NewDictionary}
	 GOTO  ={NewDictionary}
      in
	 for Set in {RecToList LR1_TABLE} do
	    ACT GO
	 in
	    if {HasFeature ACTION Set.KEY} then
	       ACT=ACTION.(Set.KEY)
	       GO =GOTO  .(Set.KEY)
	    else
	       ACT={NewDictionary}
	       GO ={NewDictionary}
	       ACTION.(Set.KEY) := ACT
	       GOTO  .(Set.KEY) := GO
	    end
	    for I in Set.items do
	       case I.tail
	       of nil andthen I.rule.head\=Begin then
		  Action=reduce(I.rule prec:I.rule.prec)
		  Actions={CondSelect ACT I.look nil}
	       in
		  if {Member Action Actions} then skip
		  else ACT.(I.look) := {EnterAction Action Actions} end
	       [] H|_ andthen {IsToken H} then Set2={Goto Set H} in
		  if Set2.items\=nil then
		     Action=shift(Set2.KEY prec:{CondSelect PREC_TABLE H unit})
		     Actions={CondSelect ACT H nil}
		  in
		     if {Member Action Actions} then skip
		     else ACT.H := {EnterAction Action Actions} end
		  end
	       else skip end
	       if I.rule.num==1 andthen I.dot==1 andthen I.look==Accept then
		  Action=accept(prec:unit)
		  Actions={CondSelect ACT Accept nil}
	       in
		  if {Member Action Actions} then skip
		  else ACT.Accept := {EnterAction Action Actions} end
	       end
	    end
	    for X in SYMBOLS do
	       if {IsToken X} then skip else
		  Set2 = {Goto Set X}
	       in
		  if Set2.items\=nil then
		     Loc  = Set2.KEY
		     Locs = {CondSelect GO X nil}
		  in
		     if {Member Loc Locs} then skip
		     else GO.X := Loc|Locs end
		  end
	       end
	    end
	 end
	 table(
	    type   : if KEY==key then lr(1) else lalr(1) end
	    init   : if KEY==key
		     then INIT_STATE_KEY
		     else INIT_STATE_COREKEY end
	    action : {RecMap {DictToTable ACTION} DictToTable}
	    goto   : {RecMap {DictToTable GOTO  } DictToTable})
      end

      fun {MakeLR  } {MakeParsingTables     key} end
      fun {MakeLALR} {MakeParsingTables corekey} end

   in
      lalr(
	 firsttable : FIRST_TABLE
	 first      : First
	 followtable: FOLLOW_TABLE
	 follow     : Follow
	 lr1        : LR1_TABLE
	 settable   : SET_TABLE
	 makeLR     : MakeLR
	 makeLALR   : MakeLALR)
   end

   %% {GetConflicts +Table ?OUT}
   %%     Table is a parsing table computed using MakeLR or MakeLALR
   %% OUT is unit if the table has no conflicts, else it is a record
   %% conflicts(shiftshift:N1 shiftreduce:N2 reducereduce:N3 goto:N4)
   %% summarizing the number of conflicts of various kinds.

   fun {GetConflicts Table}
      ShiftShift   = {NewCell 0}
      ShiftReduce  = {NewCell 0}
      ReduceReduce = {NewCell 0}
      Goto         = {NewCell 0}
   in
      for ActionTable in {RecToList Table.action} do
	 for Actions in {RecToList ActionTable} do
	    case Actions
	    of nil then skip
	    [] [_] then skip
	    else
	       {ForAllTail Actions
		proc {$ A|Bs} LA={Label A} in
		   for B in Bs do LB={Label B} in
		      {Incr
		       case LA#LB
		       of shift #shift  then ShiftShift
		       [] shift #reduce then ShiftReduce
		       [] reduce#shift  then ShiftReduce
		       [] reduce#reduce then ReduceReduce
		       end}
		   end
		end}
	    end
	 end
      end
      for GotoTable in {RecToList Table.goto} do
	 for Locs in {RecToList GotoTable} do
	    case Locs
	    of nil then skip
	    [] [_] then skip
	    [] _|L then N1 N2 in
	       {Exchange Goto N1 N2}
	       N2=N1+{Length L}
	    end
	 end
      end
      if {Access ShiftShift  }==0 andthen
	 {Access ShiftReduce }==0 andthen
	 {Access ReduceReduce}==0 andthen
	 {Access Goto        }==0
      then
	 unit
      else
	 conflicts(
	    shiftshift   : {Access ShiftShift  }
	    shiftreduce  : {Access ShiftReduce }
	    reducereduce : {Access ReduceReduce}
	    goto         : {Access Goto        })
      end
   end

   %%

   fun {Reduce N Stack Sems}
      if N==0 then Stack#Sems
      elsecase Stack of _|_|Sem|Stack then
	 {Reduce N-1 Stack Sem|Sems}
      end
   end

   fun {MakeDetEntryAction E}
      case E of [V] then
	 case V
	 of accept(     prec:_) then accept
	 [] shift(State prec:_) then shift(State)
	 [] reduce(Rule prec:_) then reduce(Rule)
	 end
      end
   end
   
   fun {MakeDetTableAction R}
      {RecMap R MakeDetEntryAction}
   end

   fun {MakeDetEntryGoto E}
      case E of [V] then V end
   end

   fun {MakeDetTableGoto R}
      {RecMap R MakeDetEntryGoto}
   end

   fun {MakeParser Table}
      ACTION = {RecMap Table.action MakeDetTableAction}
      GOTO   = {RecMap Table.goto   MakeDetTableGoto}
      INIT   = Table.init
      %% the stack is a repeating sequence of State|Token|Semantic|...
      %% Input is a list of tokens token(sym:ATOM sem:VAL coord:COORD)
      fun {ParseLoop Input Stack}
	 case Input
	 of nil then {ParseLoop token(sym:Accept sem:Accept)|EOF Stack}
	 [] Tok|Toks then
	    case Stack of State|_ then
	       case {CondSelect ACTION.State Tok.sym unit}
	       of unit then raise parser(action:none stack:Stack input:Input) end
	       [] accept then
		  if Toks\=EOF then
		     raise parser(action:accept stack:Stack input:Input) end
		  elsecase Stack of _|_|Sem|_ then
		     Sem
		  end
	       [] shift(State2) then
		  {ParseLoop Toks State2|Tok|Tok|Stack}
	       [] reduce(Rule) then
		  case {Reduce Rule.len Stack nil}
		  of ((State2|_)=Stack2)#Sems then
		     Lab=Rule.head
		     State3={CondSelect GOTO.State2 Lab unit}
		  in
		     if State2==unit then
			raise parser(action:reduce stack:Stack input:Input) end
		     else
			{ParseLoop Input
			 State3|Lab|{ApplyAction Rule.action Lab Sems}|Stack2}
		     end
		  end
	       end
	    end
	 end
      end
      fun {Parse Input}
	 {ParseLoop Input [INIT]}
      end
   in
      Parse
   end

   fun {CoordMerge C1 C2}
      case C1 of unit then C2
      [] Lo1#Hi1 then
	 case C2 of unit then C1
	 [] Lo2#Hi2 then
	    {Min Lo1 Lo2}#{Max Hi1 Hi2}
	 [] I andthen {IsInt I} then
	    {Min Lo1 I}#{Max Hi1 I}
	 end
      [] I andthen {IsInt C1} then
	 {CoordMerge I#I C2}
      end
   end
   fun {CoordExtent Sems C}
      case Sems
      of nil then C
      [] Sem|Sems then
	 {CoordExtent Sems {CoordMerge C {CondSelect Sem coord unit}}}
      end
   end
   %%
   fun {FileExtent Sems F}
      case Sems
      of nil then F
      [] Sem|_ then {CondSelect Sem file unit}
      end
   end

   fun {ApplyAction Action Lab Sems}
      if Action==unit then
	 value(sem:{ListToTuple Lab Sems} coord:{CoordExtent Sems unit} file:{FileExtent Sems unit})
      elseif {IsAtom Action} then
	 value(sem:{ListToTuple Action Sems} coord:{CoordExtent Sems unit} file:{FileExtent Sems unit})
      elseif {IsInt Action} then {Nth Sems Action}
      elsecase Action of _|_ then L={CollectSems Action Sems} in
	 value(sem:L coord:{CoordExtent L unit} file:{FileExtent L unit})
      [] nil then value(sem:nil coord:unit file:unit)
      [] '^'(V) then
	 value(sem:V coord:{CoordExtent Sems unit} file:{FileExtent Sems unit})
      elseif {IsRecord Action} then
	 Args={CollectSems {RecToList Action} Sems}
      in
	 value(sem  :{ToTuple {Label Action} Args}
	       coord:{CoordExtent Args unit} file:{FileExtent Args unit})
      else Sem={Action Sems} in
	 case Sem
	 of value(sem:_ coord:_ file:_) then Sem
	 else value(sem:Sem coord:{CoordExtent Sems unit} file:{FileExtent Sems unit}) end
      end
   end

   fun {CollectSems Ns Sems}
      case Ns
      of nil then nil
      [] N|Ns then {Nth Sems N}|{CollectSems Ns Sems} end
   end

   fun {MakeNameVS L Sep}
      case L
      of nil then nil
      [] H|T then
	 Sep#
	 if {IsAtom H} orelse {IsName H} then H
	 elsecase H of '|'(...) then
	    '('#{FoldL {RecToList H}
		 fun {$ L H}
		    if L==nil then nil
		    else L#' | ' end
		    #{MakeNameVS H nil}
		 end nil}#')'
	 [] '>'(...) then
	    {MakeNameVS {RecToList H} nil}
	 else
	    {Label H}#'('#
	    {FoldL {RecToList H}
	     fun {$ L H}
		if L==nil then nil else ' ' end#
		{MakeNameVS H nil}
	     end nil}#')'
	 end
	 #{MakeNameVS T ' '}
      elseif {IsAtom L} then Sep#L
      else {MakeNameVS [L] Sep}
      end
   end
   
   %% expand templates
   %% '?'(A) | '*'(A) | '+'(A) | '**'(A B) | '++'(A B) | '|'(L1 ... Ln)
   
   fun {Preprocess Grammar}

      proc {PUSH C V}
	 L in {Exchange C L V|L}
      end

      Rules = {NewCell Grammar.rules}

      %% first collect all templates occuring in the grammar

      Alist = {NewCell nil}

      fun {Assoc K L}
	 case L
	 of nil then unit
	 [] (Key#Val)|T then
	    if Key==K then Val else {Assoc K T} end
	 end
      end
      fun {Detemplate L}
	 case L
	 of nil then nil
	 [] H|T then
	    if {IsAtom H} orelse {IsName H} then H|{Detemplate T}
	    else {Append {GetTemplate H} {Detemplate T}} end
	 end
      end

      NameCount={NewCell 1}
      fun {NewCount} N1 N2 in
	 {Exchange NameCount N1 N2} N2=N1+1 N1
      end
      fun {NewNameUsing T N}
	 {VS2A '<'#N#'>: '#{MakeNameVS T nil}}
      end
      fun {NewName T}
	 {NewNameUsing T {NewCount}}
      end

      fun {GetTemplate T}
	 case {Assoc T {Access Alist}}
	 of unit then
	    %% template is not yet known
	    case T
	    of '?'(A)  then Sym={NewName T} in
	       {PUSH Alist T#Sym}
	       {PUSH Rules rule(head:Sym body:nil action:RET)}
	       {PUSH Rules rule(head:Sym body:[A] action:RET)}
	       [Sym]
	    [] '*'(A)  then Sym={NewName T} in
	       {PUSH Alist T#Sym}
	       {PUSH Rules rule(head:Sym body:nil action:RET)}
	       {PUSH Rules rule(head:Sym body:[A Sym] action:CONS)}
	       [Sym]
	    [] '+'(A)  then N={NewCount}
	       Sym1={NewNameUsing T N} T1={Adjoin T '*'}
	       Sym2={NewNameUsing T1 N}
	    in
	       {PUSH Alist T#Sym1}
	       {PUSH Rules rule(head:Sym1 body:[A Sym2] action:CONS)}
	       {PUSH Rules rule(head:Sym2 body:nil action:RET)}
	       {PUSH Rules rule(head:Sym2 body:[Sym1] action:1)}
	       [Sym1]
	    [] '**'(A B) then N={NewCount}
	       Sym1={NewNameUsing T N}
	       Sym2={NewNameUsing '*'(B A) N}
	    in
	       {PUSH Alist T#Sym1}
	       {PUSH Rules rule(head:Sym1 body:nil action:RET)}
	       {PUSH Rules rule(head:Sym1 body:[A Sym2] action:CONS)}
	       {PUSH Rules rule(head:Sym2 body:nil action:RET)}
	       {PUSH Rules rule(head:Sym2 body:[B Sym1] action:2)}
	       [Sym1]
	    [] '++'(A B) then N={NewCount}
	       Sym1={NewNameUsing T N}
	       Sym2={NewNameUsing '*'(B A) N} in
	       {PUSH Alist T#Sym1}
	       {PUSH Rules rule(head:Sym1 body:[A Sym2] action:CONS)}
	       {PUSH Rules rule(head:Sym2 body:nil action:RET)}
	       {PUSH Rules rule(head:Sym2 body:[B Sym1] action:2)}
	       [Sym1]
	    [] '>'(...)  then {Map {RecToList T} Detemplate}
	    [] '|'(...) then Sym={NewName T} in
	       {PUSH Alist T#Sym}
	       for L in {RecToList T} do
		  {PUSH Rules rule(head:Sym body:L)}
	       end
	       [Sym]
	    end
	 [] Sym then [Sym] end
      end

      AllRules =
      for break:Break collect:Collect do MoreRules in
	 case {Exchange Rules $ MoreRules}
	 of nil then MoreRules=nil {Break}
	 [] R|Rules then
	    MoreRules=Rules
	    {Collect
	     rule(head:R.head
		  body:{Detemplate R.body}
		  action:
		     {CondSelect R action R.head}
		 )}
	 end
      end
   in
      {AdjoinAt Grammar rules AllRules}
   end

   fun {MakeLALR Grammar}
      T={Make {Preprocess Grammar}}
      LALR={T.makeLALR}
   in
      case {GetConflicts LALR}
      of unit then {MakeParser LALR}
      [] Conflicts then raise lalr(Conflicts) end end
   end

   fun {MakeLR Grammar}
      T={Make {Preprocess Grammar}}
      LR={T.makeLR}
   in
      case {GetConflicts LR}
      of unit then {MakeParser LR}
      [] Conflicts then raise lr(Conflicts) end end
   end

   fun {GetDetailedConflicts Grammar Kind}
      Rec={Make {Preprocess Grammar}}
      Tab={Rec.case Kind
	   of lr  then makeLR
	   [] lalr then makeLALR end}
   in
      {CollectDetailedConflicts Rec Tab}
   end

   fun {CollectDetailedConflicts Rec Tab}
      fun {Conv A}
	 case A
	 of shift(S prec:P) then shift(Rec.settable.S prec:P)
	 [] reduce(_ prec:_) then A
	 [] accept(prec:_) then accept
	 end
      end
   in
      for ActionTable in {RecToList Tab.action} collect:Collect do
	 for Key#Actions in {RecToListInd ActionTable} do
	    case Actions
	    of nil then skip
	    [] [_] then skip
	    else {Collect Key#{Map Actions Conv}} end
	 end
      end
   end
end
