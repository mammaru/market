library(quantmod)
library(zoo)
library(TSclust)
source("db.R")

#stock <- get_stock(1001,"2014-01-01::2016-02-29")
#chartSeries(stock, subset="2014-01-01::2016-02-29", theme=chartTheme("white"), TA="addVo(); addBBands()")
#reChart(subset="2014-01-01::2016-02-29")

#stocks <- get_stocks("2015-01-01::2016-02-29")
tmp <- stocks[,1000:1500]
#d <- na.approx(stocks)
data <- na.locf(tmp)
data <- na.locf(data, fromLast = TRUE)
d <- diss(t(data), "DTWARP")
h <- hclust(d)
par(cex=0.6)
plot(h, hang = -1)



#sony <- getSymbols("6758.T", src="yahooj", auto.assign=FALSE)
#head(sony)
#chartSeries(sony1, subset="2015::2015-04", theme=chartTheme("white"), TA="addVo(); addBBands()")
#reChart(subset="2015-11-01::2016-02-31")


#library(RFinanceYJ)
#sony2 <- quoteStockTsData("6758.T", since="2016-01-01") 
#head(sony2)


#create dataframe
#prices = data.frame(matrix(rep(NA,nrow(codes)*nrow(datings)),nrow=nrow(datings)))
#colnames(prices) = codes["code"]
#rownames(prices) = datings["date"]

#for(i in 1:nrow(datings)){ 
  #s = subset(closes, dating_id==i)["close"]
#}
