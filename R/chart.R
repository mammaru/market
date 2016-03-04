library(quantmod)
library(zoo)
library(TSclust)
source("db.R")

candle <- function(code, interval, type){
  #get data
  dat <- get_stock(code, interval)
  #dat <- getSymbols("6758.T", src="yahooj", auto.assign=FALSE) # from yahoo! japan
  if(type=="w"){
    dat <- dat[endpoints(dat, "weeks")]
  }else if(type=="m"){
    dat <- dat[endpoints(dat, "months")]
  }else if(type!="d"){
    stop("type must be \"d\", \"w\" or \"m\"")
  }
  # draw candle chart
  chartSeries(dat, subset="2015-01-01::2016-02-29", theme = chartTheme("white"), TA="addVo(); addBBands()")
}
