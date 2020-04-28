#!/bin/bash 
export OMP_NUM_THREADS=2
export OMP_THREAD_LIMIT=2
for i in {1..2}; do
newvars=`tail -n+$((i+1)) "/home/robert/PHD/Digital_Coevolution_CH1/Joblist_Virulence_vs_Polymorphism_TEST.txt" | head -n1`
varid=`tail -n+1 "/home/robert/PHD/Digital_Coevolution_CH1/Joblist_Virulence_vs_Polymorphism_TEST.txt" | head -n1`
resultname="Virulence_vs_Polymorphism_TEST"
Rscript "/home/robert/PHD/Digital_Coevolution_CH1/Digital_Coevolution_Run_Euler_Local.R" $varid $newvars $i $resultname
done
