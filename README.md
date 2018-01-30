# Encodedummy

## Description
Simple R package to fast encode non-numeric variables. It is useful when preparing long datasets for Ridge/Lasso functions in glmnet package or other models that require input data to be numeric data.frames or matrices. Currently it provides 2 functions: transforming each unique dummy into columns that have 1 or 0; onehot encoder and creates a code book for unique character/factor --- numeric representation 

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
Data.table and its function "chmatch" for fast matching unique categories.


## Usage

1 . Convert dummies into new columns
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
  DT_new <- dummy_to_cols(DT, drop_first_level=FALSE, 
  keep_origin_cols=FALSE, sep_char='=',inplace=FALSE)
)
# inplace is FALSE, so the input data is not modified. Instead, a new object is created.
identical(DT,DT_) # TRUE
identical(DT,DT_new)  # FALSE
```
2 . Encoder

It contains three parts:
    1. create a code book for each character/factor column: all unique values have one unique number.
    2. encode those columns into factor type and numerical labels. Changes are taken 'in place' (memory address is not changed), so no copies are made internally.
    3. update code book for new data when there are unknown unique type
```
# generate random dataset
library(wakefield)
library(data.table)
library(encodedummy)

n = 1e6
df = r_data_frame(
  n = n,
  id,
  Scoring = rnorm,
  Smoker = valid,
  `Reading(mins)` = rpois(lambda=20),
  race,
  age(x = 8:14),
  sex,
  hour,
  iq,
  height(mean=50, sd = 10),
  died
)

df = data.table(df)
before = address(df)

s = sample(n,200)
df1 = copy(df[s,])
df_origin = copy(df)


code_book = create_code_book(df)
onehot_encoder(df,code_book)
address(df) ==before # TRUE

df_back = copy(df)
onehot_encoder(df_back, code_book, convert_to = 'origin')
identical(df_origin,df_back ) # TRUE


onehot_encoder(df1,code_book)
identical(df[s,],df1) # TRUE

# suppose new data has additional unique values
dat = data.table(
  A = letters[1:3],
  B = factor(LETTERS[1:3])
)
dat2 = data.table(
  A = factor(letters[6:9]),
  B = factor(LETTERS[6:9])
)
code_book = create_code_book(dat)
onehot_encoder(dat, code_book)


code_book_2 = update_code_book(code_book, dat2)
# or use onehot_encoder(dat2, code_book, update_book=TRUE)
onehot_encoder(dat2, code_book_2)
# new numeric values are added

```
