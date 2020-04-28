#############################################################
### Helper script for the Digital_Coevolution simulation ####
#############################################################
### High performance cluster computer version ####
##################################################
# Please type the full path to the folder that contains 
# the .R files, including this one.
source.file.location <- "/home/robert/PHD/Digital_Coevolution_CH1/"

# Please type the full path to the folder where results 
# should be saved.
final.result.location <- "/home/robert/PHD/Digital_Coevolution_CH1/Results/"

# Set the working directory for within loop saving to ultra fast scratch on cluster node
result.file.location <- "/home/robert/PHD/Digital_Coevolution_CH1/Results/"

# Here you can set if the results should be saved raw 
# or summarized or both, logical value FALSE or TRUE
raw.results <- FALSE
summarized.results <-TRUE

###########################################################
###########################################################
## Below here, not much has to be changed I think.

print("locations ok")

###########################################################
## Now we need a name to identify the results.
## The result file will anyway have the name :
## "Digital_Coevolution_Results_NodeID_Sys.Date_", 
## your filename will be added at the end of that.
result.file.name <- paste(commandArgs(T)[4], "_", commandArgs(T)[3], sep = "")

##############################################################
## This part extracts the arguments passed from the 
## joblist via the bashscript
argvect <- unlist(strsplit(commandArgs(T)[2], split = ","))
argnames <- unlist(strsplit(commandArgs(T)[1], split = ","))

print(argnames)
print(argvect)
###########################################################
## This part extracts the parameter values from the passed
## command arguments
duration.days <- as.numeric(argvect[grep(pattern = "day", x = argnames, ignore.case = TRUE, value = FALSE)])

saving.intervall <- as.numeric(argvect[grep(pattern =  "inter", x = argnames, ignore.case = TRUE, value = FALSE)])

replicates <- as.numeric(argvect[grep(pattern =  "repl", x = argnames, ignore.case = TRUE, value = FALSE)])

####################

for (i in 1:length(grep(pattern = "host.population", x = argnames, ignore.case = TRUE, value = FALSE))) {
  assign(x = paste("host.population.", i, sep=""), 
         value = as.numeric(argvect[grep(pattern = "host.population", x = argnames, ignore.case = TRUE, value = FALSE)[i]]))}

host.populations <- c(as.numeric(argvect[grep(pattern = "host.population", x = argnames, ignore.case = TRUE, value = FALSE)])) 
host.populations <- host.populations[host.populations != 0]

print(host.populations)
print("host.populations ok")
####################

#host.population.1 <- as.numeric(argvect[grep(pattern =  "host.population.1", x = argnames, ignore.case = TRUE, value = FALSE)])

#host.population.2 <- as.numeric(argvect[grep(pattern =  "host.population.2", x = argnames, ignore.case = TRUE, value = FALSE)])

#host.population.3 <- as.numeric(argvect[grep(pattern =  "host.population.3", x = argnames, ignore.case = TRUE, value = FALSE)])

#host.population.4 <- as.numeric(argvect[grep(pattern =  "host.population.4", x = argnames, ignore.case = TRUE, value = FALSE)])

#host.population.5 <- as.numeric(argvect[grep(pattern =  "host.population.5", x = argnames, ignore.case = TRUE, value = FALSE)])

#host.populations <- c(host.population.1, host.population.2, host.population.3, host.population.4, host.population.5) 
#host.populations <- host.populations[host.populations != 0]
  
##########################
host.genotypes <- as.numeric(argvect[grep(pattern =  "host.geno", x = argnames, ignore.case = TRUE, value = FALSE)])

host.migration <- as.numeric(argvect[grep(pattern =  "host.migr", x = argnames, ignore.case = TRUE, value = FALSE)])

parasite.migration <- as.numeric(argvect[grep(pattern =  "parasite.migr", x = argnames, ignore.case = TRUE, value = FALSE)])

parasite.specificity <- as.numeric(argvect[grep(pattern =  "parasite.spec", x = argnames, ignore.case = TRUE, value = FALSE)])

virulence <- as.numeric(argvect[grep(pattern =  "viru", x = argnames, ignore.case = TRUE, value = FALSE)])

random.drift <- as.numeric(argvect[grep(pattern =  "random.drift", x = argnames, ignore.case = TRUE, value = FALSE)])

# Read in the date, so that stuff can run over night without causing trouble
run.date <- Sys.Date()
print("arguments ok")

# Load data.table library
library(data.table)
setDTthreads(0)

# Source the parameterfile.
source(file =  paste(source.file.location, "Digital_Coevolution_Parameterspace.R", sep = ""), local = TRUE)

