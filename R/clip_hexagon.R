library(sf)
library(sp)
library(raster)

# Load data
# converting a raster to a vector file
swf_data <- raster("C:/Users/Chef/Documents/HedgeConnectivityPackage_Data/HRL_Small_Woody_Features_2018_005m.tif")
swf_vector <- rasterToPolygons(swf_data, fun = function(x) x > 0, dissolve = TRUE)
swf_sf <- st_as_sf(swf_vector)
#plot(swf_sf)

# Transform to a projected CRS if in lon/lat -> convert to meters
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
# Assign sequential IDs starting top-left, row by row
coords <- st_coordinates(st_centroid(hex_grid))
hex_grid$hex_id <- rank(-coords[,2]) * 1e6 + rank(coords[,1])  # temp sort key
hex_grid$hex_id <- rank(hex_grid$hex_id)  # final IDs from 1 to n

# Plot the hexagons to see if numeration worked
#plot(st_geometry(hex_grid), border = "grey", main = "Hexagon IDs")
#text(st_coordinates(st_centroid(hex_grid)),
#     labels = hex_grid$hex_id,
#     cex = 0.7, col = "blue")

# Clip data to hexagon grid
clipped_swf <- st_join(swf_sf, hex_grid, join = st_intersects)

# basic plots
plot(st_geometry(hex_grid), border = "grey")         # plot hexagons
plot(st_geometry(clipped_swf), col = "forestgreen", add = TRUE)  # plot clipped SWF

# Clip data with specific hexagon
# Select hexagon by hex_id (e.g. ID 11)
selected_hex <- hex_grid[hex_grid$hex_id == 11, ]
# Clip data to the selected hexagon
swf_clipped_to_hex <- st_intersection(swf_sf, selected_hex)
# (Optional) Plot to verify
plot(st_geometry(selected_hex), border = "black", lwd = 2, main = "SWF in Selected Hexagon")
plot(st_geometry(swf_clipped_to_hex), col = "forestgreen", add = TRUE)

# Plot a specific hexagon
hex_11 <- hex_grid[hex_grid$hex_id ==11, ]
swf_in_hex11 <- st_intersection(swf_sf, hex_11)
plot(st_geometry(hex_11), border = "grey", lwd = 2, main = "SWF in Hexagon 11")
plot(st_geometry(swf_in_hex11), col = "forestgreen", add = TRUE)















