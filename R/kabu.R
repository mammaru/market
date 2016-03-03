library(quantmod)
library(zoo)
library(TSclust)
source("db.R")

# get data
daily <- get_stock(3393, "2014-01-01::2016-02-29")
weekly <- daily[endpoints(daily, "weeks")]
monthly <- daily[endpoints(daily, "months")]
#daily <- getSymbols("6758.T", src="yahooj", auto.assign=FALSE) # from yahoo! japan

#stocks <- get_stocks("2015-01-01::2016-02-29")


# draw candle chart
chartSeries(weekly, subset="2014-01-01::2016-02-29", TA="addVo(); addBBands()")
reChart(subset="2015-10-01::2016-02-29")

#draw cluster dendrogram
data <- na.spline(stocks[1:50,1000:1100])
data <- scale(apply(data, c(1,2), log))

#data <- na.approx(stocks) # linear
#data <- na.locf(stocks)
#data <- na.locf(stocks, fromLast = TRUE)
d <- diss(t(data), "DTWARP")
h <- hclust(d)
par(cex=0.6)
plot(h, hang = -1)
