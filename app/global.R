packages.used <- c("shiny","leaflet","ggplot2","tidyr","tibble","tidyverse","shinythemes",
                   "shinydashboard","sf","jsonlite","gganimate","magick","plotly","dplyr","numDeriv")

# check packages that need to be installed.
packages.needed <- setdiff(packages.used, 
                           intersect(installed.packages()[,1], 
                                     packages.used))

# install additional packages
if(length(packages.needed) > 0){
  install.packages(packages.needed, dependencies = TRUE)
}

library(shiny)
library(leaflet)
library(ggplot2)
library(tidyr)
library(tibble)
library(tidyverse)
library(shinythemes)
library(shinydashboard)
library(sf)
library(jsonlite)
library(gganimate)
library(magick)
library(plotly)
library(dplyr)
library(numDeriv)

## NYC Outdoor Activity Data ###################################

# convert json files to dataframes
iceskating <- read_json("output/iceskating.json", simplifyVector = TRUE)
iceskating <- as.data.frame(iceskating)

basketball <- read_json("output/basketball.json", simplifyVector = TRUE)
basketball <- as.data.frame(basketball)

cricket <- read_json("output/cricket.json", simplifyVector = TRUE)
cricket <- as.data.frame(cricket)

handball <- read_json("output/handball.json", simplifyVector = TRUE)
handball <- as.data.frame(handball)

runningTrack <- read_json("output/runningTrack.json", simplifyVector = TRUE)
runningTrack <- as.data.frame(runningTrack)

# data cleaning
iceskating <- iceskating %>%
  mutate(category = rep("iceskating", nrow(iceskating))) %>%
  select(category, Name, Location, lat, lon, Accessible, Phone, IceSkating_Type) %>%
  filter(!is.na(lat) & !is.na(lon))
iceskating[iceskating$Name == "Abe Stark Rink",]$Location <- "Coney Island Boardwalk and West 19th Street"
iceskating$Accessible[iceskating$Accessible=="Y"] <- "OPEN"
iceskating$Accessible[iceskating$Accessible=="N"] <- "CLOSED"

basketball <- basketball %>%
  mutate(category = rep("basketball", nrow(basketball))) %>%
  select(category, Name, Location, lat, lon, Accessible) %>%
  filter(!is.na(lat) & !is.na(lon) & !is.na(Accessible))
basketball$Accessible[basketball$Accessible=="Y"] <- "OPEN"
basketball$Accessible[basketball$Accessible=="N"] <- "CLOSED"

cricket <- cricket %>%
  mutate(category = rep("cricket", nrow(cricket))) %>%
  select(category, Name, Location, lat, lon, Num_of_Fields) %>%
  filter(!is.na(lat) & !is.na(lon))
#cricket$Accessible[cricket$Accessible=="Y"] <- "OPEN"
#cricket$Accessible[cricket$Accessible=="N"] <- "CLOSED"

handball <- handball %>%
  mutate(category = rep("handball", nrow(handball))) %>%
  select(category,Name, Location, lat, lon, Num_of_Courts) %>%
  filter(!is.na(lat) & !is.na(lon))
#handball$Accessible[handball$Accessible=="Y"] <- "OPEN"
#handball$Accessible[handball$Accessible=="N"] <- "CLOSED"

runningTrack <- runningTrack %>%
  mutate(category = rep("runningTrack", nrow(runningTrack))) %>%
  select(category, Name, Location, lat, lon, Size, RunningTracks_Type) %>%
  filter(!is.na(lat) & !is.na(lon))
#runningTrack$Accessible[runningTrack$Accessible=="Y"] <- "OPEN"
#runningTrack$Accessible[runningTrack$Accessible=="N"] <- "CLOSED"

data <- full_join(iceskating,basketball,by=c("category","Name","Location","lat","lon","Accessible"))
data <- full_join(data,cricket,by=c("category","Name","Location","lat","lon"))
data <- full_join(data,handball,by=c("category","Name","Location","lat","lon"))
data <- full_join(data,runningTrack,by=c("category","Name","Location","lat","lon"))
write.csv(data,"activity_dataset.csv")

df.activity <- read.csv("activity_dataset.csv")
df.activity$category <- as.factor(df.activity$category)


## Covid Confirmed Cases Data for map ###################################

zip_code_database <- read.csv("output/zip_code_database.csv")
last7days.by.modzcta <-read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/last7days-by-modzcta.csv")
names(last7days.by.modzcta)[names(last7days.by.modzcta)=="modzcta"]<-"zip"
data <- left_join(last7days.by.modzcta, zip_code_database, by="zip")
write.csv(data,"output/casebyzipcode.csv")

