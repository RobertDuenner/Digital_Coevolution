#!/bin/bash 
export OMP_NUM_THREADS=2
export OMP_THREAD_LIMIT=2
#BSUB -J "Hierarchical_Metapop_25[1-14]%7"
#BSUB -R "rusage[mem=1000]" 
#BSUB -n 2
#BSUB -W 01:00
#BSUB -R "rusage[scratch=1000]" 
#BSUB -o /cluster/home/duennerr/Digital_Coevolution/LognErr/Hierarchical_Metapop_25_duennerr.log.%J.%I
#BSUB -e /cluster/home/duennerr/Digital_Coevolution/LognErr/Hierarchical_Metapop_25_duennerr.err.%J.%I

IDX=$LSB_JOBINDEX

newvars=`tail -n+$((IDX+1)) "/cluster/home/duennerr/Digital_Coevolution/Scripts/Joblist_Hierarchical_Metapop_25.txt" | head -n1`
varid=`tail -n+1 "/cluster/home/duennerr/Digital_Coevolution/Scripts/Joblist_Hierarchical_Metapop_25.txt" | head -n1`
resultname="Hierarchical_Metapop_25"

module load new gcc/4.8.2 r/3.6.0
Rscript "/cluster/home/duennerr/Digital_Coevolution/Scripts/Digital_Coevolution_Run_Unix.R" $varid $newvars $IDX $resultname
