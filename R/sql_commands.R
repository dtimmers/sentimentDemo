send_query <- function(cmd, db_name='sentiment_db'){
  con <- dbConnect( MySQL(), user='Ruser', password='ouRs3cret!', 
                    dbname=db_name, host='localhost')
  on.exit(dbDisconnect(con))
  dbSendQuery(con, cmd)
}

sql_create_tables <- function(db_name='sentiment_db'){
  cmd_vec <- cut_commands('../SQL/database_creation.sql')  
  for( sql_cmd in cmd_vec){
    print(sql_cmd)
    send_query(sql_cmd)
  }  
}

# Given a sql file it returns the separate sql commands in the file
cut_commands <- function(fn){
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