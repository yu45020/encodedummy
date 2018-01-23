library(data.table)
library(pryr)

source('DummyTransform.R')

dat = data.table(
  A = LETTERS[sample(26, 100, replace = TRUE)],
  B = letters[sample(26, 100, replace = TRUE)],
  C = sample(100,100,replace=TRUE)
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


convert = function(dat, code_book){
  code_book = dat[,.(lapply(.SD,unique)),.SDcols=c("A","B")]$V1
  code_book
  names(code_book)=c("A","B")
  
  for(1 in 1:length(code_book)){
    code_ch = code_book[[i]]
    code_nu = code_book[[i]]
    col = names(code_book)[i]
    
    for(code_ in code_ch){
      dat[code_, (col):= ]
    }
    
  }
}
