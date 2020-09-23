# NOTE - function takes purrr and magrittr as dependencies 
#
#
# Rank order information theory index - rank_info
#
# Takes - 2 arguments
# df - tibble/dataframe containing grouped income data (counts in income brackets), followed by column giving unweighted sample counts 
# grouping_var - vector with MSA ids for grouping rows of tibble in first argument
#
# Returns - Tibble with MSA column (grouping var ids) and bias-corrected income segregation for each MSA
#
# ##########
#
# Example - Computes income segregation based on two income groups (high and low) for MSA a  
# rank_info(df = tibble(low = c(130, 50,10), high = c(20,10,110), sample_counts = c(30, 15, 25)), 
# grouping_var = c('a', 'a', 'a'))
#
#
#
rank_info <- function(df, grouping_var){
  
  incomes_by_msa_list <- split(df , grouping_var)
  
  inc_seg <- map(incomes_by_msa_list, function(list_item){
    
    n_j <- list_item[,length(list_item)] %>% unlist %>% unname
    list_item <- list_item[,-length(list_item)]
    
    msa_list <- list_item %>% na.omit() %>% as.matrix() %>% split(., seq(nrow(.))) %>% unname
    
    p = (cumsum(Reduce(`+`,msa_list))/sum(Reduce(`+`,msa_list))) %>% .[1:(length(.)-1)]
    
    # Computing bias component B
    t_j <- list_item %>% rowSums()
    t_bar <- mean(t_j)
    r_j <- n_j/t_j
    r_harm <- harmonic_mean(r_j)
    z <- 1 + (1/t_bar)*((t_bar-1)/harmonic_mean(t_j-1) - 1)
    B <- get_bias(z, t_bar, r_harm)
    
    h_df <- tibble(p = p, p2 = p^2, p3 = p^3, p4 = p^4, wts = entropy(p), h = h_p(msa_list) - B/(2*entropy(p)))
    
    coefs <- lm(h ~ p + p2 + p3 + p4, data = h_df, weights = wts)$coef %>% unname
    
    mults <- c(1, .5, map(2:4, function(m){
      2/(m+2)^2 + 2*sum(map(0:m, function(n){
        ((-1)^(m-n)*choose(m,n))/((m-n+2)^2)}) %>% unlist)}) %>% unlist)
    
    sum(mults*coefs, na.rm = T)
  }) %>% unname %>% unlist 
  
  return(tibble(MSA = names(incomes_by_msa_list), inc_seg = inc_seg))

}


#### Utils ####


# Takes vector and returns harmonic mean
harmonic_mean <- function(r_vec){
  n <- length(r_vec)
  return((sum(r_vec^(-1))/n)^(-1))
}

# Computing bias term for income segregation
get_bias <- function(z, t_bar, r_harm){
  return((z/(t_bar-1))*((1-r_harm)/r_harm))
}

# Takes vector of counts and returns props of total counts below
inc_props <- function(inc_counts){
  if(all(inc_counts == 0)){return(rep(0, length(inc_counts)-1))}else{
    (cumsum(inc_counts)/sum(inc_counts)) %>% .[1:(length(.)-1)]}
}

# Computes entropy
entropy <- function(p){
  map(p, function(x){
    if(x == 1| x == 0){return(0)}else{return(x*log(1/x, base = 2) + (1-x)*log(1/(1-x), base = 2))}
  }) %>% unlist
}

# Traditional information theory index
h_p <- function(incomes_list){
  
  inc_tots <- Reduce(`+`, incomes_list)
  denom <- entropy(inc_props(inc_tots))*sum(inc_tots)
  
  num <- incomes_list %>% map(., function(x){
    sum(x)*(x %>% inc_props %>% entropy)
  }) %>% Reduce(`+`, .)
  
  return(1 - num/denom)
}
