library("bitops")
library("RCurl")
library("RJSONIO")
library("twitteR")
library("stringr")

# Get authorization to search tweets
# See Readme file for creating your login credentials
# and saving it into 'OAuth.RData'
Login <- function()
{
  load("OAuth.RData")
  registerTwitterOAuth(twitCred)
}

#TweetSearch() - return a dataframe based on a search term
# as.data.frame() coerces each list element into a row
# lapply() applies this to all of the elements in twtList
# rbind() takes all of the rows and puts them together
# do.call() gives rbind() all the rows as individual elements

SearchTweet <- function(searchTerm, maxTweets)
{
  twtList <- searchTwitter(searchTerm,n=maxTweets)
  return(do.call("rbind",lapply(twtList,as.data.frame)))
}

#GetTweet() - return a dataframe of tweets
GetTweet <- function(maxTweets)
{
  twtList <- Rtweets(n=maxTweets)
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

ScoreTweets <- function(tweetDF, lex_vector){
  # First stem the words in the tweets
  stem_txt <- sapply(tweetDF$cleanText, function(x) StemText(x))
  # Take the median among the word scores to compute the overall sentiment score
  sc <- sapply(stem_txt, function(x) median(lex_vector[unlist(strsplit(x," "))], na.rm=T))
  sc[is.na(sc)] <- 0
  tweetDF$score <- sc
  return(tweetDF)
}

StemText <- function(txt){
  return(paste(stemDocument(unlist(strsplit(txt, " ")), language='en'), collapse=" "))
}