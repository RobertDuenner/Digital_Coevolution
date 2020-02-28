########################################################
### Main Body of the Digital_Coevolution simulation ####
########################################################

## You shouldn't be here! 
## Warning: Only change stuff in here if you know what you are doing...

######################################################################################################################################
## Here I create the data.tables that contain each individual of the simulation. Each row is one individual, each column one trait. 
######################################################################################################################################

###################################################################### 
# In this step I preallocate all the data.table space that I could be using in an attempt to speed up the simulation. 
individual.creator.function <- function(){  
  
  preallocation.margin <- 10 # How many times larger is the maximum calculatable population size #15
  parasite.margin <- 1
  preallocation.length <- sum(starting.population.sizes.host * replicates * preallocation.margin)
  preallocation.parasite <- sum(starting.population.sizes.parasite * replicates * preallocation.margin * parasite.margin)
  
  if(exists("Host")) {
    rm(Host, pos = ".GlobalEnv")
  }
  Host <<- data.table(  
    Alive = integer(preallocation.length),
    Host.Replicate = integer(preallocation.length), 
    Time = integer(preallocation.length),
    Host.Population = integer(preallocation.length),
    Host.Infection.Genotype = factor(NA, levels = c(1 : parasite.genotypes)),
    Age = integer(preallocation.length),
    Resource.Have = numeric(preallocation.length),
    Reproduction.Allocation = numeric(preallocation.length),
    Immune.Allocation = numeric(preallocation.length),
    Immune.Genotype = factor(sample(c(1 : host.genotypes),size = preallocation.length,prob = rep(1 / host.genotypes,host.genotypes), replace = T), levels = c(1 : host.genotypes)),
    Resource.In = numeric(preallocation.length),
    Resource.Work = numeric(preallocation.length),
    Reproduction.Have = numeric(preallocation.length),
    Immune.State = numeric(preallocation.length),
    Infection.State = integer(preallocation.length),
    Infection.Size = numeric(preallocation.length),
    Parasite.Resources = numeric(preallocation.length),
    Host.TempID = integer(preallocation.length),
    Size = numeric(preallocation.length),
    Host.Generation = integer(preallocation.length),
    Origin = integer(preallocation.length)
  )
  
  ### Here I initialize the starter populations
  # Replicate, this way I hope to paralellize the replicate calculations
  Host[, Host.Replicate := c(rep(1 : replicates, each = sum(starting.population.sizes.host)), integer(preallocation.length - sum(starting.population.sizes.host) * replicates))]
  # Alive variable, 1 = alive, 0 = not alive
  Host[Host.Replicate != 0, Alive := 1L] 
  # Population
  Host[Alive == 1, Host.Population := as.integer(rep(1 : number.populations.host, times = starting.population.sizes.host)), by = Host.Replicate]
  # Age
  Host[Alive == 1, Age := 1L]
  # Resource.Have
  Host[Alive == 1, Resource.Have := 1]
  # Resource.In, meaning that the starters start with a full belly
  Host[Alive == 1, Resource.In := 1]
  # Reproduction.Allocation
  Host[Alive == 1, Reproduction.Allocation := reproduction.allocation]
  # Immune.Allocation
  Host[Alive == 1, Immune.Allocation := immune.allocation]  
  # Immune.Genotype, has been set when initializing, needs to be cleaned
  Host[Alive == !1, Immune.Genotype := NA] 
  # Infection.Genote
  Host[, Host.Infection.Genotype := NA]
  # Size
  Host[Alive == 1, Size := 1]
  # Host.Generation
  Host[Alive == 1, Host.Generation := 1L]
  # Origin
  Host[Alive == 1, Origin := Host.Population]
  
  # Here I start a vector that just contains if a host is alive or not, to circumvent all the lookups
  if(exists("Alive.Host")) {
    rm(Alive.Host, pos = ".GlobalEnv")
  }
  Alive.Hosts <<- data.table(Is.Alive = Host[, Alive == 1])
  
  # Here I initialize the parasite data.table structure
  if(exists("Parasite")) {
    rm(Parasite, pos = ".GlobalEnv")
  }
  Parasite <<- data.table(
    Alive = integer(preallocation.parasite),
    Parasite.Replicate = integer(preallocation.parasite), 
    Time = integer(preallocation.parasite),
    Parasite.Population = integer(preallocation.parasite),
    Parasite.Infection.Genotype = factor(sample(c(1 : parasite.genotypes), size = preallocation.parasite, prob = rep(1 / parasite.genotypes, parasite.genotypes), replace = T), levels = c(1 : parasite.genotypes)),
    Attack.Host.TempID = integer(preallocation.parasite),
    Attack.Host.Genotype = integer(preallocation.parasite),
    Success.Parasite.Infection.Genotype = factor(NA, levels = c(1 : parasite.genotypes)),
    Ingested = integer(preallocation.parasite),
    Age = integer(preallocation.parasite)
  )
  
  # Here I initialize the starter populations for the parasite
  # Replicate
  Parasite[, Parasite.Replicate := c(rep(1 : replicates, each = sum(starting.population.sizes.parasite)), integer(preallocation.parasite - sum(starting.population.sizes.parasite) * replicates))]
  # Alive variable, 1 = alive, 0 = not alive
  Parasite[Parasite.Replicate != 0, Alive := 1L]
  # Population
  Parasite[Alive == 1, Parasite.Population := as.integer(rep(1 : number.populations.parasite, times = starting.population.sizes.parasite)), by = Parasite.Replicate]
  # Age 
  Parasite[Alive == 1, Age := 1L]
  # Infection.Genotype, has been set when initializing, needs to be cleaned
  Parasite[Alive != 1, Parasite.Infection.Genotype := NA]
  # Atack.Host.Rownumber
  Parasite[, Attack.Host.TempID := NA]
  # Atack.Host.Genotype
  Parasite[, Attack.Host.Genotype := NA]
  
  # Here I start a vector that just contains if a Parasite is alive or not, to circumvent all the lookups
  if(exists("Alive.Parasite")) {
    rm(Alive.Parasite, pos = ".GlobalEnv")
  }
  Alive.Parasites <<- data.table(Is.Alive = Parasite[, Alive == 1], Is.Ingested = FALSE)
}

