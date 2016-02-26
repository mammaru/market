library(RSQLite)
dbname="../data/stock/db/daily/2015.sqlite3"
driver=dbDriver("SQLite")
con=dbConnect(driver,dbname)

# get data
codes = dbGetQuery(con, "select code, name from names")
datings = dbGetQuery(con, "select id, date from datings")
closes = dbGetQuery(con, "select code, dating_id, close from prices")

#create dataframe
prices = data.frame(matrix(rep(NA,nrow(codes)*nrow(datings)),nrow=nrow(datings)))
colnames(prices) = codes["code"]
#rownames(prices) = datings["date"]

for(i in 1:nrow(datings)){ 
  s = subset(closes, dating_id==i)["close"]
  

}
