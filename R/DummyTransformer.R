dummy_transfer = function(dat) {
  if (class(dat)[1] != "data.table")
    warning('Input data must be data.table')

  # ---------   Return Function ----------

  transformer = function(dat,
                         code_book_ = code_book,
                         convert_to_fact=TRUE) {
    # cols: character / factor columns,
    # code_book: list of 2 lists: factor side , numeric side (same order )
    # (TODO)  to: either 'factor' or 'numeric'. 'factor' transform from numeric to factor

    if (class(dat)[1] != "data.table")
      stop('Input data must be data.table')

    for(code in code_book_){
      col_name_ = names(code)[1]
      dat = dat[code, on=col_name_]
      dat[,(col_name_):=NULL]
      setnames(dat, c(names(code)[2]), col_name_)
    }

    return(dat)
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

  code_book = mapply(data.table, code_book_character,code_book_numeric, SIMPLIFY = FALSE )
  mapply(setnames, x=code_book,c("V1"),names(code_book_character),SIMPLIFY = FALSE)


  dat = transformer(dat, code_book, convert_to_fact=FALSE)
  setattr(dat, 'code_book', code_book)
  setattr(dat, 'transformer', transformer)
  return(dat)


  }


