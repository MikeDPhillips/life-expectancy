setwd("~/Documents/GitHub/info3300_proj1/")


library(tidyr)
library(jsonlite)
library(purrr)

#Process the life expectancy at 60 data
list_who60 <- fromJSON("WHO_Life60.json")
list_who60 <- map_if(list_who60, is.data.frame, list) 
df_who60 <- unnest(as_tibble(list_who60))
#keep columns of interest
cols <- c("CountryCode"= "SpatialDim", "Year" = "TimeDim", 
          "Sex" = "Dim1", "LifeExpectancyAt60" = "NumericValue")
df_who60 %>% select(cols) -> df60
write.csv(x = df60, sep = ",", row.names = F, col.names = T, file = "who60_long.csv")

#process life expectancy at birth data
list_who <- fromJSON("WHO_LifeBirth.json")
list_who <- map_if(list_who, is.data.frame, list) 
df_who <- unnest(as_tibble(list_who))
cols <- c("CountryCode"= "SpatialDim", "Year" = "TimeDim", 
          "Sex" = "Dim1", "LifeExpectancy" = "NumericValue")

df_who %>% select(cols) -> df_birth
#one bad data point should be removed (canada 1920)
df_birth <- df_birth[2:nrow(df_birth), ]
write.csv(x = df_birth, row.names = F, file = "whoBirth_long.csv")

df_both <- left_join(df60, df_birth)
#Country and Region Codes
list_ctry <- fromJSON("WHO_country.json")
list_ctry <- map_if(list_ctry, is.data.frame, list) 
df_ctry <- unnest(as_tibble(list_ctry))
df_ctry <- df_ctry %>% select(c("CountryCode" = "Code", "Country" = "Title", 
                                "Region" = "ParentTitle"))

df_complete <- left_join(df_both, df_ctry)
df_complete <- df_complete[, c(1, 6, 2, 3, 4, 5, 7)]

write.csv(x = df_complete, row.names = F, file = "WHOAllData.csv")


plot(df_complete)
