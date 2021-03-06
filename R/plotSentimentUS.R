library("ggplot2")
library("maps")
library("RColorBrewer")
setwd('~/Projects/sentimentDemo/R')

plotUSstates <- function(term)
{
  #load us map data
  states <- map_data("state")
  state.info <- data.frame(state.center, state.name, state.abb)
  # Exclude the states Alaska and Hawaii
  state.info <- subset(state.info, !state.name %in% c("Alaska", "Hawaii"))
  
  # Get the tweets
  tweets <- sqlGetDateCityScores(term)
  if( nrow(tweets)==0 ){
    stop(paste('There were no tweets in the database with the search term', term))
  }
  dates <- unique(tweets$date)
  for( d in dates ){
    tw <- subset( tweets, date==d)
    missing <- setdiff(state.info$state.name, tw$name)
    Nmiss <- length(missing)
    dfMiss <- cbind(rep(d, Nmiss), missing, rep(-2, Nmiss))
    colnames(dfMiss) <- names(tw)
    tw <- rbind(tw, dfMiss)
    plotSentimentMap(states, tw, state.info, term, d)
  }
}

plotSentimentMap <- function(states, tw, state.info, term, date,
                             folder='Figures'){
  # add sentiment scores to states  
  states$score <- as.numeric(tw$score[match(states$region, tolower(tw$name))])
  # cutting the state scores into bins
  # a score of 1 represents no available score
  states$bin <- rep(1, nrow(states))
  idx_noscore <- which(states$score==-2)
  idx_NA <- which(is.na(states$score))
  idx_score <- setdiff(1:nrow(states), union(idx_noscore, idx_NA))
  #states$bin[idx_score] <- cut(states$score[idx_score], 5, labels=F, include.lowest=T)+1
  states$bin[idx_score] <- sapply(states$score[idx_score], score_to_factor)
  legend_labels <- c('no tweets', 'high neg','neg','neutral','pos','high pos')
  states$bin <-factor(
    states$bin, levels=1:6, labels=legend_labels
    )
  
  bin_levels <- sort(unique(states$bin))
  fill_colors <- c(rgb(192, 192, 192, max=255), rgb(215, 25, 28, max=255), 
                    rgb(253, 174, 97, max=255), rgb(255, 255, 191, max=255), 
                    rgb(166, 217, 106, max=255), rgb(26, 150, 65, max=255))
  cols <- as.list(fill_colors)
  # change date into nicer format
  date_str <- format(as.Date(date, format="%Y-%m-%d"), format="%d %b %Y")
  # making sure the latitudes and longitudes do not show
  theme_opts <- list(theme(panel.grid.minor = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.background = element_blank(),
                           plot.background = element_rect(fill="#e6e8ed"),
                           panel.border = element_blank(),
                           axis.line = element_blank(),
                           axis.text.x = element_blank(),
                           axis.text.y = element_blank(),
                           axis.ticks = element_blank(),
                           axis.title.x = element_blank(),
                           axis.title.y = element_blank(),
                           plot.title = element_text(size=16, hjust=0.5)));
  # convert date to nicer format format(date, format="%d %B %Y")
  p <- ggplot(states, aes(x=long, y=lat))
  p <- p + 
    geom_polygon(aes(long, lat, group = group, fill=bin), colour="#666666" ) + 
    labs(title=paste("Sentiment about ",term,"-",date_str,sep="")) + 
    guides(fill=guide_legend(title='Scores')) +
    geom_text(data = state.info, aes(x = x, y = y, label = state.abb), 
              colour = 'black',size=4) +
    scale_fill_manual(values=fill_colors[bin_levels]) +
    theme_opts
  
  figDir <-  paste(folder,"sentiment/", term,sep='')
  path <- file.path(getwd(), folder)
  dir.create(path, showWarnings = FALSE)
  path <- file.path(path, "sentiment")
  dir.create(path, showWarnings = FALSE)
  path <- file.path(path, term)
  dir.create(path, showWarnings = FALSE)
  fn <- paste(path, "/sentimentUS-",term,"-",date,".png",sep='')
  ggsave(fn,width=16.510,height=10.668,units="cm")
}

score_to_factor <- function(x){
  score <- ifelse(x==-2, 1,
              ifelse( -1 <= x & x < -0.6, 2,
                      ifelse(-0.6 <= x & x< -0.2, 3,
                             ifelse( -0.2 <= x & x < 0.2, 4,
                                     ifelse(0.2 <= x & x < 0.6, 5,
                                            ifelse(0.6 <= x & x <= 1, 6, NA))))))
  return(score)
}
