%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
   System(showError onToplevel)

   Share(printComment) at 'Lib/Share.ozf'

% begin list 1 (required for xdkpm - please do not edit this line)
   Agr(principle)
   AgrPW(principle)
   Agreement(principle)
   Agreement1(principle)
   AgreementDissPW(principle)
   AgreementPW(principle)
   AgreementSubset(principle)
   AgreementSubsetDiplomPW(principle)
   Barriers(principle)
   BarriersAttrib(principle)
   BarriersLabels(principle)
   BarriersPW(principle)
   BarsPW(principle)
   BlockPW(principle)
   CSD(principle)
   CatPW(principle)
   Chorus(principle)
   Climbing(principle)
   ClimbingPW(principle)
   ClimbingSubgraphsPW(principle)
   Coindex(principle)
   CommasPW(principle)
   CsdPW(principle)
   Customs(principle)
   Dag(principle)
   DagPW(principle)
   DisjointDaughtersPW(principle)
   Dutch(principle)
   Entries(principle)
   Government(principle)
   Government1(principle)
   Government1PW(principle)
   GovernmentAcl01PW(principle)
   GovernmentDiplomPW(principle)
   GovernmentDissPW(principle)
   Graph(principle)
   Graph1(principle)
   Graph1Constraints(principle)
   Graph1Dist(principle)
   GraphConstraints(principle)
   GraphDist(principle)
   GraphPW(principle)
   GraphPWConstraints(principle)
   GraphPWDist(principle)
   In(principle)
   In1(principle)
   In2(principle)
   Linking12BelowStartEnd(principle)
   LinkingAbove(principle)
   LinkingAboveBelow1or2Start(principle)
   LinkingAboveBelow1or2StartPW(principle)
   LinkingAboveEnd(principle)
   LinkingAboveEndPW(principle)
   LinkingAboveStart(principle)
   LinkingAboveStartEnd(principle)
   LinkingBelow(principle)
   LinkingBelow1or2Start(principle)
   LinkingBelow1or2StartPW(principle)
   LinkingBelowEnd(principle)
   LinkingBelowEndPW(principle)
   LinkingBelowStart(principle)
   LinkingBelowStartEnd(principle)
   LinkingBelowStartPW(principle)
   LinkingDaughter(principle)
   LinkingDaughterEnd(principle)
   LinkingDaughterEndDissPW(principle)
   LinkingDaughterEndPW(principle)
   LinkingEnd(principle)
   LinkingEndDissPW(principle)
   LinkingEndPW(principle)
   LinkingMother(principle)
   LinkingMotherEnd(principle)
   LinkingMotherPW(principle)
   LinkingNotDaughter(principle)
   LinkingNotMother(principle)
   LinkingSisters(principle)
   LockingDaughters(principle)
   LockingDaughtersDissIDPAPW(principle)
   LockingDaughtersDissPAPW(principle)
   LookRight(principle)
   Order(principle)
   Order1(principle)
   Order2(principle)
   Order2dPW(principle)
   OrderBlocksPW(principle)
   OrderDepsPW(principle)
   OrderPW(principle)
   OrderParsePW(principle)
   OrderWithCuts(principle)
   OrderYields2dPW(principle)
   OrderYieldsPW(principle)
   Out(principle)
   PAgrPW(principle)
   PGovernmentDissPW(principle)
   PL(principle)
   PartialAgreement(principle)
   PartialAgreementDissPW(principle)
   PlPW(principle)
   Projective2dPW(principle)
   Projectivity(principle)
   ProjectivityPW(principle)
   Relative(principle)
   SameEdges(principle)
   Subgraphs(principle)
   SubgraphsDissPW(principle)
   SubgraphsPW(principle)
   TAG(principle)
   Test(principle)
   TestPW(principle)
   Tree(principle)
   Tree1(principle)
   TreePW(principle)
   Valency(principle)
   ValencyPW(principle)
   XTAG(principle)
   XTAGLinking(principle)
   XTAGRedundant(principle)
   XTAGRoot(principle)
% end list 1 (required for xdkpm - please do not edit this line)
export
   Principles
   Post
prepare
   ProcedureArity = Procedure.arity
