library(zipcode)
library(dplyr)
library(plyr)
library(ggplot2)
library(maptools)
gpclibPermit()
library(mapdata)
library(ggthemes)
library(tibble)
library(viridis)
library(mapproj)

names(AmbassadorMaster)[names(AmbassadorMaster)=="Ship To Zip Code"] <- "Zipcode"

AmbassadorMaster$Zipcode <- clean.zipcodes(AmbassadorMaster$Zipcode)

us <- map_data("state")

zips$ZipCodeType <- NULL
zips$City <- NULL
zips$State <- NULL
zips$LocationType <- NULL
zips$Location <- NULL
zips$Decommisioned <- NULL
zips$TaxReturnsFiled <- NULL
zips$EstimatedPopulation <- NULL
zips$TotalWages <- NULL

AmbassadorMaster <- merge(AmbassadorMaster, zips, by = "Zipcode")

##Bring in radius file 
##from https://www.freemaptools.com/find-zip-codes-inside-radius.htm
PhillyRadius60 <- read_csv("C:/Users/bronars.DCIM/Desktop/Ambassador Radius/PhillyRadius60.csv")
PhillyRadius60$Zipcode <- clean.zipcodes(PhillyRadius60$Zipcode)

##Match
AmbassadorMaster$Philly_60 <- {match(AmbassadorMaster$Zipcode, PhillyRadius60$Zipcode, nomatch = 0)
  AmbassadorMaster$Zipcode %in% PhillyRadius60$Zipcode}

Philly60.Ambassadors <- subset(AmbassadorMaster, Philly_60 == "TRUE",)

##export list
write.csv(Philly60.Ambassadors, file = "Philly_60mile.csv", append = FALSE)

###ggplot
names(Philly60.Ambassadors)[names(Philly60.Ambassadors)=="Lat"] <- "lat"
names(Philly60.Ambassadors)[names(Philly60.Ambassadors)=="Long"] <- "long"

gg <- ggplot()
gg <- gg + geom_map(data=us, map=us,
                    aes(x=long, y=lat, map_id=region),
                    color="#2b2b2b", fill="#eff098", size=0.15)
gg <- gg + geom_point(data=Philly60.Ambassadors,
                      aes(x=long, y=lat, map_id=Zipcode),
                      shape=21, color="#2b2b2b", fill="#ff1438", size=1)
gg <- gg + coord_map("polyconic")
gg <- gg + theme_map()
gg <- gg + theme(plot.margin=margin(20,20,20,20))
gg <- gg + scale
gg
