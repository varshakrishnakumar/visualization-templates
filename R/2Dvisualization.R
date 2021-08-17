# This file is an R template to get a basic 2D static plot of user-specified data set up. 
# The example files used in this (example) template is "output.txt" for the plotting of the orbit.

# User Inputs:
#   file:  txt/csv file containing data


# Output:
#   static:  Static 2D plot of data in file


# Version: August 2021
# -------------------------------------------------

# Library Imports
library(car)
library(rgl)



# Load output from C++ code to R readable file as a table
# Check that data is correct to relevant planetary information
file <- "R\\output.txt"
orbit <- read.table(file, header = FALSE)

time <- orbit[c(1)]

# #read first column in table, store as x-position
x <- orbit[c(2)]

# #read second column in table, store as y-position
y <- orbit[c(3)]

# #read third column in table, store as z-position
z <- orbit[c(4)]

# #store each column in a df
orb = data.frame(xax = x, yax = y, zax = z)

xpos <- as.vector(x)
ypos <- as.vector(y)
zpos <- as.vector(z)

#2D orbit: uncomment print statement to view 2d orbit (y-z plane)

static <- plot(ypos[,], zpos[,], main="2D orbit", col='royalblue1')
print(static)






