library(RSQLite)
library(xts)

get_stock <- function(code, interval){
  date <- strsplit(interval, "::")[[1]]
  year1 <- substr(date[1], 1, 4)
  year2 <- substr(date[2], 1, 4)
  if(as.integer(year1)>as.integer(year2)){
    stop("Invalid interval is given")
  }
  year = year1
  stock <- numeric(0)
  while(1){
    dbname <- paste("../data/stock/db/daily/", year, ".sqlite3", sep="")
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


get_close <- function(interval){
  date <- strsplit(interval, "::")[[1]]
  year1 <- substr(date[1], 1, 4)
  year2 <- substr(date[2], 1, 4)
  if(as.integer(year1)>as.integer(year2)){
    stop("Invalid interval is given")
  }
  year = year1
  codes <- numeric(0)
  while(1){
    dbname <- paste("../data/stock/db/daily/", year, ".sqlite3", sep="")
    driver <- dbDriver("SQLite")
    con <- dbConnect(driver, dbname)
    codes <- rbind(codes, dbGetQuery(con, "select code, name from names"))
  }
  codes[!duplicated(codes$code), ]

  stock <- numeric(0)
  
  while(1){
    dbname <- paste("../data/stock/db/daily/", year, ".sqlite3", sep="")
    driver <- dbDriver("SQLite")
    con <- dbConnect(driver, dbname)

    # get data

    datings <- dbGetQuery(con, "select id, date from datings")
    closes <- dbGetQuery(con, "select code, dating_id, close from prices")
    query <- paste("select dating_id, open, high, low, close, volume from prices where code=", as.character(code), sep="")
    stock_tmp <- dbGetQuery(con, query)

    stock_tmp <- merge(datings, stock_tmp, by.x="id", by.y="dating_id")[,-1]
    rownames(stock_tmp) <- stock_tmp[,1]
    stock_tmp <- stock_tmp[,-1]
    if(year==year2){
      stock <- rbind(stock, stock_tmp)
      break
    }else{
      stock <- stock_tmp
      year <- year2
    }
  }
  stock <- as.xts(stock)
  return(stock[seq(as.Date(date[1]), as.Date(date[2]), by="days")])
}
