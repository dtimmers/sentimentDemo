# For scraping tables from the internet
library(XML)
# For creating URL's
library(RCurl)
# For extracting JSON data
library(RJSONIO)

get_state_info <- function(keep_cols=c('State', 'Abr', 'City', 'Population', 
                                          'Land.Area.in.Square.Miles'),
                           num_cols=c('Population', 'Land.Area.in.Square.Miles')
                           ){
  states <- get_capital()
  largest_cities <- get_largest_city()
  states['City'] <- largest_cities$Largest.city[match(states$State, 
                                                      largest_cities$State)]
  
  city_areas <- get_city_area()
  # merge the information of the city areas into the states table
  # Do an outer join as some of the cities have less than 50,000 inhabitants
  m <- merge(states, city_areas, by=c('City', 'State'), sort=F, all.x = TRUE)
  
  m <- m[, keep_cols]  
  new_cols <- lapply( m[, num_cols], function(x) as.numeric(gsub(",","",x)) )
  m[, num_cols] <- new_cols
  m['radius'] <- sqrt(m$Land.Area.in.Square.Miles/(2*pi))
  
  # Add the longitude and lattitudes of the largest cities to the table
  address <- paste(m$City, m$Abr, sep=", ")
  geo <- t(sapply(address, function(x) get_geocode(x)))
  colnames(geo) <- c('lat', 'lng')
  m <- cbind(m, geo)
   
  return(m)
}

# Function that saves the data into an Rdata file
# If no dir is given it saves in the 'data' folder in the current directory.
save_state_info <- function(fn='state_info.RData', dir=NULL){
  if( is.null(dir) ){
    dir <- getwd()    
  }
  
  state_info <- get_state_info()
  save( state_info, file=paste(dir,'data',fn,sep='/'))
}

# Scrapes the state capitals and abbreviations from Wikipedia.
get_capital <- function(){
  the_url <- 'http://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States'
  state_capitals <- readHTMLTable(the_url, which=1, stringsAsFactors=F)
  names(state_capitals) <- remove_space_special(names(state_capitals))
  return(state_capitals)
}

# Returns the states plus the largest city in that state
get_largest_city <- function(){
  the_url <- "http://simple.wikipedia.org/wiki/List_of_U.S._states'_largest_cities"
  state_city <- readHTMLTable(the_url, which=1, stringsAsFactors=F)[,1:2]
  names(state_city) <- remove_space_special(names(state_city))
  state_city$Largest.city <- remove_digits(state_city$Largest.city)
  # Manual fix: Boise -> Boise City
  state_city$Largest.city <- gsub("Boise", "Boise City", state_city$Largest.city)
  
  return(state_city)
}

# Returns a table with cities which have more than 50,000 inhabitants and their land area
get_city_area <- function(){
  the_url <- "http://www.demographia.com/db-uscity98.htm"
  t <- readHTMLTable(the_url, stringsAsFactors=F, which=1)
  
  #Only need the first 5 colums
  t <- t[,1:5]
  # Remove redundant first row
  t <- t[-1,]
  # Second  row contains the column names
  names(t) <- gsub("Municipality", "City", remove_digits(remove_space_special(t[1,])))
  # Remove the now redundant row
  t <- t[-1,]
  
  # Drop last four rows
  t <- head(t, nrow(t)-4)
  
  # Cleaning up the table to make it compatible with get_capital()
  states <- get_capital()
  idx_state <- match(t$State, states$State)
  for(i in 1:nrow(t)){
    t[i,]$City <- gsub(paste(" ",states[idx_state[i],]$Abr,sep=""), "", t[i,]$City)
    t[i,]$City <- gsub(" city", "", t[i,]$City)
    t[i,]$City <- gsub("New York", "New York City", t[i,]$City)
  }
  
  # TODO: Add in Honolulu manually
  t <- rbind( t, c(602, 'Honolulu', 'Hawaii', 390738 , 68.4))
  t <- rbind(t, c(603, 'Burlington', 'Vermont', 42282, 15.5))
  return(t)
}

# Create the url from a given address
# Uses Google maps
construct_geocode_url <- function(address, return.call = "json", sensor = "false") {
  the_url <- "http://maps.google.com/maps/api/geocode/"
  u <- paste(the_url, return.call, "?address=", address, "&sensor=", sensor, sep = "")
  return(URLencode(u))
}

# Returns the longitude and latitude of an address
# Recurstively tries num_tries times to find the address
# If no address is found it returns NULL
get_geocode <- function(address, num_tries=20) {
  if(num_tries>0){
    u <- construct_geocode_url(address)
    doc <- getURL(u)
    x <<- fromJSON(doc)
    if(x$status=="OK") {
      lat <- x$results[[1]]$geometry$location['lat']
      lng <- x$results[[1]]$geometry$location['lng']
      return(c(lat, lng))
    } 
    else {
      get_geocode(address, num_tries=(num_tries-1))
    }
  }
}

# Function that removes special characters and spaces
remove_space_special <- function(s){
  return(gsub(" ", ".", gsub("[[:punct:]]","", s)))
}

# Removes the years followed by an optional period.
remove_digits <- function(s){
  return(gsub("[0-9][.]*", "", s))
}