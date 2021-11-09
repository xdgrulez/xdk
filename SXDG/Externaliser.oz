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

%% An externaliser encapsulates information about how to transform a
%% search space into a domain-specific external representation.

functor
import
   Service Space
   Helpers at 'Helpers.ozf'
   Log(logged) at 'Log.ozf'
export
   Externaliser
define
   LogPrefix = "Externaliser"
   class Externaliser from Log.logged
      %% initialisation
      meth init
	 Log.logged,init
	 {self log(LogPrefix "method call: init")}
      end
      
      %% Given a space S, return the externalisation of S (a string).
      %% This is done through a synchronous service, as explained in
      %% Schulte's book, p. 52.
      meth externaliseFull(S $)
	 D SF = {Service.synchronous.newFun fun {$ X} D=X unit end}
	 DescriptionElement = {New Helpers.xml.element init("description")}
      in
	 {self log(LogPrefix "method call: externaliseFull")}
	 {Space.ask S _} %% make sure that S is stable
	 {Space.inject S proc {$ R} {SF {self describe(R $)} _} end}
%	 {DescriptionElement addAttribute("type" "full")}
	 {DescriptionElement addAttribute("mode" "complete")}
	 {DescriptionElement addChildString({self externalise(D $)})}
	 {DescriptionElement toString($)}
      end

      %% Given a space S2, and a reference space S1, return the
      %% externalisation of the differences between S1 and S2 (a
      %% string) in terms of the externalisation function.
      meth externaliseDiff(S1 S2 $)
	 D1 SF1 = {Service.synchronous.newFun fun {$ X} D1=X unit end}
	 D2 SF2 = {Service.synchronous.newFun fun {$ X} D2=X unit end}
	 DescriptionElement = {New Helpers.xml.element init("description")}
	 Diff
      in
	 {self log(LogPrefix "method call: externaliseDiff")}
	 {Space.ask S1 _} %% make sure that S1 is stable
	 {Space.ask S2 _} %% make sure that S2 is stable
	 {Space.inject S1 proc {$ R} {SF1 {self describe(R $)} _} end}
	 {Space.inject S2 proc {$ R} {SF2 {self describe(R $)} _} end}
	 {self diff(D1 D2 Diff)}
%	 {DescriptionElement addAttribute("type" "diff")}
	 {DescriptionElement addAttribute("mode" "diff")}
	 {DescriptionElement addChildString({self externalise(Diff $)})}
	 {DescriptionElement toString($)}
      end
   end
end
