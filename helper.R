library(tidyverse)
library(tidyquant)




eps_processing <- function(data){


  data <- 
    data %>% 
    t() %>% 
    as_tibble()


  data <- 
    data %>% 
    add_column(
      period=c("curr_q", 
               "next_q", 
               "curr_y", 
               "next_y"), 
     .before="V1")



  colnames(data) <- 
    c("period", 
      "analysts", 
      "avg", 
      "low", 
      "high", 
      "y_ago")




  curr_price <- 
    symbol_data %>% 
    tail(1) %>% 
    select(adjusted) %>% 
    pull()


  data <- 
    data %>% 
    mutate(PE = 
          (curr_price / avg))


  data <- 
    data %>% 
    mutate(growth = 
          (avg / y_ago - 1))



  data <-
    data %>% 
    mutate(PEG = 
           PE / (growth*100))


  data <- 
    data %>%
    mutate(symbol = symbol)

  data <- 
    data %>%
    mutate(curr_price = curr_price)


  return(data)

}




get_returns_data <- function(symbol_data, benchmark_data){

  symbol_returns <- 
    symbol_data %>%  
    tq_transmute(select     = adjusted, 
                 mutate_fun = periodReturn, 
                 period     = "monthly", 
                 col_rename = "returns")


  benchmark_returns <- 
    benchmark_data %>%  
    tq_transmute(select     = adjusted, 
                 mutate_fun = periodReturn, 
                 period     = "monthly", 
                 col_rename = "returns") %>%
    rename(benchmark = returns)


  returns_data <- 
    symbol_returns %>% 
    left_join(benchmark_returns)


  return(returns_data)
}


add_capm <- function(data, returns_data, period){

  returns_data_sub <- 
    returns_data %>% 
    tail(period)

  model <- lm(returns ~ benchmark, 
              returns_data_sub)

  alpha <- 
    model %>% 
    coef() %>% 
    pluck(1)

  beta <- 
    model %>% 
    coef() %>% 
    pluck(2)

  data <- 
    data %>%
    mutate(alpha = alpha, 
           beta = beta)

  return(data)

}



add_macd <- function(data, symbol_data){

  symbol_data <- 
    symbol_data %>%  
    tq_mutate(select     = adjusted, 
              mutate_fun = MACD,
              nFast      = 12,
              nSlow      = 26,
              nSig       = 9,
              maType     = EMA,
              percent    = TRUE)

  symbol_data <- 
    symbol_data %>%
    mutate(macd_sig = macd - signal)

  macd_sig_now <- 
    symbol_data %>%
    select(macd_sig) %>%
    tail(1) %>% 
    pluck(1)

  data <- 
    data %>%
    mutate(macd_sig = macd_sig_now)



  return(data)
}



add_bbands <- function(data, symbol_data){

  symbol_data <- 
    symbol_data %>%  
    tq_mutate(select     = c(high, low, close), 
              mutate_fun = BBands,
              n = 20,
              maType = SMA,
              sd = 2)


  pctB_now <- 
    symbol_data %>%
    select(pctB) %>%
    tail(1) %>% 
    pluck(1)



  data <- 
    data %>% 
    mutate(pctB = pctB_now)

  return(data)

}


## sharpe


add_sharpe <- function(data, returns_data, period){

  returns_data_sub <- 
    returns_data %>% 
    tail(period)


  sharpe_res <- 
    returns_data_sub %>%
    tq_performance(
            Ra = returns, 
            Rb = NULL, 
            performance_fun = SharpeRatio, 
            annualize = TRUE
        ) %>%
        pluck(3)


   data <- 
    data %>%
    mutate(sharpe = sharpe_res)

  return(data)

}








