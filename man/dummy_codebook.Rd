\name{dummy_codebook}
\alias{create_code_book}
\alias{onehot_encoder}
\alias{update_code_book}
\title{Fast Onehot Encode Dummy Columns}
\usage{
create_code_book(dat)
onehot_encoder(dat, code_book=NULL, convert_to='numeric',update_book = FALSE)
update_code_book(code_book, dat)
}

\description{
In a data frame, if there are columns in character or factor format, create_code_book will create a code book for one-on-one match.

onehot_encoder will convert those columns into factor class but use numeric labels. If no code_book is provided, new code book will be created internally and add an attribute "code_book" to the input data. All changes are taken directly in the input date, so no copy will be made. To check it, use address(dat) before and after. They should be the same.


update_code_book with new input data will check whether there are new unique values and add them into the code book. It returns a code book and makes sure if new data with unknown type can be encoded.
}

\arguments{

\item{data}{data.table object}


\item{convert_to}{default is 'numeric'. Alternative is 'origin' that converts encoded data back to the origin. Mainly used for testing.}

\item{update_book}{If input data may have unknown type, set it to TRUE to update code book.}


\examples{
library(data.table)

if (!require("pacman")) install.packages("pacman")

pacman::p_load_gh("trinker/wakefield")


# generate random dataset

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
}

\examples{
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

}
