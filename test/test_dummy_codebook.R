library(data.table)
library(dummy_codebook)
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
