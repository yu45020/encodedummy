# Encodedummy

## Description
Simple R package to fast encode non-numeric variables into dummy columns. It is useful when preparing data for Ridge/Lasso in glmnet package or other models that require input data to be numeric data.frames or matrices. 

## Installing

1. In R, type 
    ```
    # check whether devtools is installed. If not, install it. 
    if ( !("devtools" %in% installed.packages()[,"Package"]) ){ 
        install.packages("devtools")
        }

    devtools::install_github("yu45020/encodedummy")
    ```

## Require Package
Data.table


## Usage
``` R 
library(data.table)
library(encodedummy)

get_test_data=function(N=1e5,K=6){
   set.seed(1)
   DT <- data.table(
     id1 = factor(sample(letters[1:K], N, TRUE)),
     id3 = factor(sample(LETTERS[1:K], N, TRUE)),
     id4 = sample(K, N, TRUE),
     id5 = factor(sample(K, N, TRUE)),
     id6 = sample(N/K, N, TRUE),
     v1 =  factor(sample(5, N, TRUE)),
     v3 =  sample(round(runif(100,max=100),4), N, TRUE)
  )
 }

DT = get_test_data(1e5,6)
DT_ = copy(DT)
print(format(object.size(DT), units = 'Mb'))

# number of unique values in each column
print(DT[,lapply(.SD, uniqueN)])
system.time(
  DT_new <- encodedummy_col(DT, drop_first_level=FALSE, 
  keep_origin_cols=FALSE, sep_char='=',inplace=FALSE)
)
# inplace is FALSE, so the input data is not modified. Instead, a new object is created.
identical(DT,DT_) # TRUE
identical(DT,DT_new)  # FALSE
```
