##############################################
### Data Insights About Chicago White Sox ###
#############################################

################################################################################################################
##################################### Year By Year Team Batting Statistics #####################################
################################################################################################################
# clear global environment
rm(list = ls())

# loading in packages needed
setwd("/Users/adam/Desktop/ISA 401/Data")
pacman:: p_load(tidyverse, rvest, magrittr, lubridate, DataExplorer, dplyr, correlation)

# reading in the year-by-year team batting stats
YBYpageURL = "https://www.baseball-reference.com/teams/CHW/batteam.shtml#site_menu_link"
YBYpageURL %>% read_html() %>% #same reading in as you've used before, but we just gave the read_html a name 
  html_nodes("table#yby_team_bat") %>% html_table(header = 1) %>% data.frame() -> YearByYearTeamBatting #header = 1 argument makes the first row the headers for the columns, turning it into a dataframe

# investigating the data classifications
str(YearByYearTeamBatting) #all of them should be num or int based on the fact that the table was originally stats 
                          # only one concerning is the Year, could classify as a date but it should work as a int

# removing the "league" column, all values are the same, removing other variables that we will not be using for Tableau
YearByYearTeamBatting <- select(YearByYearTeamBatting, -c(Lg, G, BatAge, Fld., DP, E, R.G, SB, CS, OBP, SLG, OPS, BA))

# renaming the column names so that if someone is not familiar with baseball they can have a better idea of what the data represents
YearByYearTeamBatting <- YearByYearTeamBatting %>% rename(
  Wins = W,
  Losses = L,
  B.Plate.Appearances = PA,
  B.At.Bats = AB,
  B.Runs.Scored = R,
  B.Hits = H,
  B.Doubles.Hit = X2B,
  B.Triples.Hit = X3B,
  B.Homeruns.Hit = HR, 
  B.Runs.Batted.In = RBI, 
  B.Walks = BB,
  B.Strikeouts = SO,
 )

# Making sure that the data we are looking at is from the last 21 years only
YearByYearTeamBatting = YearByYearTeamBatting[-c(23:120),]

# Pulling the Covid year out from the data to later use as a comparison
Batting.CovidYear = YearByYearTeamBatting[1, ]
YearByYearTeamBatting = YearByYearTeamBatting[-c(1),] # removing so that we can apply the mulitplier to it 

# Checking to see if there are any missing values
plot_missing(YearByYearTeamBatting) # none of the columns have a missing value, we are okay to continue

################################################################################################################
##################################### Year By Year Team Pitching Statistics ####################################
################################################################################################################

# reading in the year-by-year team pitching stats
YBYpPageURL = "https://www.baseball-reference.com/teams/CHW/pitchteam.shtml"
YBYpPageURL %>% read_html() %>% #same reading in as you've used before, but we just gave the read_html a name 
  html_nodes("table#yby_team_pitch") %>% html_table(header = 1) %>% data.frame() -> YearByYearTeamPitching #header = 1 argument makes the first row the head ers for the columns, turning it into a dataframe

# investigating the data classifications
str(YearByYearTeamPitching) #all of them should be num or int based on the fact that the table was originally stats 
                          # only one concering is the Year, could classify as a date but it should work as a int

#removing the "league" column, all values are the same and the league is consistent, removing variables we will not bring into Tableau
YearByYearTeamPitching <-select(YearByYearTeamPitching, -c(Lg, G, RA.G, WHIP, ERA, SO9, HR9, DP, Fld., PAge, IP))

#Changing the column names to be something more familiar for those with lesser baseball knowledge
YearByYearTeamPitching <- YearByYearTeamPitching %>% rename(
  Wins = W, 
  Losses = L, 
  P.Complete.Games = CG, 
  P.Team.Shutouts = tSho, 
  P.Saves = SV, 
  P.Hits.Allowed = H, 
  P.Runs.Allowed = R, 
  P.Earned.Runs.Allowed = ER, 
  P.Home.Runs.Allowed = HR, 
  P.Walks = BB, 
  P.Strikeouts = SO, 
  Errors = E, 
)
# Making sure that the data we are looking at is from the last 20 years only
YearByYearTeamPitching = YearByYearTeamPitching[-c(23:120),]

# Pulling the Covid year out from the data to later use as a comparison
Pitching.CovidYear = YearByYearTeamPitching[1, ] # brings 1st row to its own data set
YearByYearTeamPitching = YearByYearTeamPitching[-c(1),] #removes first row from the YearByYearPitching 

# Checking to see if there are any missing values
plot_missing(YearByYearTeamBatting) # none of the columns have a missing value, we are okay to continue

################################################################################################################
######################################## Combining Data Together ###############################################
################################################################################################################
# combining non covid years together
WhiteSox.Data = merge(YearByYearTeamBatting, YearByYearTeamPitching) #joins on Year and placed finish in the league cause they were the two columns with exact same values
    # removing the two data sets that we joined together to clean up the global environment
    rm(YearByYearTeamBatting, YearByYearTeamPitching, YBYpageURL, YBYpPageURL)

# combining covid years together, repeating process
Covid.Years = merge(Batting.CovidYear, Pitching.CovidYear)
    rm(Batting.CovidYear, Pitching.CovidYear)

# Multiplying all the values by 2.7 to resemble a real 162 game season, excluded Year because we want to keep that as 2020
Covid.Years <- Covid.Years[, c(1,4,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24)] #moved the finish column to second in order to make the next step easier
Covid.Years[3:24] <- round(Covid.Years[3:24] *2.7)

# re-combining the non-covid years with the covid years since the multiplier has been applied
WhiteSox.Data = rbind(WhiteSox.Data, Covid.Years)
# removing Covid.Years to clean up global environment and because we no longer need it
rm(Covid.Years)

################################################################################################################
######################################## Saving as CSV File ####################################################
################################################################################################################
# writing the final data set as a csv file to bring into Tableau, no longer need the Covid.Years data
write.csv(WhiteSox.Data, "WhiteSoxData2.csv")
