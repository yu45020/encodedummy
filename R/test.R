library(data.table)
library(pryr)

source('DummyTransformer.R')
n=1e6
dat = data.table(
  A = LETTERS[sample(10, n, replace = TRUE)],
  B = factor(letters[sample(10, n, replace = TRUE)]),
  C = LETTERS[sample(10, n, replace = TRUE)],
  D = factor(letters[sample(10, n, replace = TRUE)])
)

dat2 = dat[sample(10), ]

dat_ = copy(dat)

dat.transformer =  dummy_transfer(dat)

code_book = attr(dat,'code_book')
df = data.table(dat_$A, dat$A)
df = unique(df)
df = df[order(V2)]

dat3 = copy(dat2)
dat.transformer(dat2)
df2 = data.table(dat3$A, dat2$A)
df2 = unique(df2)
df2 = df2[order(V2)]

dafsdaf = function(){
  if(to=='numeric' & convert_to_fact){
    # get unique value for each col
    new_unique = dat[, .(lapply(.SD,unique)), .SDcols = cols]$V1

    for(i in 1:length(new_unique)){
      new_unique_1 = new_unique[[i]]
      code_book_1 = code_book_[['factor']][[i]]

      # if new data has more unique values
      if(length(new_unique_1)> length(code_book_1)){
        new_length = length(new_unique_1)
        code_book_[['factor']][[i]] = unique(c(code_book_1,new_unique_1 ))
        code_book_[['numeric']][[i]] = c(1:new_length)
      }else if (length(new_unique_1) < length(code_book_1)){
        # input data has fewer unique values, so subset the code book
        matched_unique = chmatch(new_unique_1 , code_book_1)
        code_book_[['factor']][[i]] = code_book_[['factor']][[i]][matched_unique]
        code_book_[['numeric']][[i]] = code_book_[['numeric']][[i]][matched_unique]
      }
    }

    # maintain the same order as the original data
    x = dat[, (cols):= mapply(factor,x=.SD , levels=code_book_[['factor']],
                              labels =code_book_[['numeric']], ordered=FALSE, SIMPLIFY = FALSE ),
            .SDcols=cols]
    invisible(x)
  }
}
