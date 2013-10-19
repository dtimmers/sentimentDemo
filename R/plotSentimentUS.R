library("ggplot2")
library("maps")
library("RColorBrewer")

plotUSstates <- function(term)
{
  #load us map data
  states <- map_data("state")
  state.info <- data.frame(state.center, state.name, state.abb)
  # Exclude the states Alaska and Hawaii
  state.info <- subset(state.info, !state.name %in% c("Alaska", "Hawaii"))
  
  # Get the tweets
  tweets <- sqlGetDateCityScores(term)
  dates <- unique(tweets$date)
  for( d in rev(dates)[1] ){
    tw <- subset( tweets, date==d)
    missing <- setdiff(state.info$state.name, tw$name)
    Nmiss <- length(missing)
    dfMiss <- cbind(rep(d, Nmiss), missing, rep(-2, Nmiss))
    colnames(dfMiss) <- names(tw)
    tw <- rbind(tw, dfMiss)
    plotSentimentMap(states, tw, state.info)
  }
}

plotSentimentMap <- function(states, tw, state.info){
  # add sentiment scores to states
  states$score <- as.numeric(tw$score[match(states$region, tolower(tw$name))])
  # cutting the state scores into bins
  # a score of 1 represents no available score
  states$bin <- rep(1, nrow(states))
  idx_noscore <- which(states$score==-2)
  idx_NA <- which(is.na(states$score))
  idx_score <- setdiff(1:nrow(states), union(idx_noscore, idx_NA))
  states$bin[idx_score] <- cut(states$score[idx_score], 5, labels=F, include.lowest=T)+1
  states$bin <-factor(
    states$bin, labels=c('no tweets', 'high neg','neg','neutral','pos','high pos')
    )
  #making sure the latitudes and longitudes do not show
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
                           plot.title = element_text(size=22)));
  #plot all states with ggplot
  p <- ggplot(states, aes(x=long, y=lat))
  p <- p + 
    geom_polygon(aes(long, lat, group = group, fill=bin),colour="#C0C0C0" ) + 
    labs(title="Relative sentiment of the US states") + 
    guides(fill=guide_legend(title="scores")) +
    geom_text(data = state.info, aes(x = x, y = y, label = state.abb), 
              colour = 'black',size=4) +
    scale_fill_brewer(palette="Spectral") + 
    theme_opts
  #print(p)
  ggsave("sentiment_plot.png",width=16.510,height=10.668,units="cm")
}
