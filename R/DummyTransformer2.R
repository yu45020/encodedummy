dummy_transfer = function(dat) {
  if (class(dat)[1] != "data.table")
    warning('Input data must be data.table')

  # ---------   Return Function ----------

  transformer = function(dat,
                         code_book_ = code_book,
                         check_code_book=TRUE) {
    # cols: character / factor columns,
    # code_book: list of 2 lists: factor side , numeric side (same order )
    # (TODO)  to: either 'factor' or 'numeric'. 'factor' transform from numeric to factor

   if (class(dat)[1] != "data.table")
      stop('Input data must be data.table')

   if(check_code_book){
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
   }else{

     cols_names = names(code_book_[['factor']])

     dat[,(cols_names):=lapply(.SD, as.character), .SDcols=cols_names]
     for(i in 1:length(code_book_[['factor']])){

       code_f = code_book_[['factor']][[i]]
       code_n = code_book_[['numeric']][[i]]
       col_name = cols_names[i]
       for(j in 1:length(code_f)){

         dat[code_f[j],(col_name):= code_n[j],on=col_name, verbose=TRUE]

       }

     }

   }
    }
  #----------------------------------------

  col_classes = dat[, lapply(.SD, class)]
  cols_char = names(dat)[col_classes == 'character']
  cols_fact = names(dat)[col_classes == 'factor' ]

  # check unique values

  # return a list of levels & digits for each col
  code_book_character_f = dat[, .(lapply(.SD, levels)), .SDcols = cols_fact]$V1
  code_book_character_c = dat[, .(lapply(.SD, unique)), .SDcols =cols_char ]$V1

  code_book_character = c(code_book_character_f,char_cols = code_book_character_c)
  names(code_book_character) = c(cols_fact, cols_char)

  code_book_numeric = lapply(code_book_character, function(x) as.character(1:length(x)))

  code_book = list('factor' = code_book_character, 'numeric' = code_book_numeric)

  transformer(dat, code_book, check_code_book=FALSE)
  setattr(dat, 'code_book', code_book)
  return(transformer)


  }


