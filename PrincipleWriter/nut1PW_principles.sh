#!/bin/bash
pw.exe -p Examples/treePW.ul -o all
pw.exe -p Examples/valencyPW.ul -o all
pw.exe -p Examples/agrPW.ul -o all
pw.exe -p Examples/agreementPW.ul -o all
pw.exe -p Examples/orderPW.ul -o all
pw.exe -p Examples/projectivityPW.ul -o all
#
pw.exe -p Examples/dagPW.ul -o all
pw.exe -p Examples/linkingEndPW.ul -o all
pw.exe -p Examples/linkingMotherPW.ul -o all
#
cd ../Solver/Principles/Lib
ozmake
cd -
