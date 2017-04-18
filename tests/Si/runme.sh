#!/bin/bash
#PLEASE DON'T CHANGE THIS SCRIPT UNLESS YOU KNOW WHAT YOU ARE DOING!
#
echo "Hello, "$USER".  This script will run QP GW test in the current directory."
echo "I will read some information from ../make.sys file hence please make sure it's the right one."
echo 

PROG=`cat ../../make.sys|grep PROG|awk  '{print $3}'`
echo "Program name is $PROG"

serial(){
cat results-4-comparison/ini | sed -e "s/nproc_tau=  24 nproc_k=   2/nproc_tau=   1 nproc_k=   1/g" > ini
outfile=`cat ini |grep allfile |awk -F= '{print $2}'`
echo "Complete output you can find in $outfile.out"
echo 
 CMD=../../src/$PROG
[ -e ../../src/$PROG ] && (echo $CMD; $CMD ) || ( echo " I can't find executable ../../src/$PROG please recompile your code" )
}

parallel(){

echo    "To run MPI job i will need from you number of cores to use, if you don't provide i will use 24 cores."
echo -n "Please choose out of those numbers: 24,  12, 8, 6, 4, 3, 2 or 1 [ENTER]: "
read ncores
if [ x"$ncores" == x"24" -o x"$ncores" == x"12" ]; then
  cat results-4-comparison/ini | sed -e "s/nproc_tau=  24 nproc_k=   2/nproc_tau=  $ncores nproc_k=   1/g" > ini
elif [ x"$ncores" == x"8" -o x"$ncores" == x"6" -o x"$ncores" == x"4" -o x"$ncores" == x"3" -o x"$ncores" == x"2" -o x"$ncores" == x"1"  ]; then
  cat results-4-comparison/ini | sed -e "s/nproc_tau=  24 nproc_k=   2/nproc_tau=   $ncores nproc_k=   1/g" > ini
else
  cat results-4-comparison/ini | sed -e "s/nproc_tau=  24 nproc_k=   2/nproc_tau=  24 nproc_k=   1/g" > ini
  ncores=24
fi

outfile=`cat ini |grep allfile |awk -F= '{print $2}'`
echo "Complete output you can find in $outfile.out"
echo 


LPtest=`echo $COMP | sed "s/mpif90//g"`
if [ x$LPtest == x"" ] ; then 
  RUNopi=`which mpif90 | sed "s/mpif90/mpirun/g"`
  RUNmpi=`which mpif90 | sed "s/mpif90/mpiexec/g"`
  ESMPD=`which mpif90  | sed "s/mpif90/smpd/g"` 
else
  RUNopi=`echo $COMP | sed "s/mpif90/mpirun/g"`
  RUNmpi=`echo $COMP | sed "s/mpif90/mpiexec/g"`
  ESMPD=`echo $COMP | sed "s/mpif90/smpd/g"`
fi

if [ -e $RUNmpi ] ; then 
echo "I found mpiexec in $RUNmpi  "
  RUN=$RUNmpi
#  ESMPD=`which mpif90  | sed "s/mpif90/smpd/g"` 
  if [ -e $ESMPD ] ; then
     ps axuf |grep smpd|grep -v grep |grep 12345 |awk '{print  $2}' |xargs kill -9 >& /dev/null
     $ESMPD  -p 12345 
     CMD="$RUN -n $ncores -envlist LD_LIBRARY_PATH -p 12345  ../../src/$PROG "
     [ -e ../../src/$PROG ] && (echo $CMD; $CMD ) || ( echo " I can't find executable ../../src/$PROG please recompile your code" )
   else 
     CMD="$RUN -n $ncores  ../../src/$PROG"
     [ -e ../../src/$PROG ] && (echo $CMD ; $CMD  ) || ( echo " I can't find executable ../../src/$PROG please recompile your code" )
   fi
else
[ -e $RUNopi ] && ( echo "I found mpirun in $RUNopi " ) || ( echo "I can't find mpirun in your PATH."; exit 1)
   RUN=$RUNopi
   CMD="$RUN -np $ncores ../../src/$PROG"
   [ -e ../../src/$PROG ] && (echo $CMD ; $CMD ) || ( echo " I can't find executable ../../src/$PROG please recompile your code" )
fi 
}

echo  "I assume that you alredy compiled the source code and obtained executable $PROG  to run  tests."
echo 
echo -n "Have you compiled the code using parallel [P] or serial [S] compiler?  [ENTER]: "
read compiler
#
if [ x"$compiler" == x"p" -o x"$compiler" == x"P" ]; then
  COMP=`cat ../../make.sys|grep -v "#"|grep F90| awk  '{print $3}'`
  echo "You used as parallel compiler: $COMP.  I will assume the following: "
  echo
  echo "If  mpiexec exists in your PATH then MPI->MPICH2,3 , otherwise  MPI->OpenMPI"
  echo "Please setup properly your environment  variables: PATH and  LD_LIBRARY_PATH"
  echo
#  echo "PATH =  $PATH"

  parallel  
elif [ x"$compiler" == x"s" -o x"$compiler" == x"S" ]; then
  COMP=`cat ../../make.sys|grep -v "#"|grep F90| awk  '{print $3}'`
  echo "You used as serial compiler: $COMP"
  serial 
else 
  echo "You didn't answer neither [P] nor [S],  quitting."
  exit 1
fi 

