

library(tidyverse)
library(tidyquant)

source("./helper.R")

# --- param -----------
save_data <- TRUE
# ---------------------

files <- 
  dir(path = "./scraped_data/", 
      pattern = "*processed.txt")


combined_data <- tibble()

benchmark_data <- tq_get("VOO")


for (file in files){

  filepath <- 
    paste0("./scraped_data/", file)

  data <- 
    read_delim(filepath, 
               " ", 
               col_names = FALSE)

  symbol <- 
    file %>% 
    str_split("_") %>%
    pluck(1,1)


  symbol_data <- tq_get(symbol)

  returns_data <- 
    symbol_data %>% 
    get_returns_data(benchmark_data)



  data <-
    data %>% 
    eps_processing() %>%
    add_capm(returns_data, period = 36) %>%
    add_sharpe(returns_data, period = 36) %>%
    add_macd(symbol_data) %>%
    add_bbands(symbol_data)




  combined_data <- 
    combined_data %>% 
    bind_rows(data)

}





combined_data <- 
  combined_data %>% 
  relocate(symbol,
           period, 
           PE,
           PEG, 
           growth,
           avg,
           alpha, 
           beta,
           sharpe,
           pctB,
           macd_sig)





# --- save combined data ---
if (save_data == TRUE){
  saveRDS(combined_data, file="eps.rds")
}


#data <- combined_data





