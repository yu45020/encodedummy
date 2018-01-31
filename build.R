# Build R package

library(devtools)
# set current directory to parent folder of project location
setwd("..")
install("encodedummy")

remove.packages('encodedummy')