######################################################################################################################################
## Here I define the dynamics that make up each individual of the simulation. Each of these functions will be carried out once per tick
######################################################################################################################################

######################################################################################################################################
#### Time marker, counts the number of time steps that the simulation has been though # time.function
time.function <- function() {
  Host[, Time := Time + 1L]
  Parasite[, Time := Time + 1L]
}
######################################################################################################################################
# Ageing functions. this function adds one age to each individuals age spot, and then kills of the individuals that are to old.#senescence.function
senescence.function <- function() {
  # additional drift parameter
  Host[Alive.Hosts$Is.Alive, Alive := rbinom(n = .N, size = 1, prob = (1 - random.drift))]
  Parasite[Alive.Parasites$Is.Alive, Alive := rbinom(n = .N, size = 1, prob = (1 - random.drift))]
    
  # senescence
  Host[Alive.Hosts$Is.Alive, Age := Age + 1L]
  Host[Alive.Hosts$Is.Alive & Age > age.threshold.host, Alive := 0L]
  Parasite[Alive.Parasites$Is.Alive, Age := Age + 1L]
  Parasite[Alive.Parasites$Is.Alive & Age > age.threshold.parasite, Alive := 0L]

  # updating the host and parasite alive vectors
  set(Alive.Hosts, j = "Is.Alive", value = Host[, Alive == 1])
  #Alive.Hosts[, Is.Alive := Host[, Alive == 1]]
  set(Alive.Parasites, j = "Is.Alive", value = Parasite[, Alive == 1])
  #Alive.Parasites[, Is.Alive := Parasite[, Alive == 1]]
}


