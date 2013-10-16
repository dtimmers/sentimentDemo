library(RMySQL)
usr <- 'Ruser'
pw <- 'ouRs3cret!'
db_name <- 'sentiment_db'

# Opens a connection to the database and sends a query
send_query <- function(cmd, db_name='sentiment_db'){
  con <- dbConnect( MySQL(), user=usr, password=pw, 
                    dbname=db_name, host='localhost')
  dbSendQuery(con, cmd)
  dbDisconnect(con)
}

# Initialize all the tables in the database.
# The SQL commands are all given in the file /SQL/database_creation.sql
sql_initialize_tables <- function(db_name='sentiment_db'){
  cmd_vec <- cut_commands('../SQL/database_creation.sql')  
  for( sql_cmd in cmd_vec){
    send_query(sql_cmd)
  }
  cat(paste('Successfully created all the necessary tables on the database', db_name))
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