define
   Principles =
   [
% begin list 2 (required for xdkpm - please do not edit this line)
    Agr.principle
    AgrPW.principle
    Agreement.principle
    Agreement1.principle
    AgreementDissPW.principle
    AgreementPW.principle
    AgreementSubset.principle
    AgreementSubsetDiplomPW.principle
    Barriers.principle
    BarriersAttrib.principle
    BarriersLabels.principle
    BarriersPW.principle
    BarsPW.principle
    BlockPW.principle
    CSD.principle
    CatPW.principle
    Chorus.principle
    Climbing.principle
    ClimbingPW.principle
    ClimbingSubgraphsPW.principle
    Coindex.principle
    CommasPW.principle
    CsdPW.principle
    Customs.principle
    Dag.principle
    DagPW.principle
    DisjointDaughtersPW.principle
    Dutch.principle
    Entries.principle
    Government.principle
    Government1.principle
    Government1PW.principle
    GovernmentAcl01PW.principle
    GovernmentDiplomPW.principle
    GovernmentDissPW.principle
    Graph.principle
    Graph1.principle
    Graph1Constraints.principle
    Graph1Dist.principle
    GraphConstraints.principle
    GraphDist.principle
    GraphPW.principle
    GraphPWConstraints.principle
    GraphPWDist.principle
    In.principle
    In1.principle
    In2.principle
    Linking12BelowStartEnd.principle
    LinkingAbove.principle
    LinkingAboveBelow1or2Start.principle
    LinkingAboveBelow1or2StartPW.principle
    LinkingAboveEnd.principle
    LinkingAboveEndPW.principle
    LinkingAboveStart.principle
    LinkingAboveStartEnd.principle
    LinkingBelow.principle
    LinkingBelow1or2Start.principle
    LinkingBelow1or2StartPW.principle
    LinkingBelowEnd.principle
    LinkingBelowEndPW.principle
    LinkingBelowStart.principle
    LinkingBelowStartEnd.principle
    LinkingBelowStartPW.principle
    LinkingDaughter.principle
    LinkingDaughterEnd.principle
    LinkingDaughterEndDissPW.principle
    LinkingDaughterEndPW.principle
    LinkingEnd.principle
    LinkingEndDissPW.principle
    LinkingEndPW.principle
    LinkingMother.principle
    LinkingMotherEnd.principle
    LinkingMotherPW.principle
    LinkingNotDaughter.principle
    LinkingNotMother.principle
    LinkingSisters.principle
    LockingDaughters.principle
    LockingDaughtersDissIDPAPW.principle
    LockingDaughtersDissPAPW.principle
    LookRight.principle
    Order.principle
    Order1.principle
    Order2.principle
    Order2dPW.principle
    OrderBlocksPW.principle
    OrderDepsPW.principle
    OrderPW.principle
    OrderParsePW.principle
    OrderWithCuts.principle
    OrderYields2dPW.principle
    OrderYieldsPW.principle
    Out.principle
    PAgrPW.principle
    PGovernmentDissPW.principle
    PL.principle
    PartialAgreement.principle
    PartialAgreementDissPW.principle
    PlPW.principle
    Projective2dPW.principle
    Projectivity.principle
    ProjectivityPW.principle
    Relative.principle
    SameEdges.principle
    Subgraphs.principle
    SubgraphsDissPW.principle
    SubgraphsPW.principle
    TAG.principle
    Test.principle
    TestPW.principle
    Tree.principle
    Tree1.principle
    TreePW.principle
    Valency.principle
    ValencyPW.principle
    XTAG.principle
    XTAGLinking.principle
    XTAGRedundant.principle
    XTAGRoot.principle
% end list 2 (required for xdkpm - please do not edit this line)
   ]
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Post: G Nodes DebugB -> U
   %% Posts all possible constraints in grammar G on node records Nodes.
   %%
   proc {Post G Nodes FD FS Select PW PWByNeed DebugB}
      proc {PostConstraints ProcProcPnCAPriITups}
	 for Proc#_#Pn#CA#PriI in ProcProcPnCAPriITups do
%	    {System.show 'constraint'#CA}
	    if {PnIsActive Pn UsedDIDAs UsedPns} then
	       Principle = {Pn2Principle Pn}
	    in
	       if DebugB then
		  DIDA = Principle.dIDA
	       in
		  {System.showError constraint#' '#DIDA#' '#CA#' '#PriI}
	       end
	       if {System.onToplevel} then
		  DIDA = Principle.dIDA
		  PIDA = Principle.pIDA
	       in
		  {Share.printComment DIDA#' '#PIDA#' '#CA var}
		  {Share.printComment DIDA#' '#PIDA#' '#CA constraint}
		  {Share.printComment DIDA#' '#PIDA#' '#CA branch}
	       end
	       case {ProcedureArity Proc}
	       of 6 then {Proc Nodes G Principle FD FS Select}
	       [] 7 then {Proc Nodes G Principle FD FS Select PW}
	       [] 8 then {Proc Nodes G Principle FD FS Select PW PWByNeed}
	       end
	    end
	 end
      end
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      PnIsActive = G.pnIsActive
      UsedDIDAs = G.usedDIDAs
      UsedPns = G.usedPns
      Pn2Principle = G.pn2Principle
      ProcProcPnCAPriITups = G.procProcPnCAPriITups
   in
      {PostConstraints ProcProcPnCAPriITups}
   end
end