######################################################################################################################################
# Resource functions
# .ext.resource moves the resource capital from one container to the next. It moves whatever is left in the working container to the storage, then drains the working container.
# then it truncates the storage container. It then moves the resources form the income container to the working container and drains the income container.  #host.ext.resource.function
host.resource.function <- function(){
  Host[Alive.Hosts$Is.Alive, Resource.Have := Resource.Have + Resource.Work]
  
  # I will make the resource.have threshhold, so basically the fat content, size dependant. As larger individuals should be able to proportionally store more fat, a qubic increase instead of a linear increase with size migth be applicable.
  Host[Alive.Hosts$Is.Alive, Resource.Have := pmin(Resource.Have, (Size ^ 2))]
  
  # Then the resource.work (metabolic resource) gets filled by the resource.in container of the last timestep, creating a delay between feeding and availability of energy
  # This part lets hosts that get less external resources use some stored resources to fill resource.work #host.int.resource.function
  Host[Alive.Hosts$Is.Alive, Resource.Work := Resource.In + pmin((round(Size) - Resource.In), Resource.Have)]
  Host[Alive.Hosts$Is.Alive, Resource.Have := Resource.Have - pmin((round(Size) - Resource.In), Resource.Have)]
  
  # This part removes individuals that have run out of resources (starving). Works on Resource.Work, with the logic that it should check metabolic energy availability which shouldn't drop too low.
  Host[Alive.Hosts$Is.Alive & Resource.Work < resource.threshold.host, Alive := 0]
  
  # This part updates the Alive.Hosts$Is.Alive vector
  #setorder(Host, -Alive)
  set(Alive.Hosts, j = "Is.Alive", value = Host[, Alive == 1])
  #Alive.Hosts[, Is.Alive := Host[, Alive == 1]]
  
  #Now I need to clean up the host data table, so that the rows of the epmty individuals become clean and available again.
  #Host[!Alive.Hosts$Is.Alive, c("Host.Replicate", "Host.Population", "Age", "Resource.Have", "Reproduction.Allocation", "Immune.Allocation", "Resource.In", "Resource.Work", "Reproduction.Have", "Immune.State", "Infection.State", "Infection.Size", "Parasite.Resources", "Size", "Host.Generation", "Parasite.Generation", "Origin") := 0]
  #Host[!Alive.Hosts$Is.Alive, c("Infection.Genotype", "Immune.Genotype", "Host.TempID") := NA]
  
  # This part takes all the available resources, and redistributes them according to host size. It adjusts the resources by relative filtering capacity if the population gets less than maximal food
  Host[Alive.Hosts$Is.Alive, Resource.In := (rpois(n = .N, lambda = (Size * min(1, (resources.host[Host.Population[1]] / sum(Size)))) * resource.grain) / resource.grain), by = list(Host.Population, Host.Replicate)]
  
  # This part restricts resource in to Size + 10% in order to avoid unrealistic overfeeding
  Host[Alive.Hosts$Is.Alive, Resource.In := pmin(Resource.In, (Size * 1.1))]
}

#####################################################################################################################################
# Infection.function.host; Here the infection grows and then withdraws resources from the host
infection.function <- function(){ 
  # First the infection matures
  Host[Alive.Hosts$Is.Alive, Infection.Size := Infection.Size * infection.growth.factor]
  Host[Alive.Hosts$Is.Alive, Infection.Size := pmin(Infection.Size, Size)]
  
  # Then the parasite draws resources, dependant on infection size
  Host[Alive.Hosts$Is.Alive, Parasite.Resources := Parasite.Resources + pmin(Resource.Work, Infection.Size * virulence)]
  Host[Alive.Hosts$Is.Alive, Resource.Work := Resource.Work - pmin(Resource.Work, Infection.Size * virulence)]
}

#####################################################################################################################################  
# Reproduction function parasite
parasite.reproduction.function <- function () {
  reproducing.parasites <- Host[,rep(.I[Alive.Hosts$Is.Alive & Parasite.Resources > reproduction.threshold.parasite], times = round(Host[Alive.Hosts$Is.Alive & Parasite.Resources > reproduction.threshold.parasite, Parasite.Resources] - reproduction.threshold.parasite) * reproduction.factor.parasite)]
  
  if (Host[reproducing.parasites, .N] > 0) {
    #################  This part selects the "dead" rows in the parasite data.table, then calcualtes how many offsping are produced, and updates the values from the corresponding host data.table
    Parasite[Parasite[, .I[!Alive.Parasites$Is.Alive][seq(Host[reproducing.parasites, .N])]],
             `:=` (Alive = 1L, Parasite.Replicate = Host[reproducing.parasites, Host.Replicate], Parasite.Population = Host[reproducing.parasites, Host.Population], Parasite.Infection.Genotype = Host[reproducing.parasites, Host.Infection.Genotype], Attack.Host.TempID = NA, Attack.Host.Genotype = NA, Success.Parasite.Infection.Genotype = NA, Ingested = 0, Age = 1L)
             #c("Alive", "Parasite.Replicate", "Parasite.Population", "Infection.Genotype", "Generation", "Age", "Attack.Host.TempID", "Attack.Host.Genotype", "Success.Parasite.Infection.Genotype", "Ingested") := c(Host[reproducing.parasites, list(Alive, Host.Replicate, Host.Population, Infection.Genotype, Generation)], list(Age = 1, Attack.Host.TempID = NA, Attack.Host.Genotype = NA, Success.Parasite.Infection.Genotype = NA, Ingested = 0))
             ]
    Host[Alive.Hosts$Is.Alive & Parasite.Resources > reproduction.threshold.parasite, Parasite.Resources := Parasite.Resources - (round(Parasite.Resources) - reproduction.threshold.parasite)]
    
    # Uptdate parasite alive vector
    set(Alive.Parasites, j = "Is.Alive", value = Parasite[, Alive == 1])
    #Alive.Parasites[, Is.Alive := Parasite[, Alive == 1]]
  } 
}

