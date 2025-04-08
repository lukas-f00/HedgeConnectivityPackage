library(sf)
library(sp)
library(raster)

# Load data
swf_data <- raster("C:/Users/Chef/Documents/HedgeConnectivityPackage_Data/HRL_Small_Woody_Features_2018_005m.tif")
swf_vector <- rasterToPolygons(swf_data, fun = function(x) x > 0, dissolve = TRUE)
swf_sf <- st_as_sf(swf_vector)
#plot(swf_sf)

# Transform to a projected CRS if it's in lon/lat --> convert to meters
#if (st_is_longlat(swf_data)) {
#  swf_data <- st_transform(swf_data, 32632)
#}

# Create a hexagon grid
hex_grid <- st_make_grid(
  swf_sf,
  cellsize = 500,           # value here 500
  square = FALSE,
  what = "polygons"
)
hex_grid <- st_sf(geometry = hex_grid)
hex_grid$hex_id <- seq_len(nrow(hex_grid))  # Add IDs

# Clip data to hexagon grid
clipped_swf <- st_join(swf_sf, hex_grid, join = st_intersects)

# basic plots
plot(st_geometry(hex_grid), border = "grey")         # draw hexagons
plot(st_geometry(clipped_swf), col = "forestgreen", add = TRUE)  # draw clipped SWF

# specific hexagon
# Select hexagon from the hex grid
hex_11 <- hex_grid[hex_grid$hex_id ==11, ]

# Intersect SWF features with this hexagon
swf_in_hex11 <- st_intersection(swf_sf, hex_11)

plot(st_geometry(hex_11), border = "grey", lwd = 2, main = "SWF in Hexagon 11")
plot(st_geometry(swf_in_hex11), col = "forestgreen", add = TRUE)


