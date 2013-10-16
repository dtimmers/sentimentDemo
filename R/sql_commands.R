library(RMySQL)
usr <- 'Ruser'
pw <- 'ouRs3cret!'
db_name <- 'sentiment_db'

# Opens a connection to the database and sends a query
send_query <- function(cmd, db_name='sentiment_db'){
  con <- dbConnect( MySQL(), user=usr, password=pw, dbname=db_name, host='localhost')
  dbSendQuery(con, cmd)
  dbDisconnect(con)
}

# Initialize all the tables in the database.
# The SQL commands are all given in the file /SQL/database_creation.sql
sql_initialize_tables <- function(){
  cmd_vec <- cut_commands('../SQL/database_creation.sql')  
  for( sql_cmd in cmd_vec){
    send_query(sql_cmd)
  }
  cat(paste('Successfully created all the necessary tables on the database', db_name))
}

fill_state <- function(tab='state'){
  load('data/state_info.RData')
  vals <- collapse_cols_df(state_info[, c('State', 'Abr')])
  cmd <- paste('INSERT INTO', tab, '(name, abr) VALUES', vals)
  send_query(cmd)  
}

fill_city <- function(tab='city'){
  load('data/state_info.RData')
  df <- state_info[, c('Abr', 'City', 'Population', 'Land.Area.in.Square.Miles', 'radius')]
  df <- df_val_to_string(df, c('Abr', 'City'))
  n <- nrow(df)
  for( i in 1:n ){
    row <- df[i,]
    if ( sum(is.na(row))==0 ){
      cmd <- 'INSERT INTO city (state_id, city, population, area, radius) SELECT state_id,'
      cmd <- paste(cmd, paste(row[-1], collapse=', '))
      cmd <- paste(cmd, ' FROM state WHERE abr=', row[1],';', sep='')
      send_query(cmd)
    }    
  }
}

insert_tweet_df <- function(tw){
  
}

df_val_to_string <- function(df, str_cols=NULL){
  if( is.null(str_cols) ){
    str_cols <- 1:ncol(df)
  }  
  for( i in str_cols) {
    df[,i] <- paste("'", df[,i],"'", sep="")
  }
  
  return(df)  
}

collapse_cols_df <- function(df, str_cols=NULL){
  df <- df_val_to_string(df, str_cols=str_cols)
  vals <- apply(df, 1, function(x) paste(x, collapse=", "))
  return(paste('(', paste(vals, collapse='), ('),');', sep=''))
}

# Returns the separate commands in the sql file with filename fn
break_sql_file <- function(fn){
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