######################################################################################################################################
## exposure.function; here the parasite infects new hosts #exposure.function 
host.exposure.function <- function(){
  #This part sets an identifier to be used later on
  Host[Alive.Hosts$Is.Alive, Host.TempID := 1 : .N]
  Host[! Alive.Hosts$Is.Alive, Host.TempID := NA]
  
  set(Parasite, j = "Ingested", value = 0)
  set(Parasite, j = "Attack.Host.TempID", value = NA)
  set(Parasite, j = "Attack.Host.Genotype", value = NA)
  set(Parasite, j = "Success.Parasite.Infection.Genotype", value = NA)
  
  # This part removes the identifier from those hosts that already are infected, creating a vaccination effect
  Host[Alive.Hosts$Is.Alive & Infection.State == 1, Host.TempID := NA]
  
  # This part does assign to each parasite score if it has been ingested by a host, dependant on resource availability, host and parasite population size
  ##########
  Parasite[Alive.Parasites$Is.Alive, 
           Ingested := rbinom(n = .N, size = 1, prob = min(1, (sum(Host[Alive.Hosts$Is.Alive & Host.Population == Parasite.Population[1] & Host.Replicate == Parasite.Replicate[1], Size]) / resources.host[Parasite.Population[1]]))),
           by = list(Parasite.Population, Parasite.Replicate)]
  
  # Updating the Alive.Parasites$Is.Ingested vector for faster lookups
  Alive.Parasites[Alive.Parasites$Is.Alive, Is.Ingested := Parasite[Alive.Parasites$Is.Alive, Ingested == 1]]
  
  # This part does assign to each parasite spore the host tempID it has been ingested by #Parasite[Alive.Parasites$Is.Alive & Alive.Parasites$Is.Ingested
  Parasite[Alive.Parasites$Is.Ingested,
           Attack.Host.TempID := 
             base:::sample(x = Host[Alive.Hosts$Is.Alive & Host.Population == Parasite.Population[1] & Host.Replicate == Parasite.Replicate[1], Host.TempID], 
                           size = .N, 
                           replace = TRUE, 
                           prob = c(
                             Host[Alive.Hosts$Is.Alive & Host.Population == Parasite.Population[1] & Host.Replicate == Parasite.Replicate[1], Size] * 
                               (.N / resources.host[Parasite.Population[1]]) * 
                               min(1, resources.host[Parasite.Population[1]] / 
                                     sum(Host[Alive.Hosts$Is.Alive & Host.Population == Parasite.Population[1] & Host.Replicate == Parasite.Replicate[1], Size]))
                           )
             ), 
           by = list(Parasite.Population, Parasite.Replicate)]
  
  # This part does assign to each parasite the host genotype it has been ingested by 
  Parasite[Alive.Parasites$Is.Ingested, Attack.Host.Genotype := Host[Alive.Hosts$Is.Alive][Attack.Host.TempID, Immune.Genotype]]
  
  # This part calculated which parasite successfully infects, takes into account the relative abundance of ingested parasite spores and their genetic specificity
  Parasite[Alive.Parasites$Is.Ingested & ! is.na(Attack.Host.TempID), Success.Parasite.Infection.Genotype := sample(c(NA, Parasite.Infection.Genotype), size = 1, prob = c(1,infection.table[Attack.Host.Genotype[1], Parasite.Infection.Genotype]), replace = TRUE), by = list(Attack.Host.TempID, Parasite.Population, Parasite.Replicate)]
  
  # And the last thing to do would be to assign the infection genotype back to the host
  #setorder(Parasite, - Alive, Attack.Host.TempID, na.last = TRUE)
  infected.hosts <- unique(Parasite[Alive.Parasites$Is.Ingested & ! is.na(Success.Parasite.Infection.Genotype)], by = "Attack.Host.TempID")$Attack.Host.TempID
  infected.hosts.infection.genotypes <- unique(Parasite[Alive.Parasites$Is.Ingested & ! is.na(Success.Parasite.Infection.Genotype)], by = "Attack.Host.TempID")$Success.Parasite.Infection.Genotype
  Host[Host[, .I[Alive.Hosts$Is.Alive]][infected.hosts],
       Host.Infection.Genotype := infected.hosts.infection.genotypes
       ]
  #Host[Host.TempID %in% infected.hosts, Host.Infection.Genotype := infected.hosts.infection.genotypes] 
  
  # And the very last thing is to update the infection status of the host that got assigned a infection.genotype
  Host[Alive.Hosts$Is.Alive & ! is.na(Host.Infection.Genotype) & Infection.State == 0, c("Infection.Size", "Infection.State") := 1]
  
  # And kill the parasites that have been ingested
  Parasite[Alive.Parasites$Is.Ingested, Alive := 0]
  
  # Update the parasite alive vector
  # setorder(Parasite, -Alive)
  set(Alive.Parasites, j = "Is.Alive", value = Parasite[, Alive == 1])
  #Alive.Parasites[, Is.Alive := Parasite[, Alive == 1]]
  
  # Update the Alive.Paraistes$Is.Ingested vector
  set(Alive.Parasites, j = "Is.Ingested", value = FALSE)
  
}

