
create_code_book = function(dat) {
    # create a code book that has one-on-one match for non-numeric cols 
    # unique values are stored in factor, and numeric representations are in character
    # code book has attribute 'col_type' that store origin col's type
    
    ###         Code Book Format    ###
    # List: col_name = data.table( col_name, digits), ....
    #       (attribute: 'col_type'=input col's data type )



    if (class(dat)[1] != 'data.table') { stop("Input data must be data.table") }

    col_classes = dat[, lapply(.SD, class)]

    col_char = names(dat)[col_classes == 'character']
    col_fact = names(dat)[col_classes == 'factor']

    if (identical(col_char, character(0)) &
     identical(col_fact, character(0))) { stop('No factor/character cols') }

    code_book_c = dat[, .(lapply(.SD, unique)), .SDcols = col_char]$V1

    code_book_f = dat[, .(lapply(.SD, levels)), .SDcols = col_fact]$V1

    code_book_character = c(code_book_c, code_book_f)

    code_book_character = Map(factor,
                            x = code_book_character,
                            labels = code_book_character,
                            levels = code_book_character)

    names(code_book_character) = c(col_char, col_fact)

    code_book_numeric = lapply(code_book_character, function(x)
        as.character(1:length(x)))

    code_book = mapply(data.table,
                     code_book_character,
                     code_book_numeric,
                     SIMPLIFY = FALSE)
    #  set names

    Map(
    setnames,
    x = code_book,
    old = c('V1'),
    new = names(code_book)
  )

    Map(setnames,
      x = code_book,
      old = c('V2'),
      new = 'digits')

    # add attribute
    Map(setattr,
      x = code_book,
      name = 'col_type',
      value = c(rep('character', length(col_char)), rep('factor', length(col_fact))))

    return(code_book)
}

update_code_book = function(code_book, dat) {
    # update code_book for new data with the same col names. New cols will no be updated 
    # if there are unknown type, always use this function to update code book or in onehot_encoder set update_book=TRUE
    if (class(dat)[1] != "data.table") { stop('Input data must be data.table') }

    cols = names(code_book)
    new_unique = dat[, .(lapply(.SD, unique)), .SDcols = cols]$V1
    names(new_unique) = cols
    col_types = dat[, sapply(.SD, class)]

    # for loop to check each column
    for (col in cols) {
        origin_book = code_book[[col]]
        new_unique_f = new_unique[[col]]
        origin_book_f = origin_book[, get(col)]

        if (identical(new_unique_f, origin_book_f)) {
            print(sprintf("Column %s has no new unique values", col))

        } else {
            old_length = length(origin_book_f)
            col_type = col_types[col]

            if (col_type == 'character') {
                new_unique_f = factor(new_unique_f, labels = new_unique_f, levels = new_unique_f)

            }

            extra_types = Filter(function(x)!x %in% origin_book_f, x = new_unique_f)

            origin_book_f = unique(c(levels(origin_book_f), levels(new_unique_f)))
            origin_book_f = factor(origin_book_f, labels = origin_book_f, levels = origin_book_f)


            # update code book
            extra_length = length(origin_book_f) - old_length
            extra_types = sapply(extra_types, function(x) paste0("NewType.", x))
            code_book[[col]] = data.table(digits = c(as.character(code_book[[col]]$digits),
                              extra_types)
                              )
            code_book[[col]][, (col) := origin_book_f]

            print(sprintf("Column %s has %i new unique values.", col, extra_length))

        }
        # end of else
    }
    # end of for loop
    return(code_book)
}

onehot_encoder = time_it %@% function(dat, code_book = NULL,
                          convert_to = 'numeric',
                          update_book = FALSE) {


    # encode character/factor cols into numeric values (but are represented by factor type)
    # modification is taken directly to the input data. No additional copy will be made
    # check address(dat) before and after

    if (is.null(code_book)) {
        print("No code book provided. Create a new one.")
        code_book = create_code_book(dat)
        setattr(dat, 'code_book', code_book)
        print("Set 'code_book' attribute to the input data.")
    }

    if (isTRUE(update_book)) {
        code_book = update_code_book(code_book, dat)
        print("Code book has been updated.")

    }


    cols = names(code_book)
    cols = cols[cols %in% names(dat)]

    if (length(cols) == 0) {
        stop('Input data has no matching column and need to create a code book.')
    }


    col_fact_origin = lapply(cols, function(x) code_book[[x]][, get(x)])
    col_fact_numeric = lapply(code_book[cols], function(x) x[, digits])


    if (convert_to == 'numeric') {

        # change them into factor type
        dat[, (cols) := Map(
      factor,
      x = .SD,
      levels = col_fact_origin,
      labels = col_fact_numeric
    ),
        .SDcols = cols]

        # add attr
        setattr(dat,name='transformed',TRUE)

    } else if (convert_to == 'origin') {

        # check if all cols are factor: if data is transformed, its cols must be factor
        check_type = dat[, sapply(.SD, is.factor), .SDcols = cols]
        if (!all(check_type)) {
            stop("Character cols are detected. Transormed data cols must be factor.\n Use convert_to='numeric' or function onehot_encoder instead.")
        }

        col_type = sapply(code_book, attr, 'col_type')
        col_names = names(col_type)

        # change factor labels back to the origin
        dat[, (col_names) := Map(
      factor,
      x = .SD,
      levels = col_fact_numeric,
      labels = col_fact_origin
    ),
        .SDcols = col_names]

        # convert to character type if cols are in character type in the origin

        col_char = names(col_type)[col_type == 'character']

        if (length(col_char) > 0) {
            dat[, (col_char) := lapply(.SD, as.character), .SDcols = col_char]
        }

    }

   
    print("Done")
    invisible(dat)
}
