#!/bin/bash
pw.exe -p Examples/treePW.ul -o all
pw.exe -p Examples/valencyPW.ul -o all
#
pw.exe -p Examples/orderDepsPW.ul -o all
#
pw.exe -p Examples/blockPW.ul -o all
pw.exe -p Examples/orderBlocksPW.ul -o all
pw.exe -p Examples/commas1PW.ul -o all
#
cd ../Solver/Principles/Lib
ozmake
cd -
