library(data.table)
library(pryr)
library(profvis)
source("DummyTransform.R")
library(onehot)
library(microbenchmark)


set.seed(1)
n = 1e6
dat = data.table(
  A = LETTERS[sample(26, n, replace = TRUE)],
  B = letters[sample(26, n, replace = TRUE)],
  #C = sample(100,n,replace=TRUE),
  #D = dnorm(n, 1, 4),
  E = c(LETTERS[sample(26, n/2, replace = TRUE)],
        letters[sample(26, n/2, replace = TRUE)])
)

object_size(dat)
dat = dat[,lapply(.SD,as.factor)]
dat2 = dat[sample(n,n*0.3), ]

dat_ = copy(dat)
dat2_ = copy(dat2)


dat_transfer = dummy_transfer(dat)
dat3 = dat_transfer(dat2)

encoder =onehot(dat_, max_levels = 100)
x = predict(encoder, dat2_)

dummy_transfer(dat)

onehot_t = function(dat){
  encoder = onehot(dat_, max_levels = 100)
  x = predict(encoder, dat2_)
  return(x)
}


microbenchmark(
  onehot_t(dat_),
  dummy_transfer(dat), 
  times=100
)

