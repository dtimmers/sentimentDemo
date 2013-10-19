library(RMySQL)
usr <- 'Ruser'
pw <- 'ouRs3cret!'
db_name <- 'sentiment_db'

# Opens a connection to the database and sends a query
sqlSendQuery <- function(cmd, con=NULL){
  start_con <- F
  if(is.null(con)){
    start_con <- T
    con <- dbConnect( MySQL(), user=usr, password=pw, dbname=db_name, host='localhost')
  }
  tryCatch(dbSendQuery(con, cmd),
           error=function(msg) {
             if( regexpr('Duplicate entry', msg)[1]==-1) {
               message(cat(paste(msg)))
             }
           },
           finally={
             if( start_con ){
               dbDisconnect(con)
             }
           }
  )
}

sqlGetQuery <- function(cmd, con=NULL){
  start_con <- F
  if(is.null(con)){
    start_con <- T
    con <- dbConnect( MySQL(), user=usr, password=pw, dbname=db_name, host='localhost')
  }
  res <- tryCatch({
    res <- dbGetQuery(con, cmd)},
    error=function(msg) {
      message(cat(paste(msg)))
      res <- NULL
    },
    warning=function(msg) {
      res <- NULL
    },
    finally={
      if( start_con ){
        dbDisconnect(con)
      }
    }
  )
  return(res)
}

# Initialize all the tables in the database.
# The SQL commands are all given in the file /SQL/database_creation.sql
sqlInitializeTables <- function(){
  cmd_vec <- sqlCutQueries('../SQL/database_creation.sql')  
  for( sql_cmd in cmd_vec){
    sqlSendQuery(sql_cmd)
  }
}

sqlFillState <- function(tab='state'){
  load('data/state_info.RData')
  vals <- CollapseColsDF(state_info[, c('State', 'Abr')])
  cmd <- paste('INSERT INTO', tab, '(name, abr) VALUES', vals)
  sqlSendQuery(cmd)  
}

sqlFillCity <- function(tab='city'){
  load('data/state_info.RData')
  View(state_info)
  df <- state_info[, c('Abr', 'City', 'Population', 'Land.Area.in.Square.Miles', 
                       'radius', 'lat', 'lng')]
  df <- dfValToString(df, c('Abr', 'City'))
  con <- dbConnect( MySQL(), user=usr, password=pw, dbname=db_name, host='localhost')
  n <- nrow(df)
  for( i in 1:n ){
    row <- df[i,]
    if ( sum(is.na(row))==0 ){
      cmd <- 'INSERT INTO city (state_id, city, population, area, radius, lat, lng) 
      SELECT state_id,'
      cmd <- paste(cmd, paste(row[-1], collapse=', '))
      cmd <- paste(cmd, ' FROM state WHERE abr=', row[1],';', sep='')
      sqlSendQuery(cmd, con=con)
    }
  }
  dbDisconnect(con)
}

sqlInsertTweetDF <- function(tw_df){
  Ntweet <- nrow(tw_df)
  cols <- c('id', 'city_id', 'created', 'text', 'cleanText', 'score', 
            'screenName', 'searchTerm')
  con <- dbConnect( MySQL(), user=usr, password=pw, dbname=db_name, host='localhost')
  for(i in 1:Ntweet){
    tweet <- tw_df[i, cols]
    tweet <- dfValToString(tweet, c('created', 'text', 'cleanText', 'screenName', 'searchTerm'))
    cmd <- 'INSERT INTO tweet (tweet_id, city_id, datetime, txt, cleanTxt, score, screenName, searchTerm) VALUES'
    cmd <- paste(cmd, paste('(',paste(tweet, collapse=","),');'))
    sqlSendQuery(cmd, con=con)
  }
  dbDisconnect(con)
}

sqlGetCity <- function() {
  city_cmd <- "SELECT city_id, lat, lng, radius FROM"
  city_cmd <- paste(city_cmd, "city JOIN state USING ( state_id )")
  return(sqlGetQuery(city_cmd))
}

sqlGetDateCityScores <- function(term, from_date=NULL){
  cmd <- 'SELECT DATE(tweet.datetime) AS date, state.name, AVG(tweet.score) AS score'
  cmd <- paste(cmd, 'FROM tweet JOIN state JOIN city')
  cmd <- paste(cmd, 'ON tweet.city_id=city.city_id AND city.state_id=state.state_id')
  cmd <- paste(cmd, " WHERE tweet.score IS NOT NULL AND tweet.searchTerm='",term,"'", sep="")
  if(!is.null(from_date)){
    cmd <- paste(cmd, "AND date(tweet.datetime)>='", from_date,"'", sep="")
  }
  cmd <- paste(cmd, 'GROUP BY DATE(tweet.datetime), state.name')
  cmd <- paste(cmd, 'ORDER BY DATE(tweet.datetime);')
  return(sqlGetQuery(cmd))
}

dfValToString <- function(df, str_cols=NULL){
  if( is.null(str_cols) ){
    str_cols <- 1:ncol(df)
  }  
  for( i in str_cols) {
    df[,i] <- paste("'", df[,i],"'", sep="")
  }
  
  return(df)  
}

CollapseColsDF <- function(df, str_cols=NULL){
  df <- dfValToString(df, str_cols=str_cols)
  vals <- apply(df, 1, function(x) paste(x, collapse=", "))
  return(paste('(', paste(vals, collapse='), ('),');', sep=''))
}

# Returns the separate commands in the sql file with filename fn
sqlCutQueries <- function(fn){
  lines <- readLines(fn)
  
  idx_cut <- which(regexpr('^$|^/*', lines)==1)
  idx_cut <- c(0, idx_cut)
  cmd_vec <- vector()
  for(i in 1:(length(idx_cut)) ){
    if( i==length(idx_cut) ){
      cmd_vec <- c(cmd_vec, paste(lines[(idx_cut[i]+1):length(lines)],  collapse=""))
    }
    else if( (idx_cut[i+1]-idx_cut[i])!=1 ){
      cmd_vec <- c(cmd_vec, paste(lines[(idx_cut[i]+1):(idx_cut[i+1]-1)],  collapse=""))
    }
  }
  
  return(cmd_vec)
}