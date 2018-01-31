library(data.table)
library(encodedummy)


# /----------------
# Test 1: new data with new unique values 
# \----------------


df_test1 = data.table(
                      A = letters[1:3],
                      B = as.factor(LETTERS[11:13])
                      )

onehot_encoder(df_test1)
head(df_test1)
code_book_test1 = attr(df_test1, 'code_book')

df_test1_new = data.table(
                    A = as.factor(letters[1:3]),
                    B = LETTERS[20:22]
                          )

onehot_encoder(df_test1_new, code_book = code_book_test1, 
               update_book=TRUE)

head(df_test1_new)
# A=c(1,2,3), B=(NewType.T,NewType.U,NewType.V) 


# /------------------
# Test 2: self-defined code book
# \-------------------
# Note: this is useful when using K-Means to cluster some variables and apply the reuslt into new data 

df_test2 = data.table(
                      A = LETTERS[1:4],
                      B = c("AA", "BB", "CC", "DD"),
                      c = c("AAA", "AKB", "Fdd" ,"alsf")
                      )

code_book_test2 = list(
                       B = data.table(B = c("AA", "BB"),
                                      digits = c(111, 000)),
                        c = data.table(c = factor(c("AAA", 'AKB')),
                                       digits=c("sa",'12'))

                       )
onehot_encoder(dat=df_test2, code_book=code_book_test2, update_book = TRUE)

head(df_test2)
# A should not change, 
# B = c(111,000, NewType.CC, NewType.DD)
# c = c(sa, 12, NewType.Fdd, NewType.alsf
sapply(df_test2, class)
# character, factor , factor 
