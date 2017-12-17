\name{encodedummy_col}
\alias{encodedummy_col}
\title{Fast Encode Non-Numeric Variables into Dummy Columns}
\usage{
encodedummy_col(data, drop_first_level=FALSE,
keep_origin_cols=FALSE, sep_char='=', inplace=FALSE)
}
\description{
In a data frame, if there are columns in character or factor format, encodedummy_col can convert them into dummy columns, and each columns has either 1 or 0. Require data.table.
}

\arguments{

\item{data}{Either a data.frame or data.table}

\item{drop_first_level}{Whether drop the first level of category}

\item{keep_origin_cols}{Whether keep the input data's non-numeric columns}

\item{sep_char}{Character string between column names and unique category/level. Example: sep_char="=", and a column named 'Col A' with levels 'A','B'. Then the output columns will be named as 'Col A=A', 'Col A=B'.}

\item{inplace}{Whether modify the data directly. Input data will be converted into data.table, so FALSE means a new copy is created and added new dummy columns, while the input data is not changed. TRUE means the input data is modified directly in memory, so no new object will be created. Details can be found by ?data.table::copy}
}

\value{Returns a data.table object.}

\examples{
library(data.table)
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
# inplace is FALSE, so the input data is not modified.
# Instead, a new object is created.
identical(DT,DT_) # TRUE
identical(DT,DT_new)  # FALSE
}
