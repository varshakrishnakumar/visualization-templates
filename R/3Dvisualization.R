# Library imports
library(rgl)
library(png)
library(plotly)
library(lazyeval)
library(dplyr)



# Load output from a txt file and store in a dataframe
# Check that data is correct to relevant planetary information, and note that the data should not have a header. If there is one, change header to TRUE.
orbit <- read.table(file = "R\\output.txt", header = FALSE)

#read first column in table, store as time (seconds)
time <- orbit[c(1)]

#read second column in table, store as x-position (km)
x <- orbit[c(2)]

# #read third column in table, store as y-position (km)
y <- orbit[c(3)]

# #read fourth column in table, store as z-position (km)
z <- orbit[c(4)]

#store each column in a dataframe
orb = data.frame(xax = x, yax = y, zax = z)

xpos <- as.vector(x)
ypos <- as.vector(y)
zpos <- as.vector(z)



#Surface of Planet - Set Up

Radius = 6787    #specifiy planet's radius
# read a image containing surface of planet
img <- readPNG("R\\mars_surface.png")

# convert PNG to a raster array
if (exists("rasterImage")) { # can plot only in R 2.11.0 and higher
    plot(1:2, type='n')
    rasterImage(img,  1, 2, 2, 1, interpolate=FALSE)
}

img <- as.raster(img)

# Spherical Coordinate system to set up sphere model for planet
phi <- seq(0, pi, length = 200)
theta <- seq(0, 2*pi, length = 200)
x = Radius*outer(sin(phi),cos(theta))
y = Radius*outer(sin(phi),sin(theta))
z = Radius * (matrix(1, 200, 200)*cos(phi))


#Background of Visual; can comment out lines 58-83 if a white background is wanted
axx <- list(
  backgroundcolor="rgb(200, 200, 230",
  gridcolor="rgb(255,255,255)",
  showbackground=TRUE,
  title = 'x position',
  range = c(-9000, 9000),
  zerolinecolor="rgb(255,255,255"
)

axy <- list(
  backgroundcolor="rgb(230, 200,230)",
  gridcolor="rgb(255,255,255)",
  showbackground=TRUE,
  title = 'y position',
  range = c(-9000, 9000),
  zerolinecolor="rgb(255,255,255"
)

axz <- list(
  backgroundcolor="rgb(230, 230,200)",
  gridcolor="rgb(255,255,255)",
  showbackground=TRUE,
  title = 'z position',
  range = c(-9000, 9000),
  zerolinecolor="rgb(255,255,255"
)


# function to set up dataframe for cummulative animation
accumulate_by <- function(dat, var) {
  var <- f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  bind_rows(dats)
}


orbit <- data.frame(time = orbit[,c(1)], xpos = orbit[,c(2)], ypos = orbit[,c(3)], zpos = orbit[,c(4)])
df <- orbit %>% accumulate_by(~time)

# Set up interactive plot
base <- df %>%
  plot_ly(
    x = ~xpos, 
    y = ~ypos,
    z = ~zpos,
    frame = ~frame,
    color = ~frame,
    type = 'scatter3d',
    mode = 'lines',
    name = 'Orbit',
    line = list(simplyfy = F, width = 3),
    showscale = FALSE
  ) %>% layout(
    scene = list(xaxis = axx, yaxis = axy, zaxis = axz)
  ) %>% animation_opts(
    frame = 1 %/% 21900,
    easing = 'linear',
    transition = 1 %/% 20000
  )


# Set up surface of planet
surf <- plot_ly(x = ~x, y = ~y, z = ~z, colorscale = ~list(c(0, img[333,549]), c(1, img[222,898])), showscale = FALSE, showlegend = FALSE) %>% add_surface() %>%
  layout(
    scene = list(xaxis = axx, yaxis = axy, zaxis = axz)
  )


# Print combined subplot to html file
print(subplot(surf, base), "R")



