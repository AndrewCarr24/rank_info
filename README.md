## rank_info
R Implementation of bias-corrected rank-ordered information theory index from Logan et al. 2018.

rank_info function takes 2 arguments - 
df - tibble/dataframe containing grouped income data (counts in income brackets), followed by column giving unweighted sample counts.
grouping_var - vector with MSA ids for grouping rows of tibble in first argument.

The function returns a tibble with MSA column (grouping var ids) and bias-corrected income segregation for each MSA.


#### Example - Computes income segregation based on two income groups (high and low) for MSA "a"  
``` r
rank_info(df = tibble(low = c(130, 50,10), high = c(20,10,110), sample_counts = c(30, 15, 25)), grouping_var = c('a', 'a', 'a'))
```

#### References 
Reardon, Sean F., Kendra Bischoff, Ann Owens, and Joseph B. Townsend. 2018. “Has Income Segregation Really Increased? Bias and Bias Correction in Sample-Based Segregation Estimates.” Demography 55(6):2129–60.
