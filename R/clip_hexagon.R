
# function 1
load_swf_data <- function(path) {
  swf_raster <- raster(path)
  swf_vector <- rasterToPolygons(swf_raster, fun = function(x) x > 0, dissolve = TRUE)
  swf_sf <- st_as_sf(swf_vector)
  return(swf_sf)
}

###########################################################################################

# function 2
create_hex_grid <- function(swf_sf, cellsize) {
  hex_grid <- st_make_grid(swf_sf, cellsize = cellsize, square = FALSE, what = "polygons")
  hex_grid <- st_sf(geometry = hex_grid)
  coords <- st_coordinates(st_centroid(hex_grid))
  hex_grid$hex_id <- rank(-coords[,2]) * 1e6 + rank(coords[,1])
  hex_grid$hex_id <- rank(hex_grid$hex_id)
  return(hex_grid)
}

############################################################################################

# function 3
plot_hex_ids <- function(hex_grid) {
  plot(st_geometry(hex_grid), border = "black", main = "Hexagon IDs")
  text(st_coordinates(st_centroid(hex_grid)),
       labels = hex_grid$hex_id,
       cex = 0.7, col = "blue")
}

###########################################################################################

# function 4
clip_swf_to_grid <- function(swf_sf, hex_grid) {
  swf_clipped <- st_join(swf_sf, hex_grid, join = st_intersects)
  return(swf_clipped)
}

##########################################################################################

# function 5
plot_swf_grid <- function(hex_grid, swf_clipped) {
  plot(st_geometry(hex_grid), border = "grey")
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}

##########################################################################################

# function 6
clip_swf_to_hex <- function(swf_sf, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_clipped <- st_intersection(swf_sf, selected_hex)
  return(swf_clipped)
}

#########################################################################################

# function 7
plot_swf_hex <- function(hex_grid, swf_clipped, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  plot(st_geometry(selected_hex), border = "black", lwd = 2, main = paste("SWF in Hexagon", selected_hex$hex_id))
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}



