#!/bin/bash
pw.exe -p Examples/treePW.ul --nooptimize
pw.exe -p Examples/valencyPW.ul --nooptimize
pw.exe -p Examples/agrPW.ul --nooptimize
pw.exe -p Examples/agreementPW.ul --nooptimize
pw.exe -p Examples/orderPW.ul --nooptimize
pw.exe -p Examples/projectivityPW.ul --nooptimize
#
pw.exe -p Examples/dagPW.ul --nooptimize
pw.exe -p Examples/linkingEndPW.ul --nooptimize
pw.exe -p Examples/linkingMotherPW.ul --nooptimize
#
cd ../Solver/Principles/Lib
ozmake
cd -
