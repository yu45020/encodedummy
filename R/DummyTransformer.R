dummy_transfer = function(dat) {
  if (class(dat)[1] != "data.table")
    warning('Input data must be data.table')
  
  # ---------   Return Function ----------
  
  transformer = function(dat,
                         cols = char_fact_cols,
                         code_book_ = code_book,
                         to = 'numeric', 
                         convert_to_fact=TRUE) {
    # cols: character / factor columns,
    # code_book: list of 2 lists: factor side , numeric side (same order )
    # to: either 'factor' or 'numeric'. 'factor' transform from numeric to factor
    
   if (class(dat)[1] != "data.table")
      warning('Input data must be data.table')
    
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
   }else{
     
     
     x = dat[, (cols):= mapply(setattr, .SD, name = 'levels', 
                               value = code_book_[[to]], SIMPLIFY = FALSE ), 
             .SDcols =cols]
     invisible(x)
   }  
    }
  #----------------------------------------
  
  col_classes = dat[, lapply(.SD, class)]
  char_fact_cols = names(dat)[col_classes == 'factor' | col_classes == 'character']
  
  if (identical(char_fact_cols, character(0))) {
    print("No factor/character cols")
    return(NULL)
    
  } else {
    # turn them into factor
    dat[, (char_fact_cols) := lapply(.SD, as.factor), .SDcols = char_fact_cols]
    
    # return a list of levels & digits for each col
    code_book_character = dat[, .(lapply(.SD, levels)), .SDcols = char_fact_cols]$V1
    names(code_book_character) = char_fact_cols
    
    code_book_numeric = lapply(code_book_character, function(x) as.character(1:length(x)))
    names(code_book_numeric) = char_fact_cols
    
    code_book = list('factor' = code_book_character, 'numeric' = code_book_numeric)
    
    transformer(dat, char_fact_cols, code_book, to = 'numeric', convert_to_fact=FALSE)
    setattr(dat, 'code_book', code_book)
    return(transformer)
    
  }
  
}
