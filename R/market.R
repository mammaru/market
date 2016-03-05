source("chart.R")

code <- 3583
interval <- "2011-01-01::2016-12-31"
stock <- get_stock(code, interval)
candle(code, interval, "w")
#reChart(subset="2015-10-01::2016-02-29")
plot(dat[,as.character(code)],type="b")


# get data
#stocks <- get_stocks("2015-01-01::2016-02-29")
stocks_weekly <- stocks[endpoints(stocks, "weeks")]
stocks_monthly <- stocks[endpoints(stocks, "months")]

#draw cluster dendrogram
#dat <- na.approx(stocks) # linear
dat <- na.spline(stocks_weekly[,1000:1100])
dat <- scale(apply(dat, c(1,2), log))
dat <- na.locf(dat)
#dat <- na.locf(stocks, fromLast = TRUE)


dmat <- diss(t(dat), "DTWARP")
h <- hclust(dmat)
par(cex=0.6, bg="white")
plot(h, hang = -1)
rect.hclust(h, k=10, border="red")


