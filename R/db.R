library(RSQLite)
library(xts)

get_stock <- function(code, interval){
  date <- strsplit(interval, "::")[[1]]
  year1 <- substr(date[1], 1, 4)
  year2 <- substr(date[2], 1, 4)
  if(as.integer(year1)>as.integer(year2)){
    stop("Invalid interval is given")
  }
  year <- year1
  stock <- numeric(0)
  while(1){
    dbname <- paste("../data/stock/", year, ".sqlite3", sep="")
    driver <- dbDriver("SQLite")
    con <- dbConnect(driver, dbname)

    # get data
    query <- paste("select dating_id, open, high, low, close, volume from prices where code=", as.character(code), sep="")
    stock_tmp <- dbGetQuery(con, query)
    datings <- dbGetQuery(con, "select id, date from datings")

    stock_tmp <- merge(datings, stock_tmp, by.x="id", by.y="dating_id")[,-1]
    rownames(stock_tmp) <- stock_tmp[,1]
    stock_tmp <- stock_tmp[,-1]
    stock <- rbind(stock, stock_tmp)
    if(year==year2){
      break
    }else{
      year <- as.character(as.integer(year) + 1)
    }
  }
  stock <- as.xts(stock)
  return(stock[seq(as.Date(date[1]), as.Date(date[2]), by="days")])
}

get_stocks <- function(interval){
  date <- strsplit(interval, "::")[[1]]
  year1 <- substr(date[1], 1, 4)
  year2 <- substr(date[2], 1, 4)
  if(as.integer(year1)>as.integer(year2)){
    stop("Invalid interval is given")
  }
  year <- year1
  all_stocks <- numeric(0)
  while(1){
    dbname <- paste("../data/stock/", year, ".sqlite3", sep="")
    driver <- dbDriver("SQLite")
    con <- dbConnect(driver, dbname)

    # get data
    query <- "select dating_id, code, close from prices"
    stocks <- dbGetQuery(con, query)
    datings <- dbGetQuery(con, "select id, date from datings")
    stocks <- merge(datings, stocks, by.x="id", by.y="dating_id")[,-1]
    all_stocks <- rbind(all_stocks, stocks)
    if(year==year2){
      break
    }else{
      year <- as.character(as.integer(year) + 1)
    }
  }
  #print(colnames(all_stocks))
  all_stocks <- reshape(all_stocks, timevar= "code", idvar="date", direction = "wide")
  rownames(all_stocks) <- all_stocks[,1]
  all_stocks <- all_stocks[,-1]
  colnames(all_stocks) <- as.vector(sapply(colnames(all_stocks), function(x){return(as.integer(strsplit(x,"\\.")[[1]][2]))}))
  all_stocks <- as.xts(all_stocks)
  return(all_stocks[seq(as.Date(date[1]), as.Date(date[2]), by="days")])
}
