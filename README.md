
# The Digital\_Coevolution simulation

**Author:** Robert Dünner  
**Licence:** GPL-3.0  
**Language:** R

## Introduction

The Digital\_Coevolution simulation is an agent-based time-forward
simulation written in R. It implements detailed life histories of
haploid, clonal, host-type and parasite-type agents. The
Digital\_Coevolution simulation can be used to simulate metapopulations
of arbitrary numbers of interconnected subpopulations with detailed
migration schemes for both host-type and parasite-type agents. It allows
for the specification of any type of genotype specific infection system
via an infection table.  
The Digital\_Coevolution simulation can be used for research and
teaching in negative frequency-dependent host-parasite coevolution.  
A very detailed description of the Digital\_Coevolution simulation that
was published as the first chapter of my PhD thesis can be found here.

# Using the Digital\_Coevolution simulation

## Overview

The Digital\_Coevolution simulation currently consists of three to four
interdependent R scripts. In order to be able to run the
Digital\_Coevolution simulation yourself, you simply have to download or
copy the relevant scripts from the GitHub repository to your computer.
The Digital\_Coevolution simulation is implemented in R (Team 2020) and
relies heavily on the data.table package (Dowle and Srinivasan 2019).
You can download the newest R version for your system from
[CRAN.](https://cran.r-project.org/).

This document is written in R markdown (Xie, Allaire, and Grolemund
2018; Allaire et al. 2020) in R (Team 2020) using R Studio (Team 2019)
as IDE. It consists of blocks of text that are followed by snippets of
commented code when appropriate. The text and the comments do show
substantial overlap, trying to reinforce a thorough understanding. The
code snippets are not complete though, and serve mostly as explanations.
If you would like to have a look at the complete source code or even
contribute, you are very welcome to do so.

## Digital\_Coevolution on your local machine

<details>

<summary> Getting the simulation on your computer </summary>

### Getting the Digital\_Coevolution simulation on your computer

You want to run the Digital\_Coevolution on your computer (your local
machine). That is very easy. You will have to download (or copy) the R
scripts named “Digital\_Coevolution\_Dynamics\_Functions.R”,
“Digital\_Coevolution\_Parameterspace.R”,
“Digital\_Coevolution\_Run.R” and “Digital\_Coevolution\_User.R”
onto your computer. Put them all in the same folder. You will only have
to interact with the “Digital\_Coevolution\_User.R” file. You can open
and have a look at all of them though, there should be some comments
that explain which part is doing what. But beware, changing code in
there can lead to errors and unwanted behaviour.  
The Digital\_Coevolution simulation has been successfully run on
Windows, Linux and Macintosh.

</details>

<details>

<summary> Run a single parameter set on your local machine </summary>

### Run a single parameter set on your local machine

Open the “Digital\_Coevolution\_User.R” file in your favourite editor.
There is one thing that has to be done carefully. The first uncommented
line, that sets the source.file.location, needs to be adapted. There you
have to specify the file path of the folder into which you have
downloaded the Digital\_Coevolution R scripts. This will allow the R
scripts to communicate with each other.  
A bit further down in the script you have to specify the file path where
the simulation should save the results. It can be the same folder than
the scripts. And even a bit further down you have to name the result
file. Make it an easy to remember and meaningful name, so that later you
still know what was done in that run of the simulation.  
You will also find settings called “raw.results” and
“summarized.results”. There you can adjust if you want the raw
results, meaning if a copy of the state of each host and parasite agent
that exists in the simulation at the time of the reporting should be
saved, or if you want summarized results. The summarized results
contains for example number of individuals per genotype, per population,
per metapopulation and so on, for both host and parasite agents as well
as the infection state. Calculating the summary takes slightly longer,
so if you are really hard pressed for time the simulation is faster with
“summarized.results” set to FALSE.

``` r
############################################
### User script for Digital_Coevolution ####
############################################

## This is the script you should be working with when you
## want to use the Digital_Organism.
## There is a few things that have to be done carefully in
## order for this to work smoothly.
## Simply work through this script line by line and 
## follow the instructions.
## Have fun!

###########################################################
## The simulation relies upon four .R files (one of which
## you are reading right now), which you should all have 
## in the same folder.

# Please type the full path to the folder that contains 
# the .R files, including this one.
source.file.location <- "/home/example/path/to/Rscripts/"

###########################################################
## The next thing to do is to define where the script 
## should save its results.
## This can be the same folder as the .R files, or any 
## other folder with writing permission.

# Please type the full path to the folder where results 
# should be saved.
result.file.location <- "/home/example/path/to/results/"

###########################################################
## Now we need a name to identify the results.
## The result file will anyway have the name :
## "Digital_Coevolution_Results_Sys.Date_", 
## your filename will be added at the end of that.
result.file.name <- "YourResultNameHere"

###########################################################
# Here you can set if the results should be saved raw 
# or summarized or both, logical value FALSE or TRUE
raw.results <- FALSE
summarized.results <- TRUE
```

The remainder of the file allows you to set some of the parameters of
the simulation. This is where stuff gets interesting, and you should
play around with the values. Don’t worry, here you should not be able to
break the simulation. You can for example set how many host populations
should be simulated. And how large they should be. Or how virulent the
parasite should be. If you specify too large host populations and a too
long “duration.days” at the same time, the simulation will take a very
long time and produce a very large result data set. How long a run of
the simulation actually takes is any ones guess, as that depends heavily
on the abilities of your local machine. Best would be to start small and
work your way up.  
One important setting that can help you to reduce the result file size
for long simulation is the saving.interval. This simply means that every
N time steps the complete host and parasite data.tables will be saved
into the data file in append mode. If the setting is left at 1, the
default, then every time step will be saved. If you set another value,
for example 10, then only every 10 time-steps will be saved, thus
decreasing the size of the final output file by 10, but also decreasing
your resolution in time. The simulation will run slightly faster if the
reporting window is larger. If the reporting window is set to the same
value as the duration of the simulation in “duration.days”, then only
the starting and the ending state of the simulation will be saved. As
with many things, there is a trade-off.  
If you want to compare different parameter settings, you will have to do
that consecutively. Set them, name the result, run the simulation,
repeat. If you want to run many different parameter settings (parameter
space exploration), then you will probably want to run the
Digital\_Coevolution simulation on a server or a cluster. Running many
different parameter settings will take some time on a normal computer.
Just refer to the next sections for running Digital\_Coevolution on a
server or cluster.

``` r
###########################################################
## In the lines below you can adjust some of the parameter 
## settings that influence the simulation

## Beware that combinations of large populations and 
## many replicates might overpower your computer.

# For how many time steps should the simulation run?
# It can help to think of that as days in the life 
# of a digital individual
duration.days <- 1000

# Here you can set how often a snapshot of all individuals 
# should be saved. Every N timesteps
saving.intervall <- 1

# How many replicates should there be?
replicates <- 1

###########################################################
## Here you can adjust the parameters that influence the 
## digital organisms themselves

# How many host populations should there be, and how large
# should they be? This doesn't directly set the number
# of individuals, but the resources that are available 
# per population. More resources will lead to larger 
# populations, but the exact number of individuals 
# that will result depends on many things.
host.populations <- c(100,100) 

# How many host genotypes should there be?
# Note that as default, each host genotype gets its own
# parasite genotype as well. 
host.genotypes <- 5

# Which proportion of the host populations should 
# randomly migrate each time step
host.migration <- 0

# Which proportion of the parasite populations
# should randomly migrate?
parasite.migration <- 0.5

# How genotype specific should the infection
# be in percent?
parasite.specificity <- 1

# How virulent should the parasites be?
# Virulence is implemented as percent resources withdrawn
# per time step, depending on infection size.
virulence <- 0.2 

# How much random drift should there be?
# Defined as proportion per timestep.
# This proportion of the host and the parasite population
# will additionally randomly be killed each timestep.
# A value of zero adds no additional random drift.
random.drift <- 0
```

The last thing you need to do in order to run the Digital\_Coevolution
simulation is simply to execute the whole script. If you already have
executed all the parameter settings described above, you can simply
execute the remaining lines of the script. Or to make things clean,
source the whole script in a clean R session. That’s it, the simulation
will start running, and notify you whence it is done.

``` r
###########################################################
## That's it. You have set all parameters. To run the 
## simulation either source this script or if you already 
## have executed the lines above, execute the remaining 
## lines as well.
###########################################################

###########################################################
## This sources a helper script that runs the simulation. 
print(paste("Simulation started :", Sys.time()))

source(file =  
         paste(source.file.location, "Digital_Coevolution_Run.R", sep = ""), 
       local = TRUE)
print("Congratulations, you have successfully run the Digital_Coevolution simulation. 
  Now go and check out those amazing results.")

print(paste("Simulation ended", Sys.time()))
```

</details>

<details>

<summary> Getting the results </summary>

### Getting the results

If you see the message: “Congratulations, you have successfully run the
Digital\_Coevolution simulation. Now go and check out those amazing
results.” on your screen, then you have successfully run the
Digital\_Coevolution simulation and you should go and check out those
amazing results.  
The results will be three files in the folder that you have specified in
the "\_User" script as result.file.location. Two file names will begin
with the name you have set in result.file.name, followed by “*Host*” or
“*Parasite*”, then the date on which the simulation was run, and
finally .csv, as the results are saved as simple comma separated values.
These are the results from your simulation run. An example result file
could be: “MyResult\_Host\_2020\_02\_14.csv”. The third file that is
generated is named
“Digital\_Coevolution\_Parameters\_run.date\_result.file.name.RDS”.
That is a snapshot of the R environment at the beginning of the
simulation, after all parameter settings have been made, but before the
first loop of the simulation has run. It serves as a backup storage of
the parameter settings of your run, should you need them at a later
stage.

</details>

## Digital\_Coevolution on a high performance cluster

<details>

<summary> The cluster computing environment </summary>

### The cluster computing environment

The Digital\_Coevolution simulation has been used extensively on a high
performance cluster computer from ETH Zurich, Euler. Cluster computers
are powerful aggregations of several (thousands) of computing nodes that
are used for scientific calculations or other tasks that need lots of
power. A single node is usually far more powerful than an average home
computer, harbouring multiple CPUs with multiple cores and plenty of
memory (RAM). Users will be able to get a subset of the cluster computer
resources that fits their need. Usually, a user will submit a computing
job that has specific requirements in terms of CPU cores and memory.
Running several such jobs in parallel is what makes cluster computers so
powerful. As each job is independent, this is a great tool for parameter
space exploration, where you want to run the simulation with many
different parameter settings.  
How a cluster computer can be used is dependent on the implementation of
the cluster. In my use case of Euler cluster of ETH, the cluster runs on
Unix and its resources are managed by an IBM LSF. LSF stands for load
sharing facility and its the tool that distributes the available
resources among the jobs requested by the users. The cluster itself can
be accessed via entry nodes like a normal Unix server, but running jobs
on compute nodes can only be done via the LSF system. Access to the
entry node is done via ssh from within the network. Your access system
might differ.

</details>

<details>

<summary> Getting the simulation to a cluster </summary>

### Getting the Digital\_Coevolution simulation to a cluster

Make sure that the cluster has R available on it. If it has not, please
contact the administrator of your cluster, they will be able to help
you.  
Getting the Digital\_Coevolution simulation on the cluster is the easy
part. Assuming that the entry node works like a standard Unix server,
you simply need to upload all the necessary files to a folder that can
be accessed by you. You will need three R scripts:
“Digital\_Coevolution\_Dynamics\_Functions.R”,
“Digital\_Coevolution\_Parameterspace.R” and
“Digital\_Coevolution\_Run\_Unix.R”, as well as one bash script:
“Digital\_Coevolution\_User\_Cluster.sh” and one .txt job list file:
“Digital\_Coevolution\_Joblist\_Example.txt”. In total you will need
five files. Uploading to the cluster is done easiest when you already
have downloaded those files from GitHub to you local computer, and then
transfer them to the cluster via scp. On windows you will need an extra
program to transfer files to a Unix server, for example winscp. You will
need to interact with several of the files before running the
simulation, depending on your preferences it might be easier to modify
them on your local machine before uploading (see next section).

</details>

<details>

<summary> Running the simulation on a cluster </summary>

### Running the Digital\_Coevolution simulation on a cluster

Running the Digital\_Coevolution simulation on a cluster is slightly
different from running the simulation on your local machine. You will
have to interact with three files instead of one.  
First you will need to interact with the
“Digital\_Coevolution\_Run\_Unix.R” file. In there you will need to
set the paths to the folder on the cluster to where you have uploaded
the scripts of the Digital\_Coevolution simulation, the folder where you
want the results, and a path to a fast scratch disk that can be used
during the simulation.  
You can also set if you want raw results, summarized results, or both.

``` r
#############################################################
### Helper script for the Digital_Coevolution simulation ####
#############################################################
### High performance cluster computer version ####
##################################################
# Please type the full path to the folder that contains 
# the .R files, including this one.
source.file.location <- "/cluster/home/username/Digital_Coevolution/Scripts/"

# Please type the full path to the folder where results 
# should be saved.
final.result.location <- "/cluster/scratch/username/"

# Set the working directory for within loop saving to ultra fast scratch on cluster node
result.file.location <- "/scratch/"

# Here you can set if the results should be saved raw 
# or summarized or both, logical value FALSE or TRUE
raw.results <- FALSE
summarized.results <-TRUE
```

Next you will have to interact with the .txt file, the
“Digital\_Coevolution\_Joblist\_Example.txt”. That is the file where
you can set the parameters with which most will want to interact. Every
line in the “Digital\_Coevolution\_Joblist\_Example.txt” file is a
separate, independent combination of parameters that will be run in an
independent instance of the Digital\_Coevolution simulation.  
The first line in the “Digital\_Coevolution\_Joblist\_Example.txt” file
are the names of the parameters that can be set. All those parameters
are mandatory as they have no default settings (sorry). The order of
those names in itself is irrelevant, but the order of the parameter
names in the first line, and the parameter values in all other lines
needs to be the same.  
**IMPORTANT:** As the Digital\_Coevolution simulation can simulate
arbitrary numbers of host populations of arbitrary size, those need to
be set explicitly. This means that you will need to add one parameter
for each host population that you want to simulate. The names of these
population parameters need necessarily to start with “host.population.”.
If you want to simulate five host populations, you will need to add five
parameters with distinct names starting with “host.population.”. Don’t
forget that you also need to set the parameter values of the respective
host populations.  
All following lines are the respective parameter values that correspond
to the parameter names. The parameter values need to be in the same
order than the parameter names.  
You can add several lines that contain parameter values to the
joblist.txt file, each of which will result in a separate run of the
Digital\_Coevolution simulation with a different setting of parameters.
Running a parameter space exploration can therefore easily be done by
writing several lines into the
“Digital\_Coevolution\_Joblist\_Example.txt” file. If you have several
lines in the job list, you will be running a “job array”, basically a
list of jobs that you push to the cluster as one, but that the cluster
will work on in a defined chunk size. You will need to know the number
of parameter value lines for that. So all lines in the job list file
minus the first line containing the parameter names.  
Below you find an example of a job list file containing two lines of
parameter values.

The last file you will have to interact with is the bash script
“Digital\_Coevolution\_User\_Cluster.sh”. Bash script? Right, for this
user script you need to use bash, as most clusters (or at least the one
I ran the simulation on) is running on Unix.  
The first line in the bash script tell the interpreter that is is a bash
script.  
The second and third line are used to set the maximum number of threads
that can be used by the data.table package in R (which is used
extensively in the simulation). This is an sensitive setting as it can
produce varying results in different cluster environments. It is needed
because data.table is capable of using multiple cores (or threads)
natively. Data.table will automatically detect the number of cores
available and use them accordingly. The number of cores or threads that
data.table will detect can vary between systems and environments. On
cluster computers there might eventually be the danger that data.table
will detect all available cores on a node and not only the ones assigned
to a job, and try to hijack them. This would lead to conflict and
possibly the process being killed. In order to avoid that, the number of
threads that data.table can detect is set explicitly. This at least is
how I understood it and how I made it work.  
The next 7 lines that all benign with a **\#BSUB** string are intended
for the LSF scheduler. The LSF scheduler distributes the clusters
resources to the jobs that are requesting resources. All cluster
resources that are specified there are valid per job, so each line from
the job list will have those resources available. If you request to
little resources and your job requires more, it will usually be killed
and cannot run to completion. If you repeatedly request way more
resources than your job needs, your administrator will get angry at you.
Usually, jobs that request more resources spend more time in the waiting
queue before they get started. It is best practice though to request as
little resources as possible but as much as needed.  
The dash and character (for example “-J”) defines the use of the
respective line.  
The line “-J” is the name of the job or job array. In the brackets you
can specify the lines in the job list that this job array should run
over, usually all of the parameter value lines in the job list. After
the bracket you can specify the chunk size with which the cluster should
work on the task array.  
The line “-R” is the space allocation, for both memory and scratch disk.
In my bash script it is split in two lines for readability. The line
with “-R” that reads “rusage\[mem=1000\]” is the memory allocation PER
CORE, so the available RAM per job (one line in the job list file) in
mb. A value of 1000 means 1 GB of RAM per core.  
The line “-n” is the number of cores PER JOB. A value of two means that
each job gets two cores.  
The line “-W” is the wall clock, meaning the available time that each
job is allowed to run. The format is dd:hh:mm.  
The line “-R” is the space allocation, for both memory and scratch disk.
In my bash script it is split in two lines for readability. The line
with “-R” that reads “rusage\[scratch=1000\]” is the scratch disk
allocation PER CORE, so the available disc space per job (one line in
the job list file) in mb. A value of 1000 means 1 GB of disc space per
core. This is only the disc space on the ultra fast scratch disc
directly on a computation node, and will not be available after the
simulation ends.  
The line “-o” is the path and name of the output log file.  
The line “-e” is the path and name of the output error file.

A bit further down are two lines starting with “newvars = …” and “varid
= …”, there you need to specify the path on the cluster to the folder
where the “Digital\_Coevolution\_Joblist\_Example.txt” is.  
Then follows a line starting with “resultname=..”. There you specify the
resultname.  
The “module load” line loads the R module on the cluster, this line you
will have to modify with the respective module on your cluster.  
Finally there is the last line that starts with “Rscript”, which starts
the R session and where you need to specify the folder on the cluster
where the R scripts are located.

Those are a lot of things that you need to specify, and especially
setting the requested resources right is not straightforward. But is is
also not as hard as it sounds. Being able to leverage the power of
cluster computing does greatly increase the scope of projects that can
be tackled with the Digital\_Coevolution simulation.

``` bash
#!/bin/bash 
export OMP_NUM_THREADS=2
export OMP_THREAD_LIMIT=2
#BSUB -J "Example_Jobname[1-14]%7"
#BSUB -R "rusage[mem=1000]" 
#BSUB -n 2
#BSUB -W 01:00
#BSUB -R "rusage[scratch=1000]" 
#BSUB -o /cluster/home/username/Digital_Coevolution/LogFiles/
Example_Jobname_username.log.%J.%I
#BSUB -e /cluster/home/username/Digital_Coevolution/ErrorFiles/
Example_Jobname_username.err.%J.%I

IDX=$LSB_JOBINDEX

newvars=`tail -n+$((IDX+1)) "/cluster/home/username/Digital_Coevolution/Scripts/
Digital_Coevolution_Joblist_Example.txt" | head -n1`
varid=`tail -n+1 "/cluster/home/username/Digital_Coevolution/Scripts/
Digital_Coevolution_Joblist_Example.txt" | head -n1`
resultname="Example_Jobname"

module load new gcc/4.8.2 r/3.6.0
Rscript "/cluster/home/username/Digital_Coevolution/Scripts/
Digital_Coevolution_Run_Unix.R" $varid $newvars $IDX $resultname
```

After having set all those things in the
“Digital\_Coevolution\_Run\_Unix.R”, the
“Digital\_Coevolution\_User\_Cluster.sh” and the
“Digital\_Coevolution\_Joblist\_Example.txt” file, you will have to
upload those files into the same folder on the cluster where the other
three R scripts are. In order to start the job array on the cluster, you
need to submit it. For this you will need to access the cluster, usually
using ssh. On clusters using the IBM LSF, you will have to submit your
job array to LSF in order to run it. It is depreciated to execute the
bash script directly. Submitting the job array to LSF is done simply by
navigating to the folder that contains the R and bash scripts and
submitting the bash script “Digital\_Coevolution\_User\_Cluster.sh” to
bsub.

``` bash
bsub < Digital_Coevolution_User_Cluster.sh
```

That’s finally it. Your job is submitted to the queue and will be run
soon. After the job is done, you will find the results in the folder
that you have specified as final.result.folder in the
“Digital\_Coevolution\_Run\_Unix.R” script. The names and structure of
the files is the same as described in the local use case above.

</details>

-----

# Final remarks

Writing the Digital\_Coevolution simulation has been great fun, and
probably one of the most instructive experiences that I ever had. There
is some truth in the saying that you have not understood something
completely before you can not build it yourself. Trying to build this
agent-based simulation and reflecting how those agents have to behave
lead me to have some great realisations on how complex and fascinating
life is, and how little we actually understand. It made me read far more
papers in a far broader array of topics than I would have initially
imagined, and I would not miss a bit of it.  
The Digital\_Coevolution simulation is a purpose-built tool that I have
created to answer some questions in host-parasite coevolution. By
training I am a biologist, so writing this simulation has given me great
exposure to writing functional and fast R code. The source code of this
simulation is provided on GitHub and I invite people to use it, to
collaborate, and to share alterations of it.  
Last but not least: Have fun, explore, stay curious.

Cheers  
Robert

-----

# References

<div id="refs" class="references">

<div id="ref-Allaire2020">

Allaire, JJ, Yihui Xie, Jonathan McPherson, Javier Luraschi, Kevin
Ushey, Aron Atkins, Hadley Wickham, Joe Cheng, Winston Chang, and
Winston Iannone. 2020. “R Markdown: Dynamic Documents for R.”

</div>

<div id="ref-Dowle2019">

Dowle, Matt, and Arun Srinivasan. 2019. “Data.Table: Extension of
‘data.Frame‘.”

</div>

<div id="ref-RCoreTeam2020">

Team, R Core. 2020. “R: A Language and Environment for Statistical
Computing.” Vienna, Austia: R Foundation for Statistical Computing.

</div>

<div id="ref-RStudioTeam2019">

Team, RStudio. 2019. “RStudio: Integrated Development Environment for
R.” Boston, MA: RStudio, Inc.

</div>

<div id="ref-Xie2018">

Xie, Yihui, J.J. Allaire, and Garret Grolemund. 2018. *R Markdown: The
Definitive Guide*. Chapman and Hall / CRC.

</div>

</div>
