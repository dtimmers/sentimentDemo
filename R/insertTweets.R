library("bitops")
library("RCurl")
library("RJSONIO")
library("twitteR")
library("stringr")
# getCurRateLimitInfo() gives information about the current rate limit

# Downloads tweets from geocode locations of the largest cities in the US states.
# The tweets are uploaded to a MySQL relational database.
DownLoadTweets <- function(city=NULL, lex=NULL, maxTweets=40, term='obamacare'){
  if(is.null(lex)){
    lex <- GetLex()
  }
  if( is.null(city)){
    city <- sqlGetCity()
  }
  if( length(dbListConnections(MySQL()))>0 ){
    for( con in dbListConnections(MySQL()) ){
      dbDisconnect(con)
    }
  }
  Login()
  
  for( i in 1:nrow(city)){
    geocode <- city[i, c('lat', 'lng', 'radius')]
    geocode[3] <- paste(ceiling(20*geocode[3]),'mi',sep='')
    geocode <- paste(geocode, collapse=",")
    if(i==1){
      tweetDF <- SearchTweets(term, maxTweets, geocode=geocode)
      tweetDF$city_id <- rep(city[i,]$city_id, nrow(tweetDF))
      tweetDF$searchTerm <- rep(term, nrow(tweetDF))
    }
    else{
      new_tweets <- SearchTweets(term, maxTweets, geocode=geocode)
      new_tweets$city_id <- rep(city[i,]$city_id, nrow(new_tweets))
      new_tweets$searchTerm <- rep(term, nrow(new_tweets))
      tweetDF <- rbind(tweetDF, new_tweets)
    }
  }
  tweetDF <- CleanTweets(tweetDF)
  tweetDF <- ScoreTweets(tweetDF,lex_vector=lex)
  tweetDF$text <- sapply(tweetDF[,'text'], function(x) str_replace_all(x,"\'",""))
  # remove duplicate tweets
  tweetDF <- unique(tweetDF)
  sqlInsertTweetDF(tweetDF)
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

SearchTweets <- function(searchTerm, maxTweets, geocode=NULL)
{
  if( is.null(geocode)){
    twtList <- searchTwitter(searchTerm, n=maxTweets) 
  }
  else {
    twtList <-  searchTwitter(searchTerm, n=maxTweets, geocode=geocode) 
  }
  return(do.call("rbind",lapply(twtList,as.data.frame)))
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

# Twitter sets rate limits for downloading tweets
# We extract the info about the rate limits and determine how long
# R has to be put into sleep before continuing with downloading tweets.
GetSleepTime <-function(col='resource', row='/search/tweets'){
  g <- getCurRateLimitInfo()
  next_time <- as.numeric(g[ g[col]==row,]$reset)
  current_time <- as.numeric(Sys.time())
  return(max(0, next_time-current_time))
}

# Function which reduces every word in txt to its stem.
StemText <- function(txt){
  return(paste(stemDocument(unlist(strsplit(txt, " ")), language='en'), collapse=" "))
}