data2 <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/data-by-modzcta.csv")
#zipcode <- read.csv("zipcode.csv")
load("output/geo_data.RData")


## case plot data ###################################
#Get the raw data about the active case rate by zip code.
case_zipcode_url <- "https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/caserate-by-modzcta.csv"
case_zipcode <- read.csv(case_zipcode_url, header = TRUE, sep = ",", quote = "\"'")
case_zipcode <- case_zipcode%>%
  dplyr::rename(week = week_ending,#change variables to a more clear format.
                Citywide = CASERATE_CITY,
                Bronx = CASERATE_BX,
                Brooklyn = CASERATE_BK,
                Manhattan = CASERATE_MN,
                Queens = CASERATE_QN,
                `Staten Island` = CASERATE_SI)
for (i in 8:ncol(case_zipcode)){
  colnames(case_zipcode)[i] <-  sub(".*E_", "", colnames(case_zipcode)[i])#change the zip code to a more clear format
}
case_zipcode$week <- as.Date(case_zipcode$week,"%m/%d/%Y")

perp_zipcode_url <- "https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/percentpositive-by-modzcta.csv"
perp_zipcode <- read.csv(perp_zipcode_url, header = TRUE, sep = ",", quote = "\"'")
perp_zipcode <- perp_zipcode%>%
  dplyr::rename(week = week_ending,#change variables to a more clear format.
                Citywide = PCTPOS_CITY,
                Bronx = PCTPOS_BX,
                Brooklyn = PCTPOS_BK,
                Manhattan = PCTPOS_MN,
                Queens = PCTPOS_QN,
                `Staten Island` = PCTPOS_SI)
for (i in 8:ncol(perp_zipcode)){
  colnames(perp_zipcode)[i] <-  sub(".*S_", "", colnames(perp_zipcode)[i])#change the zip code to a more clear format
}
perp_zipcode$week <- as.Date(perp_zipcode$week,"%m/%d/%Y")

case_merged <- case_zipcode[1:2]
case_merged$zipcode <- colnames(case_zipcode)[2] #Convert column names to a single variable called zipcode.
colnames(case_merged)[2] <- "Case.rate"
for (i in 3:ncol(case_zipcode)){
  new <-  case_zipcode[c(1,i)]
  new$zipcode <- colnames(case_zipcode)[i]
  colnames(new)[2] <- "Case.rate"
  case_merged <- rbind(case_merged, new)
}
case_merged$Case.rate <- case_merged$Case.rate/1000 #change the rate from case per 100,000 to case percentage.


perp_merged <- perp_zipcode[1:2]
perp_merged$zipcode <- colnames(perp_zipcode)[2]
colnames(perp_merged)[2] <- "Positive.test.rate"#Convert column names to a single variable called zipcode.
for (i in 3:ncol(perp_zipcode)){
  new <-  perp_zipcode[c(1,i)]
  new$zipcode <- colnames(perp_zipcode)[i]
  colnames(new)[2] <- "Positive.test.rate"
  perp_merged <- rbind(perp_merged, new)
}

Positive.test.rate <- perp_merged$Positive.test.rate
cp_merged <- cbind(case_merged, Positive.test.rate)#merge the case rate data with the positive test rate data.
zipcode <- colnames(case_zipcode)[2:ncol(case_zipcode)]
ratetype <- c("Case.rate", "Positive.test.rate")

#assign each zip code to its borough.
Manhattan.zip <- c("Manhattan","10026", "10027", "10030", "10037", "10039","10001", "10011", "10018", "10019", "10020", "10036","10029", "10035", "10010", "10016", "10017", "10022","10012", "10013", "10014","10004", "10005", "10006", "10007", "10038", "10280","10002", "10003", "10009",	"10021", "10028", "10044", "10065", "10075", "10128","10023", "10024", "10025","10031", "10032", "10033", "10034", "10040")

Queens.zip <- c("Queens","11361", "11362", "11363", "11364",	"11354", "11355", "11356", "11357", "11358", "11359", "11360","11365", "11366", "11367","11412", "11423", "11432", "11433", "11434", "11435", "11436","11101", "11102", "11103", "11104", "11105", "11106","11374", "11375", "11379", "11385","11691", "11692", "11693", "11694", "11695", "11697", "11004", "11005", "11411", "11413", "11422", "11426", "11427", "11428", "11429","11414", "11415", "11416", "11417", "11418", "11419", "11420", "11421","11368", "11369", "11370", "11372", "11373", "11377", "11378")

