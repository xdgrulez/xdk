#!/bin/bash
pw.exe -p Examples/treePW.ul -o all
pw.exe -p Examples/valencyPW.ul -o all
pw.exe -p Examples/agrPW.ul -o all
pw.exe -p Examples/agreementDissPW.ul -o all
pw.exe -p Examples/governmentDissPW.ul -o all
pw.exe -p Examples/pAgrPW.ul -o all
pw.exe -p Examples/pGovernmentDissPW.ul -o all
pw.exe -p Examples/orderPW.ul -o all
pw.exe -p Examples/projectivityPW.ul -o all
#
pw.exe -p Examples/climbingPW.ul -o all
pw.exe -p Examples/climbingSubgraphsPW.ul -o all
pw.exe -p Examples/barriersPW.ul -o all
pw.exe -p Examples/linkingEndDissPW.ul -o all
pw.exe -p Examples/linkingDaughterEndDissPW.ul -o all
#
pw.exe -p Examples/dagPW.ul -o all
pw.exe -p Examples/disjointDaughtersPW.ul -o all
pw.exe -p Examples/lockingDaughtersDissPAPW.ul -o all
#
pw.exe -p Examples/lockingDaughtersDissIDPAPW.ul -o all
pw.exe -p Examples/linkingDaughterEndPW.ul -o all
pw.exe -p Examples/linkingAboveBelow1or2StartPW.ul -o all
pw.exe -p Examples/linkingBelow1or2StartPW.ul -o all
pw.exe -p Examples/linkingMotherPW.ul -o all
pw.exe -p Examples/linkingAboveEndPW.ul -o all
pw.exe -p Examples/linkingBelowStartPW.ul -o all
pw.exe -p Examples/partialAgreementDissPW.ul -o all
#
pw.exe -p Examples/subgraphsDissPW.ul -o all
#
cd ../Solver/Principles/Lib
ozmake
cd -
