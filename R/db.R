library(quantmod)
library(RSQLite)
library(xts)

dbname <- "../data/stock/db/daily/2015.sqlite3"
driver <- dbDriver("SQLite")
con <- dbConnect(driver,dbname)

# get data
codes <- dbGetQuery(con, "select code, name from names")
datings <- dbGetQuery(con, "select id, date from datings")
closes <- dbGetQuery(con, "select code, dating_id, close from prices")
stock <- dbGetQuery(con, "select dating_id, open, high, low, close, volume from prices where code=1378")

stock <- merge(datings,stock,by.x="id",by.y="dating_id")[,-1]
rownames(stock) <- stock[,1]
stock <- stock[,-1]
as.xts(stock)

chartSeries(stock, subset="2015::2015-12", theme=chartTheme("white"), TA="addVo(); addBBands()")
reChart(subset="2015-11-01::2016-02-31")

#create dataframe
prices = data.frame(matrix(rep(NA,nrow(codes)*nrow(datings)),nrow=nrow(datings)))
colnames(prices) = codes["code"]
#rownames(prices) = datings["date"]

for(i in 1:nrow(datings)){ 
  s = subset(closes, dating_id==i)["close"]
  

}
