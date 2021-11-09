%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Space(clone commit new ask merge)
   Property(get)
export
   Search
define
   %% Search: ScriptProc SolutionsI MaxRecoDistI OutputProc -> Rec
   %% Search for n (=SolutionsI) solutions of solver script ScriptProc with
   %% recomputation distance MaxRecoDistI.
   %% OutputProc: I Solution -> U is a procedure to output each solution.
   %% (having index I).
   %% Returns record Rec of search statistics.
   fun {Search ScriptProc SolutionsI MaxRecoDistI OutputProc}
      fun {Recompute RecoSpc RecoIs}
	 case RecoIs
	 of nil then
	    {Space.clone RecoSpc}
	 [] RecoI|RecoIs1 then
	    RecoSpc1 = {Recompute RecoSpc RecoIs1}
	 in
	    {Space.commit RecoSpc1 RecoI}
	    RecoSpc1
	 end
      end
      %%
      fun {Loop}
	 Rec = o(choices: 0
		 depth: 1
		 failed: 0
		 succeeded: 0)
	 Spc = {Space.new ScriptProc}
	 I1 = {Property.get 'time.total'}
	 Rec1 =
	 try
	    {Loop1 Spc Spc nil MaxRecoDistI Rec}
	 catch exit(Rec2) then
	    Rec2
	 end
	 I2 = {Property.get 'time.total'}
	 Rec2 = {Adjoin Rec1 o(time: I2-I1)}
      in
	 Rec2
      end
      %%
      fun {Loop1 Spc RecoSpc RecoIs RecoDistI StatRec}
	 o(choices: ChoicesI
	   depth: DepthI
	   failed: FailedI
	   succeeded: SucceededI) = StatRec
      in
	 case {Space.ask Spc}
	 of failed then
	    o(choices: ChoicesI
	      depth: DepthI
	      failed: FailedI+1
	      succeeded: SucceededI)
	 [] succeeded then
	    Spc1 = {Space.clone Spc}
	    Solution = {Space.merge Spc1 $}
	    SucceededI1 = SucceededI+1
	    {OutputProc SucceededI Solution}
	    StatRec1 =
	    o(choices: ChoicesI
	      depth: DepthI
	      failed: FailedI
	      succeeded: SucceededI1)
	    if SucceededI1>=SolutionsI then
	       raise exit(StatRec1) end
	    end
	 in
	    StatRec1
	 [] alternatives(2) then
	    StatRec1 = o(choices: StatRec.choices+1
			 depth: StatRec.depth+1
			 failed: StatRec.failed
			 succeeded: StatRec.succeeded)
	 in
	    if RecoDistI==MaxRecoDistI then
	       Spc1 = {Space.clone Spc}
	       {Space.commit Spc 1}
	       StatRec11 = {Loop1 Spc Spc1 [1] 1 StatRec1}
	       StatRec2 = o(choices: StatRec11.choices
			    depth: StatRec.depth+1
			    failed: StatRec11.failed
			    succeeded: StatRec11.succeeded)
	       {Space.commit Spc1 2}
	       StatRec21 = {Loop1 Spc1 Spc1 nil MaxRecoDistI StatRec2}
	    in
	       o(choices: StatRec21.choices
		 depth: {Max StatRec11.depth StatRec21.depth}
		 failed: StatRec21.failed
		 succeeded: StatRec21.succeeded)
	    else
	       {Space.commit Spc 1}
	       StatRec11 = {Loop1 Spc RecoSpc 1|RecoIs RecoDistI+1 StatRec1}
	       StatRec2 = o(choices: StatRec11.choices
			    depth: StatRec.depth+1
			    failed: StatRec11.failed
			    succeeded: StatRec11.succeeded)
	       Spc1 = {Recompute RecoSpc RecoIs}
	       {Space.commit Spc1 2}
	       StatRec21 = {Loop1 Spc1 RecoSpc 2|RecoIs RecoDistI+1 StatRec2}
	    in
	       o(choices: StatRec21.choices
		 depth: {Max StatRec11.depth StatRec21.depth}
		 failed: StatRec21.failed
		 succeeded: StatRec21.succeeded)
	    end
	 end
      end
   in
      if SolutionsI>0 then
	 if MaxRecoDistI<1 then
	    raise error1('functor':'SolvingStatistics.ozf' 'proc':'Get' msg:'Maximum recomputation distance is less than 1: '#MaxRecoDistI info:o coord:noCoord file:noFile) end
	 end
	 %%
	 StatRec = {Loop}
      in
	 StatRec
      else
	 o(choices: 0
	   depth: 0
	   failed: 0
	   succeeded: 0
	   time: 0)
      end
   end
end
