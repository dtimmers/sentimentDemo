library("bitops")
library("RCurl")
library("RJSONIO")
library("twitteR")

# Get authorization to search tweets
# See Readme file for creating your login credentials
# and saving it into 'OAuth.RData'
Login <- function()
{
  load("OAuth.RData")
  registerTwitterOAuth(twitCred)
}

#TweetFrame() - return a dataframe based on a search of Twitter
# as.data.frame() coerces each list element into a row
# lapply() applies this to all of the elements in twtList
# rbind() takes all of the rows and puts them together
# do.call() gives rbind() all the rows as individual elements

TweetFrame <- function(searchTerm, maxTweets)
{
  twtList <- searchTwitter(searchTerm,n=maxTweets)
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
  # retweet header
  txt <- str_replace(txt,"RT @[a-z,A-Z,0-9]*:","")
  # references to other screennames
  txt <- str_replace_all(txt,"@[a-z,A-Z]*","")
  # &amp
  txt <- str_replace_all(txt,"&amp","")
  # hexidecimal characters
  txt <- str_replace_all(txt,"[[:xdigit:]]","")
  # digits
  txt <- str_replace_all(txt,"[[:digit:]]"," ")
  # punctuation
  txt <- str_replace_all(txt,"[[:punct:]]"," ")
  # redundant spacing
  txt <- str_replace_all(txt, "\\s+"," ")
  txt <- str_trim(txt, side="both")
  
  tweetDF$clean_text <- txt
  return(tweetDF)
}