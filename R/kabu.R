#library(quantmod)
#sony1 <- getSymbols("6758.T", src="yahooj", auto.assign=FALSE)
#head(sony1)

#chartSeries(sony1, subset="2015::2015-04", theme=chartTheme("white"), TA="addVo(); addBBands()")
reChart(subset="2016-01-01::2016-02-31")

#library(RFinanceYJ)
#sony2 <- quoteStockTsData("6758.T", since="2016-01-01") 
#head(sony2)
