# This file contains all the time functions necessary to obey the rate limits imposed by
# Twitter: https://dev.twitter.com/docs/rate-limiting/1.1
# E.g. can only ask for week-old tweets and not before.

# Checks how many API requests we can still make. If the number of allowed API requests
# falls below the given threshold th it returns the amount of time in seconds 
# we have to wait until the rate limit has been reset.
GetSleepTime <-function(th, col='resource', resource_name='/search/tweets'){
  g <- getCurRateLimitInfo()
  api_row <- g[ g[col]==resource_name,]
  if( api_row$remaining < th){
    return(0)
  }
  else{
    next_time <- as.numeric(api_row$reset)
    current_time <- as.numeric(Sys.time())
    return(max(0, ceiling(next_time-current_time)))
  }
}

# A function which puts R 'to sleep' for time_sec seconds amount of time
RtoSleep <- function(time_sec){
  Sys.sleep(time_sec)
}