# Save a copy of the created parameters
saveRDS(as.list(.GlobalEnv),file = 
          paste(final.result.location, result.file.name, "_", run.date, ".RDS", sep = ""))

# Source the main body of the simulation that includes all dynamics functions
source(file =  paste(source.file.location, "Digital_Coevolution_Dynamics_Functions.R", sep = ""), local = TRUE)

print("sourcing ok")
######################################################################################################################################
### Now we run the simulation
# As a first step we need to create the individuals that are the core of this individual based simulation.
# We do that by calling the individual.creator.function that was sourced in the Main_Body_Digital_Coevolution.R
individual.creator.function() # That's it
print("individuals created")

# Because it is a time forward simulation it is necessary to loop through the timesteps. We do that by calling the dynamics.wrapper function within a loop. 
# The dynamics.wrapper contains all the functions that guide the dynamics of the individuals in each timestep (as for example the host.reproduction.function).
for(i in 1:duration.days){
  dynamics.wrapper()
  # result saving 
  if(i %in% c(1, seq(from = saving.intervall, to = duration.days, by = saving.intervall))){
    if(raw.results) {
      fwrite(Host[Alive.Hosts$Is.Alive], file = 
               paste(result.file.location, result.file.name, "_Host_", run.date, "_raw_", ".csv", sep = ""), append = TRUE)
      fwrite(Parasite[Alive.Parasites$Is.Alive], file = 
               paste(result.file.location, result.file.name, "_Parasite_", run.date, "_raw_", ".csv", sep = ""), append = TRUE)
    } 
    if(summarized.results) {
      temp.data.host <- copy(Host)
      temp.data.host[, Virulence := virulence]
      temp.data.host[, Popsize := host.populations[1]]
      temp.data.host[, Random.Drift := random.drift]
      temp.data.host[, Parasite.Connection := parasite.migration]
      temp.data.host[, Host.Connection := host.migration]
      temp.data.host[, Host.Time := Time]
      
      temp.data.host[, Host.Number.Individuals := .N, by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Host.Population.Size := .N, by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Host.Number.Individuals.Between := .N, by = list(Host.Time, Host.Replicate, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Host.Population.Size.Between := .N, by = list(Host.Time, Host.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Epidemic.Size.Within := sum(Infection.State), by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Epidemic.Size.Total := sum(Infection.State), by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      
      #########
      temp.data.parasite <- copy(Parasite)
      temp.data.parasite[, Virulence := virulence]
      temp.data.parasite[, Popsize := host.populations[1]]
      temp.data.parasite[, Random.Drift := random.drift]
      temp.data.parasite[, Parasite.Connection := parasite.migration]
      temp.data.parasite[, Host.Connection := host.migration]
      temp.data.parasite[, Parasite.Time := Time]
      
      temp.data.parasite[, Parasite.Number.Individuals := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Population, Parasite.Infection.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.parasite[, Parasite.Population.Size := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.parasite[, Parasite.Number.Individuals.Between := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Infection.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.parasite[, Parasite.Population.Size.Between := .N, by = list(Parasite.Time, Parasite.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      
      #########
      temp.data.host[, Total.Parasite.Number.Individuals := Epidemic.Size.Within + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1] & Parasite.Infection.Genotype == Immune.Genotype[1], .N], by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Total.Parasite.Population.Size := Epidemic.Size.Total + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1], .N], by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Total.Parasite.Number.Individuals.Between := Epidemic.Size.Within + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1] & Parasite.Infection.Genotype == Immune.Genotype[1], .N], by = list(Host.Time, Host.Replicate, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      temp.data.host[, Total.Parasite.Population.Size.Between := Epidemic.Size.Total + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1], .N], by = list(Host.Time, Host.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]
      
      #########
      fwrite(
        unique(temp.data.host[, list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Host.Number.Individuals, Host.Population.Size, Host.Number.Individuals.Between, Host.Population.Size.Between, Epidemic.Size.Within, Epidemic.Size.Total, Total.Parasite.Number.Individuals, Total.Parasite.Population.Size, Total.Parasite.Number.Individuals.Between, Total.Parasite.Population.Size.Between, Origin)]), 
        file = paste(result.file.location, result.file.name, "_Host_", run.date, "_summarized_", ".csv", sep = ""), append = TRUE)
      
      fwrite(
        unique(temp.data.parasite[, list(Parasite.Time, Parasite.Replicate, Parasite.Population, Parasite.Infection.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Parasite.Number.Individuals, Parasite.Population.Size, Parasite.Number.Individuals.Between, Parasite.Population.Size.Between)]), 
        file = paste(result.file.location, result.file.name, "_Parasite_", run.date, "_summarized_", ".csv", sep = ""), append = TRUE)
      
    }
  }
}
print("simulation ok")
#############################################
# As this is the version of the script that is supposed to run on the euler cluster
# we need to move the file from the scratch to the final location
file.copy(from = paste(result.file.location, list.files(path = result.file.location), sep = ""), to = final.result.location, overwrite = FALSE)
print("file copying ok")
##############################################################################
### Post processing
# Loading the accumulated dataset, calculate some summary statistics and metrics, get rid of duplicate entries, and save a smaller dataset. This saves time and discspace.
#library(data.table)
#temp.data.host <- fread(paste(result.file.location, result.file.name, "_Host_", run.date, ".csv", sep = ""), header = TRUE)
#temp.data.host[, Virulence := virulence]
#temp.data.host[, Popsize := host.populations[1]]
#temp.data.host[, Random.Drift := random.drift]
#temp.data.host[, Parasite.Connection := parasite.migration]
#temp.data.host[, Host.Connection := host.migration]
#temp.data.host[, Host.Time := Time]

#temp.data.host[, Host.Number.Individuals := .N, by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Host.Population.Size := .N, by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Host.Number.Individuals.Between := .N, by = list(Host.Time, Host.Replicate, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Host.Population.Size.Between := .N, by = list(Host.Time, Host.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Epidemic.Size.Within := sum(Infection.State), by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Epidemic.Size.Total := sum(Infection.State), by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]

#########
#temp.data.parasite <- fread(paste(result.file.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""), header = TRUE)
#temp.data.parasite[, Virulence := virulence]
#temp.data.parasite[, Popsize := host.populations[1]]
#temp.data.parasite[, Random.Drift := random.drift]
#temp.data.parasite[, Parasite.Connection := parasite.migration]
#temp.data.parasite[, Host.Connection := host.migration]
#temp.data.parasite[, Parasite.Time := Time]

#temp.data.parasite[, Parasite.Number.Individuals := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Population, Parasite.Infection.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.parasite[, Parasite.Population.Size := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.parasite[, Parasite.Number.Individuals.Between := .N, by = list(Parasite.Time, Parasite.Replicate, Parasite.Infection.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.parasite[, Parasite.Population.Size.Between := .N, by = list(Parasite.Time, Parasite.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]

#########
#temp.data.host[, Total.Parasite.Number.Individuals := Epidemic.Size.Within + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1] & Parasite.Infection.Genotype == Immune.Genotype[1], .N], by = list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Total.Parasite.Population.Size := Epidemic.Size.Total + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1], .N], by = list(Host.Time, Host.Replicate, Host.Population, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Total.Parasite.Number.Individuals.Between := Epidemic.Size.Within + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1] & Parasite.Infection.Genotype == Immune.Genotype[1], .N], by = list(Host.Time, Host.Replicate, Immune.Genotype, Virulence, Popsize, Parasite.Connection, Host.Connection)]
#temp.data.host[, Total.Parasite.Population.Size.Between := Epidemic.Size.Total + temp.data.parasite[Parasite.Replicate == Host.Replicate[1] & Parasite.Population == Host.Population[1] & Parasite.Time == Host.Time[1], .N], by = list(Host.Time, Host.Replicate, Virulence, Popsize, Parasite.Connection, Host.Connection)]

#########
#temp.data.host.small <- unique(temp.data.host[, list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Host.Number.Individuals, Host.Population.Size, Host.Number.Individuals.Between, Host.Population.Size.Between, Epidemic.Size.Within, Epidemic.Size.Total,
#                                                     Total.Parasite.Number.Individuals, Total.Parasite.Population.Size, Total.Parasite.Number.Individuals.Between, Total.Parasite.Population.Size.Between, Origin)])
#temp.data.parasite.small <- unique(temp.data.parasite[, list(Parasite.Time, Parasite.Replicate, Parasite.Population, Parasite.Infection.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Parasite.Number.Individuals, Parasite.Population.Size, Parasite.Number.Individuals.Between, Parasite.Population.Size.Between)])

#fwrite(temp.data.host.small, file = paste(final.result.location, result.file.name, "_Host_", run.date, ".csv", sep = ""))
#fwrite(temp.data.parasite.small, file = paste(final.result.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""))

#############################################
# As this is the version of the script that is supposed to run on the euler cluster
# we need to move the file from the scratch to the final location
#file.copy(from = paste(result.file.location, result.file.name, "_Host_", run.date, ".csv", sep = ""), 
#          to = paste(final.result.location, result.file.name, "_Host_", run.date, ".csv", sep = ""))

#file.copy(from = paste(result.file.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""), 
#          to = paste(final.result.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""))
