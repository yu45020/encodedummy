# ----------------- Decorator --------------------

# Similar to Python's @ decorator
`%@%` = function(decorator, func) {
    return(decorator(func))
}
# usage:
  # foo = decorator %@% function(...){}

# Time Decorator 

time_it = function(func, ...) {
    wrapper = function(...) {
        start_t = Sys.time()
        result = func(...)
        end_t = Sys.time()
        print("====================")
        print(sprintf("Total Runtime: %.2f seconds", end_t - start_t))
        return(result)
    }
    return(wrapper)
}