Brooklyn.zip <- c("Brooklyn","11212", "11213", "11216", "11233", "11238","11209", "11214", "11228","11204", "11218", "11219", "11230","11234", "11236", "11239",	"11223", "11224", "11229", "11235","11201", "11205", "11215", "11217", "11231","11203", "11210", "11225", "11226",	"11207", "11208",	"11211", "11222",	"11220", "11232",	"11206", "11221", "11237")

Bronx.zip <- c(	"Bronx","10453", "10457", "10460","10458", "10467", "10468","10451", "10452", "10456",	"10454", "10455", "10459", "10474",	"10463", "10471","10466", "10469", "10470", "10475","10461", "10462","10464", "10465", "10472", "10473")

Staten.Island.zip <- c ("Staten Island","10302", "10303", "10310","10306", "10307", "10308", "10309", "10312","10301", "10304", "10305","10314")

Borough <- c("Manhattan", "Queens", "Bronx", "Brooklyn", "Staten Island")

#create a variable called borough to assign each zip code to its corresponding borough in the case rate data set.
cp_merged$Borough <- ifelse(cp_merged$zipcode %in% Manhattan.zip, "Manhattan", ifelse(cp_merged$zipcode %in% Queens.zip, "Queens", ifelse(cp_merged$zipcode %in% Brooklyn.zip, "Brooklyn", ifelse(cp_merged$zipcode %in% Bronx.zip, "Bronx", ifelse(cp_merged$zipcode %in% Staten.Island.zip, "Staten Island", "Citywide")))))

#get the raw data about daily cases in NYC.
cbd_url <- "https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/now-cases-by-day.csv"
cbd <- read.csv(cbd_url, header = TRUE, sep = ",", quote = "\"'")
cbd$date_of_interest <- as.Date(cbd$date_of_interest,"%m/%d/%Y")
cbd <- cbd%>%
  dplyr::rename(date = date_of_interest,
                Citywide = CASE_COUNT,
                Bronx = BX_CASE_COUNT,
                Brooklyn = BK_CASE_COUNT,
                Manhattan = MN_CASE_COUNT,
                Queens = QN_CASE_COUNT,
                `Staten Island` = SI_CASE_COUNT)%>%
  select(date,Citywide,Bronx,Brooklyn, Manhattan,Queens, `Staten Island`)

cbd_merged <- cbd[1:2]
cbd_merged$Borough <- colnames(cbd_merged)[2]#convert column names to a single column called Borough
colnames(cbd_merged)[2] <- "Case"
for (i in 3:ncol(cbd)){
  new <-  cbd[c(1,i)]
  new$Borough <- colnames(cbd)[i]
  colnames(new)[2] <- "Case"
  cbd_merged <- rbind(cbd_merged, new)
}

Borough_case <- c("Citywide","Manhattan", "Queens", "Bronx", "Brooklyn", "Staten Island")

# home page data cleaning
open = df.activity %>%
  filter(Accessible == "OPEN")

count_open = nrow(open)

closed = df.activity %>%
  filter(Accessible == "CLOSED")

count_closed = nrow(closed)
count_total = count_open + count_closed
count_na = nrow(df.activity) - count_total

#prediction function
source("../lib/trend.R")

#create predictions
predictions_perp <-  perp_zipcode[0,]
pred_vector = list(as.Date(perp_zipcode[nrow(perp_zipcode),1])+7)
for(i in names(perp_zipcode)){
  if(i=="week"){
    next
  }
  pred_vector = append(pred_vector,round(perp_zipcode[nrow(perp_zipcode),i]+ trend(perp_zipcode,perp_zipcode[i]),digits=2))
}
predictions_perp[1,] = pred_vector

predictions_case2 <-  case_zipcode[0,]
pred_vector = list(as.Date(case_zipcode[nrow(case_zipcode),1])+7)
for(i in names(case_zipcode)){
  if(i=="week"){
    next
  }
  pred_vector = append(pred_vector,round(case_zipcode[nrow(case_zipcode),i]+ trend(case_zipcode,case_zipcode[i]),digits=2)/1000)
}
predictions_case2[1,] = pred_vector


predictions_case <-  case_zipcode[0,]
pred_vector = list(as.Date(case_zipcode[nrow(case_zipcode),1])+7)
for(i in names(case_zipcode)){
  if(i=="week"){
    next
  }
  pred_vector = append(pred_vector,round(case_zipcode[nrow(case_zipcode),i]+ trend(perp_zipcode,perp_zipcode[i]),digits=2))
}
predictions_case[1,] = pred_vector

#combine predictions_perp and predictions_case2 for plotting reasons
predictions_combo = rbind(predictions_perp,predictions_case2)

convert = function(type){
  if(type == "Case.rate"){
    return(2)
  }else if(type == "Positive.test.rate"){
    return(1)
  }
}