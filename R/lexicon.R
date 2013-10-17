library(tm)
library(SnowballC)
# Returns a keyed vector with pairs (key, value)=(word, score),
# where score is the sentiment score of the word.
# The score is in the range -1 to 1.
get_lex <- function(sent_col='priorpolarity', word_col='word'){
  df <- read_lex()
  df <- add_scores_lex(df, sent_col=sent_col)
  return( setNames( unlist(df['score'], use.names=F), unlist(df[word_col], use.names=F)) )
}

# Reads the MPQA lexicon and turns it into a dataframe.
# The lexicon can be downloaded at:
# http://mpqa.cs.pitt.edu/lexicons/subj_lexicon/
# The scores are string-valued: either 'positive', 'negative', 'neutral', 
# 'both' or 'weak negative'
read_lex <- function(){
  lines <- readLines('data/subjectivity_lexicon_MPQA.tff')
  rows <- gsub(' len=1', "", lines)
  rows <- gsub('type=[a-z]+\\s', '', rows)
  rows <- gsub(' polarity=[a-z]+', "", rows)
  rows <- gsub(' mpqapolarity=[a-z]+\\s*', "", rows)
  rows <- gsub(' pos1=[a-z]+', "", rows)
  rows <- gsub(' m', '', rows)  
  splitLines <- strsplit(rows, split='\\s|=')
  
  ncol <- length(splitLines[[1]])
  colnames <- splitLines[[1]][seq(from=1, to=ncol, by=2)]  
  linesMatrix <- matrix(unlist(splitLines, use.names=F), ncol = ncol, byrow = TRUE)
  linesMatrix <- linesMatrix[, seq(from=2, to=ncol, by=2)]
  colnames(linesMatrix) <- gsub('[[:digit:]]', '', colnames)
  df <- as.data.frame(linesMatrix, stringsAsFactors=F)
  word_stem <- stemDocument(unlist(df$word, use.names=F), language='en')
  df$word <- word_stem
  return( unique(df) )
}

# Turn string-valued scores into numeric scores and add this to the dataframe lex_df.
add_scores_lex <- function(lex_df, sent_col='priorpolarity'){
  score_keys <- list('negative'=-1,
                     'weakneg'=-0.5,
                     'neutral'=0,
                     'both'=0,
                     'positive'=1
  )
  
  lex_df['score'] <- unlist( score_keys[unlist(lex_df[sent_col], use.names=F)], 
                             use.names=F)
  return(lex_df)
}