#####################################################################################################################################
# metabol.funtion drains the resource.work container and moves the resources to the life history funcitons, like reproduction and immune function #host.metabol.function
metabolism.function <- function(){
  Host[Alive.Hosts$Is.Alive, Immune.State := pmin(Immune.Allocation * Size, Resource.Work)] # this part drains resource.work and assigns to immune.state, refreshes every round, so no immune buildup
  Host[Alive.Hosts$Is.Alive, Resource.Work := Resource.Work - pmin(Immune.Allocation * Size, Resource.Work)]
  
  Host[Alive.Hosts$Is.Alive, Reproduction.Have := Reproduction.Have + (pmin(Reproduction.Allocation * Size, Resource.Work) * (1 - (2 / Age)))]
  # this part drains resource.work and moves to reproduction have, cummultative 
  # Depending on the age of the host, resources are funneled more towards reproduction or more towards growth
  if(host.size == "ON"){
    Host[Alive.Hosts$Is.Alive, Size := Size + (pmin(Reproduction.Allocation * Size, Resource.Work) * (2 / Age))]
  }
  Host[Alive.Hosts$Is.Alive, Resource.Work := Resource.Work - pmin(Reproduction.Allocation * Size, Resource.Work)]
}

######################################################################################################################################
# Reproduction function #host.reproduction.function
host.reproduction.function <- function(){
  # Looks complicated, does first chose the current overall population size, sets the reproduction lenght and then updates the respective columns.
  # It Calculates the position of all hosts with enough resources to reproduce, the repeats those positions for the number of times defined by the resources of each.
  # Of this it calculates the length to set the reproduction length. Then it choses the same subset of the host population and mirrors it down in the dataframe into the precalculated empty positions.
  reproducing.hosts <- Host[, rep(.I[Alive.Hosts$Is.Alive & Reproduction.Have > reproduction.threshold.host], times = round(Host[Alive.Hosts$Is.Alive & Reproduction.Have > reproduction.threshold.host,Reproduction.Have] - reproduction.threshold.host) * reproduction.factor.host)]
  
  if (Host[reproducing.hosts, .N] > 0) {
    
    ###############
    Host[Host[, .I[!Alive.Hosts$Is.Alive][seq(Host[reproducing.hosts, .N])]],
         `:=` (Alive = 1L, Host.Replicate = Host[reproducing.hosts, Host.Replicate], Host.Population = Host[reproducing.hosts, Host.Population], Host.Infection.Genotype = NA, Age = 1, Resource.Have = 1, Reproduction.Allocation = Host[reproducing.hosts, Reproduction.Allocation], Immune.Allocation = Host[reproducing.hosts, Immune.Allocation], Immune.Genotype = Host[reproducing.hosts, Immune.Genotype], Resource.In = 1, Resource.Work = 0, Reproduction.Have = 0, Immune.State = Host[reproducing.hosts, Immune.State], Infection.State = 0L, Infection.Size = 0, Parasite.Resources = 0, Host.TempID = NA, Size = 1, Host.Generation = (Host[reproducing.hosts, Host.Generation] + 1L), Origin = Host[reproducing.hosts, Host.Population])
         #c("Alive","Host.Replicate","Host.Population","Reproduction.Allocation","Immune.Allocation","Immune.Genotype", "Immune.State", "Age", "Resource.Have", "Resource.In", "Size", "Resource.Work", "Reproduction.Have", "Origin", "Host.Generation", "Parasite.Generation") := c(Host[reproducing.hosts, list(Alive, Host.Replicate, Host.Population, Reproduction.Allocation, Immune.Allocation, Immune.Genotype, Immune.State)], list(Age = 1, Resource.Have = 1, Resource.In = 1, Size = 1, Resource.Work = 0, Reproduction.Have = 0), list(Origin = Host[reproducing.hosts, Host.Population],  Host.Generation = (Host[reproducing.hosts, Host.Generation] + 1L), Parasite.Generation = 0))
         ]
    ##############
    Host[Alive.Hosts$Is.Alive & Reproduction.Have > reproduction.threshold.host, Reproduction.Have := Reproduction.Have - (round(Reproduction.Have) - reproduction.threshold.host)]
  
    # Uptdate the Alive.Hosts$Is.Alive vector
    set(Alive.Hosts, j = "Is.Alive", value = Host[, Alive == 1])
    #Alive.Hosts[, Is.Alive := Host[, Alive == 1]]
    }
}

