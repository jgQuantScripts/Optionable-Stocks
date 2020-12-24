require("httr");require("dplyr");require("purrr")
# ************************
# get Optionable tickers
# ************************
# page url
pg <- html_session("https://www.barchart.com/options/stocks-by-sector?page=1")
# save page cookies
cookies <- pg$response$cookies
# Use a named character vector for unquote splicing with !!!
token <- URLdecode(dplyr::recode("XSRF-TOKEN", !!!setNames(cookies$value, 
                                                           cookies$name)))
# get data by passing in url and cookies
pg <- 
  pg %>% rvest:::request_GET(
    paste0("https://www.barchart.com/proxies/core-api/v1/quotes/get?lists=",
           "stocks.optionable.by_sector.all.us&",
           "fields=symbol%2CsymbolName%2ClastPrice%2CpriceChange%2CpercentChange",
           "%2ChighPrice%2ClowPrice%2Cvolume%2CtradeTime%2CsymbolCode%2CsymbolType",
           "%2ChasOptions&orderBy=symbol&orderDir=asc&meta=field.shortName",
           "%2Cfield.type%2Cfield.description&hasOptions=true&page=1",
           "&limit=1000000&raw=1"),
    config = httr::add_headers(`x-xsrf-token` = token)
  )

# raw data
data_raw <- httr::content(pg$response)
# convert into a data table
data <- 
  purrr::map_dfr(
    data_raw$data,
    function(x){
      as.data.frame(x$raw)
    }
  )
# fix time 
data$tradeTime = as.POSIXct(data$tradeTime, origin="1970-01-01")
