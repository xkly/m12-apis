### Exercise 1 ###

# Load the httr and jsonlite libraries for accessing data
library(httr)
library(jsonlite)

## For these questions, look at the API documentation to identify the appropriate endpoint and information.
## Then send GET() request to fetch the data, then extract the answer to the question

# For what years does the API have statistical data?
response <- GET('http://data.unhcr.org/api/stats/time_series_years.json')
body <- content(response, "text")
years <- fromJSON(body)

# What is the "country code" for the "Syrian Arab Republic"?
countries <- GET('http://data.unhcr.org/api/countries/list.json')
countries.body <- content(countries, "text")
countries.data <- fromJSON(countries.body)
# use dplyr to find out the ocuntry code for the Syrian Arab Republic
syrian.arab.republic.country.code <- countries.data %>%
    filter(name_en == "Syrian Arab Republic") %>%
    select(country_code)


# How many persons of concern from Syria applied for residence in the USA in 2013?
# Hint: you'll need to use a query parameter
# Use the `str()` function to print the data of interest
# See http://www.unhcr.org/en-us/who-we-help.html for details on these terms
base.uri <- "http://data.unhcr.org/api/stats/persons_of_concern.json"
query.parameters <- list(country_of_residence = "USA", country_of_origin = syrian.arab.republic.country.code,
                         year = "2013")
request.syrian.applicants <- GET(base.uri, query = query.parameters)
syrian.applicants.2013 <- fromJSON(content(request.syrian.applicants, "text"))
str(syrian.applicants.2013)

## And this was only 2013...


# How many *refugees* from Syria settled the USA in all years in the data set (2000 through 2013)?
# Hint: check out the "time series" end points
base.uri2 <- "http://data.unhcr.org/api/stats/time_series_all_years.json"
query.parameters2 <- list(country_of_residence = "USA", country_of_origin = syrian.arab.republic.country.code,
                          population_type_code = "RF")
request.refugees.settled <- GET(base.uri2, query = query.parameters2)
refugees.settled <- fromJSON(content(request.refugees.settled, "text"))
refugees.settled <- select(refugees.settled, year, country_of_residence, value)

# Use the `plot()` function to plot the year vs. the value.
# Add `type="o"` as a parameter to draw a line
plot(refugees.settled$year, refugees.settled$value, type = "o")


# Pick one other country in the world (e.g., Turkey).
# How many *refugees* from Syria settled in that country in all years in the data set (2000 through 2013)?
# Is it more or less than the USA? (Hint: join the tables and add a new column!)
# Hint: To compare the values, you'll need to convert the data (which is a string) to a number; try using `as.numeric()`
query.parameters3 <- list(country_of_residence = "TUR", country_of_origin = "SYR", 
                          population_type_code = "RF")
request.refugees.Turkey <- GET(base.uri2, query = query.parameters3)
refugees.in.Turkey <- fromJSON(content(request.refugees.Turkey, "text"))
refugees.in.Turkey <- select(refugees.in.Turkey, year, country_of_residence, value)

USA.TUR.numbers <- full_join(refugees.settled, refugees.in.Turkey, by = "year") %>%
  mutate(USA_more_than_TUR = as.numeric(value.x) > as.numeric(value.y))


## Bonus (not in solution):
# How many of the refugees in 2013 were children (between 0 and 4 years old)?


## Extra practice (but less interesting results)
# How many total people applied for asylum in the USA in 2013?
# - You'll need to filter out NA values; try using `is.na()`
# - To calculate a sum, you'll need to convert the data (which is a string) to a number; try using `as.numeric()`


## Also note that asylum seekers are not refugees