######################################################################################################################################
# Migration.functions 1
#####################################
## Parasite migration function  #parasite.migration.function
parasite.migration.function <- function(){
  Parasite[Alive.Parasites$Is.Alive, 
           Parasite.Population := base:::sample(1 : number.populations.parasite, 
                                                size = .N, 
                                                prob = migration.matrix.parasite[Parasite.Population[1], ], 
                                                replace = TRUE), 
           by = list(Parasite.Population, Parasite.Replicate)]
}
### Maybe this part of the simulation needs to be updated. Currently this will cause problems with uneven population sizes
### Something that takes the existing population vector and shuffles it around maybe. something that takes the indicated fraction of 
### the population, pools it into the global parasite population, and backdistributes it. 
### That way the relative population sizes are maintained.
# 
######################################################################################################################################
# Migration.functions 2
## Host migration function #host.migration.function
host.migration.function <- function(){
  Host[Alive.Hosts$Is.Alive, 
       Host.Population := base:::sample(1 : number.populations.host, 
                                        size = .N, 
                                        prob = migration.matrix.host[Host.Population[1], ], 
                                        replace = TRUE),
       by = list(Host.Population, Host.Replicate)]
} 

######################################################################################################################################
# Here I will combine all the functions defined above into one wrapper function to be called. One call is one timestep. The order of the function can have an influence on the dynamics of the thing
dynamics.wrapper <- function(){
  time.function()
  senescence.function()
  host.resource.function()
  infection.function()
  host.exposure.function()
  parasite.reproduction.function()
  metabolism.function()
  host.reproduction.function()
  host.migration.function()
  parasite.migration.function()
  # result saving 
  if(i %in% c(1, seq(from = saving.intervall, to = duration.days, by = saving.intervall))){
    fwrite(Host[Alive.Hosts$Is.Alive], file = 
             paste(result.file.location, result.file.name, "_Host_", run.date, ".csv", sep = ""), append = TRUE)
    fwrite(Parasite[Alive.Parasites$Is.Alive], file = 
             paste(result.file.location, result.file.name, "_Parasite_", run.date, ".csv", sep = ""), append = TRUE)    
  }
}
