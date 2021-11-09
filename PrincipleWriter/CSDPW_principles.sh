#!/bin/bash
pw.exe -p Examples/treePW.ul -o all
pw.exe -p Examples/valencyPW.ul -o all
#
pw.exe -p Examples/orderPW.ul -o all
#
pw.exe -p Examples/climbingPW.ul -o all
pw.exe -p Examples/csdPW.ul -o all
#
cd ../Solver/Principles/Lib
ozmake
cd -
