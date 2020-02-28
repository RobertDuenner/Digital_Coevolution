##################################################################
### Helper script for the Digital_Coevolution simulation ####
##################################################################

## You shouldn't be here! 
## Warning: Only change stuff in here if you know what you are doing...

###########################################################
## This script simply coordinates the running of the 
## Digital_Coevolution simulation, and takes those
## Steps out of the frontend script that most users
## will interact with. 

# Load data.table library
library(data.table)

# Source the parameterfile.
source(file =  paste(source.file.location, "Digital_Coevolution_Parameterspace.R", sep = ""), local = TRUE)

# Save a copy of the created parameters
saveRDS(as.list(.GlobalEnv),file = 
          paste(result.file.location, "Digital_Coevolution_Parameters","_", run.date, "_", result.file.name, ".RDS", sep = ""))

# Source the main body of the simulation that includes all dynamics functions
source(file =  paste(source.file.location, "Digital_Coevolution_Dynamics_Functions.R", sep = ""), local = TRUE)

######################################################################################################################################
### Now we run the simulation
# As a first step we need to create the individuals that are the core of this individual based simulation.
# We do that by calling the individual.creator.function that was sourced in the Main_Body_Digital_Coevolution.R
individual.creator.function() # That's it

# Because it is a time forward simulation it is necessary to loop through the timesteps. We do that by calling the dynamics.wrapper function within a loop. 
# The dynamics.wrapper contains all the functions that guide the dynamics of the individuals in each timestep (as for example the host.reproduction.function).
for(i in 1 : duration.days){
  dynamics.wrapper()
}

##############################################################################
### Post processing
# Loading the accumulated dataset, calculate some summary statistics and metrics, get rid of duplicate entries, and save a smaller dataset. This saves time and discspace.
library(data.table)
temp.data.host <- fread(paste(result.file.location, result.file.name, "_Host_", run.date, ".csv", sep = ""), header = TRUE)
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
temp.data.parasite <- fread(paste(result.file.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""), header = TRUE)
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
temp.data.host.small <- unique(temp.data.host[, list(Host.Time, Host.Replicate, Host.Population, Immune.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Host.Number.Individuals, Host.Population.Size, Host.Number.Individuals.Between, Host.Population.Size.Between, Epidemic.Size.Within, Epidemic.Size.Total,
                                                     Total.Parasite.Number.Individuals, Total.Parasite.Population.Size, Total.Parasite.Number.Individuals.Between, Total.Parasite.Population.Size.Between, Origin)])
temp.data.parasite.small <- unique(temp.data.parasite[, list(Parasite.Time, Parasite.Replicate, Parasite.Population, Parasite.Infection.Genotype, Virulence, Popsize, Random.Drift, Parasite.Connection, Host.Connection, Parasite.Number.Individuals, Parasite.Population.Size, Parasite.Number.Individuals.Between, Parasite.Population.Size.Between)])

fwrite(temp.data.host.small, file = paste(result.file.location, result.file.name, "_Host_", run.date, ".csv", sep = ""))
fwrite(temp.data.parasite.small, file = paste(result.file.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""))
