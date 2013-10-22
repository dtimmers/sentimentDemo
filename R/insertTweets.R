library("bitops")
library("RCurl")
library("RJSONIO")
library("twitteR")
library("stringr")
setwd('~/Projects/sentimentDemo/R')
# If we search a 1000 Tweets, it takes 10 API requests
# Also Barack Obama uses the term obamacare, otherwise might create difference
# between positve and negative tweets about obamacare, gogreen

Main <- function(term, hrs=1, maxTweets=1000){
  setwd('~/Projects/sentimentDemo/R')
  source('lexicon.R')
  source('sql_commands.R')
  source('time.R')
  
  Login()
  lex <- GetLex()
  city <- sqlGetCity()
  stop_time <- as.numeric(Sys.time()) + ceiling(hrs*3600)
  
  while( as.numeric(Sys.time())<stop_time ){
    DownloadIteration(city=city, lex=lex, maxTweets=maxTweets, term=term)
  }
}

# Downloads tweets from geocode locations of the largest cities in the US states.
# The tweets are uploaded to a MySQL relational database.
# One already has to be OAuth logged in when running an iteration.
DownloadIteration <- function(city=NULL, lex=NULL, maxTweets=1000, term=term){
  if(is.null(lex)){
    lex <- GetLex()
  }
  if( is.null(city)){
    city <- sqlGetCity()
  }
  
  # Set the threshold for sleeping
  # Seems that it takes one API request per 100 tweets
  # TODO: pick better threshold
  th <- 2*ceiling(maxTweets/100)
  # Take a random order of the cities
  for( i in sample(nrow(city)) ){
    geocode <- city[i, c('lat', 'lng', 'radius')]
    geocode[3] <- paste(ceiling(10*geocode[3]),'mi',sep='')
    geocode <- paste(geocode, collapse=",")
    tweetDF <- SearchTweets(term, maxTweets, geocode=geocode)
    if( !is.null(tweetDF) ){
      tweetDF$city_id <- rep(city[i,]$city_id, nrow(tweetDF))
      tweetDF$searchTerm <- rep(term, nrow(tweetDF))
      tweetDF <- CleanTweets(tweetDF)
      tweetDF <- ScoreTweets(tweetDF,lex_vector=lex)
      tweetDF$text <- sapply(tweetDF[,'text'], function(x) str_replace_all(x,"\'",""))
      # remove duplicate tweets
      tweetDF <- unique(tweetDF)
      sqlInsertTweetDF(tweetDF)
    }
    # Check whether we have to put the system to sleep
    t <- GetSleepTime(th)
    if( t > 0 ){
      RtoSleep(t)
    }
  }
}

# Get authorization to search tweets
# See Readme file for creating your login credentials
# and saving it into 'OAuth.RData'
Login <- function()
{
  load("OAuth.RData")
  registerTwitterOAuth(twitCred)
}

# RetrieveTweets() - return a dataframe based on a search term
# as.data.frame() coerces each list element into a row
# lapply() applies this to all of the elements in twtList
# rbind() takes all of the rows and puts them together
# do.call() gives rbind() all the rows as individual elements

# TODO: supressing all warning but only want to suppress warnings
# with '1000 tweets were requested but API can only return 104'
SearchTweets <- function(searchTerm, maxTweets, geocode=NULL)
{ 
  tryCatch({
    if( is.null(geocode) ){
      twtList <- suppressWarnings( searchTwitter(searchTerm, n=maxTweets) )
    }
    else {
      twtList <- suppressWarnings( searchTwitter(searchTerm, n=maxTweets, geocode=geocode) )
    }
    return(do.call("rbind",lapply(twtList,as.data.frame)))},
    error=function(msg){
      message(cat(paste(msg)))
    }
  )
}

# clean up the tweet texts by removing hashtags, years, etc.
# The order in which symbols are removed is important e.g,
# first remove retweets @****, then remove punctuation and symbols with :punct:
CleanTweets<-function(tweetDF)
{
  txt <- tweetDF$text
  # URLs
  txt <- str_replace_all(txt,"http://t.co/[a-z,A-Z,0-9]{7,10}","")
  # references to other screennames and parts of retweet header
  txt <- str_replace_all(txt,"@[[:alnum:]]*","")
  # retweet header
  txt <- str_replace(txt,"RT ","")
  # &amp
  txt <- str_replace_all(txt,"&amp","")
  # hexidecimal characters
  txt <- str_replace_all(txt,"[\x01-\x1f\x7f-\xff]","")
  # digits
  txt <- str_replace_all(txt,"[[:digit:]]"," ")
  # punctuation
  txt <- str_replace_all(txt,"[[:punct:]]"," ")
  # redundant spacing
  txt <- str_replace_all(txt, "\\s+"," ")
  txt <- str_trim(txt, side="both")
  
  tweetDF$cleanText <- tolower(txt)
  return(tweetDF)
}

# Scores the tweets by taking the median over the lexicon scores
# for each stemmed word in the cleaned text of the tweet.
ScoreTweets <- function(tweetDF, lex_vector){
  # First stem the words in the tweets
  stem_txt <- sapply(tweetDF$cleanText, function(x) StemText(x))
  sc <- sapply(stem_txt, function(x) median(lex_vector[unlist(strsplit(x," "))], na.rm=T))
  sc[is.na(sc)] <- 'null'
  tweetDF$score <- sc
  return(tweetDF)
}

# Function which reduces every word in txt to its stem.
StemText <- function(txt){
  return(paste(stemDocument(unlist(strsplit(txt, " ")), language='en'), collapse=" "))
}