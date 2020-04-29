###########################################################
### User script for the Digital_Coevolution simulation ####
###########################################################

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
source.file.location <- "/home/robert/PHD/Digital_Coevolution_CH1/"

###########################################################
## The next thing to do is to define where the script 
## should save its results.
## This can be the same folder as the .R files, or any 
## other folder with writing permission.

# Please type the full path to the folder where results   
# should be saved.
result.file.location <- "/home/robert/PHD/Digital_Coevolution_CH1/Results/"

###########################################################
## Now we need a name to identify the results.
## The result file will anyway have the name :
## "Digital_Coevolution_Results_NodeID_Sys.Date_", 
## your filename will be added at the end of that.
result.file.name <- "OldTest"

###########################################################
# Here you can set if the results should be saved raw 
# or summarized or both, logical value FALSE or TRUE
raw.results <- FALSE
summarized.results <-TRUE

###########################################################
## In the lines below you can adjust some of the parameter 
## settings that influence the simulation

## Beware that combinations of large populations and 
## many replicates might overpower your computer.

# For how many time steps should the simulation run?
# It can help to think of that as days in the life 
# of a digital individual
duration.days <- 100

# Here you can set how often a snapshot of all individuals 
# should be saved. Every N timesteps
saving.intervall <- 10

# How many replicates should there be?
replicates <- 10

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
parasite.migration <- 1

# How genotype specific should the infection
# be in percent?
parasite.specificity <- 1

# How virulent should the parasites be?
# Virulence is implemented as percent resources withdrawn
# per time step, depending on infection size.
virulence <- 0.4 

# How much random drift should there be?
# Defined as proportion per timestep.
# This proportion of the host and the parasite population
# will additionally randomly be killed each timestep.
# A value of zero adds no additional random drift.
random.drift <- 0

# Read in the date, so that stuff can run over night without causing trouble
run.date <- Sys.Date()

###########################################################
## That's it. You have set all parameters. To run the 
## simulation either source this script or if you already 
## have executed the lines above, execute the remaining 
## lines as well.
###########################################################

###########################################################
## This sources a helper script that runs the simulation. 
print(paste("Simulation started :", Sys.time()))
source(file =  paste(source.file.location, "Digital_Coevolution_Run.R", sep = ""), local = TRUE)
print("Congratulations, you have successfully run the Digital_Coevolution simulation. Now go and check out those amazing results.")
print(paste("Simulation ended", Sys.time()))