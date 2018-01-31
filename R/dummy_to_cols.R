dummy_to_cols = function(dat_, drop_first_level = FALSE, keep_origin_cols = FALSE, sep_char = '=', inplace = FALSE) {
  ## For data sets with columns that have dummy variables (characters & factors), this function create new
  ##  dummy columns with (1, 0).

  ## Helper functions ####
  .create_col_names = function(unique_level,col_to_encode,drop_first_level,sep_char){

    if(drop_first_level){
      unique_level = lapply(unique_level,FUN=function(x)x[-1])
    }

    col_names= mapply(paste, col_to_encode, unique_level,sep=sep_char,SIMPLIFY = FALSE)
    return(col_names)
  }

  .create_dummy_cols = function(col_,unique_level_percol,col_newname, dat){
    col_unique = unique_level_percol[[col_]]
    col_name = col_newname[[col_]]
    dat[,(col_name):=lapply(col_unique, chmatch, x=as.character(get(col_)),nomatch=0L)]
  }
  #####################


  dat_ = data.table(dat_)
    if(inplace){
    dat = dat_
  }else{
    dat = copy(dat_)
  }

  # get non-numeric column names
  col_attr = sapply(dat, is.numeric)
  col_to_encode = c(names(dat)[!col_attr])

  # get unique values for each columns
  unique_level_percol = dat[,.(lapply(.SD,unique)),.SDcols=col_to_encode]$V1
  names(unique_level_percol)= col_to_encode

  unique_level_percol = lapply(unique_level_percol,as.character) # make sure no factor

  unique_level_percol = lapply(unique_level_percol,sort) #sort order

  # get newe column names with unique value e.g. col1=type A
  col_newname = .create_col_names(unique_level_percol,col_to_encode,drop_first_level,sep_char)

  for(col_ in col_to_encode){
    .create_dummy_cols(col_,unique_level_percol,col_newname, dat)
  }

  if(! keep_origin_cols){
    dat[,(col_to_encode):=NULL]
  }

  return(dat)
}

