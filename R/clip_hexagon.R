# function 1

load_swf_data <- function(path) {
  # Loading in the raster data and converting it to polygons, then to a sf-object
  swf_raster <- raster(path)
  swf_vector <- rasterToPolygons(swf_raster, fun = function(x) x > 0, dissolve = TRUE)
  swf_sf <- st_as_sf(swf_vector)
  return(swf_sf)
}

###########################################################################################

# function 2

create_hex_grid <- function(swf_sf, diameter) {
  # Creating a hexagon grid with given cellsize and converting it to a sf-object
  hex_grid <- st_make_grid(swf_sf, cellsize = diameter, square = FALSE, what = "polygons")
  hex_grid <- st_sf(geometry = hex_grid)

  # getting the coordinates of the centroids
  coords <- st_coordinates(st_centroid(hex_grid))
  # Assingning a ID to each hexagon and ranking them in consecutive order
  hex_grid$hex_id <- rank(-coords[,2]) * 1e6 + rank(coords[,1])
  hex_grid$hex_id <- rank(hex_grid$hex_id)
  return(hex_grid)
}

############################################################################################

# function 3

plot_hex_ids <- function(hex_grid) {
  # Plotting the hexagons and adding the IDs into them
  plot(st_geometry(hex_grid), border = "black", main = "Hexagon IDs")
  text(st_coordinates(st_centroid(hex_grid)),
       labels = hex_grid$hex_id,
       cex = 0.7, col = "blue")
}

###########################################################################################

# function 4

swf_grid <- function(swf_sf, hex_grid) {
  # Clipping the SWF-data with the hexagon grid
  swf_clipped <- st_join(swf_sf, hex_grid, join = st_intersects)
  return(swf_clipped)
}

##########################################################################################

# function 5

plot_swf_grid <- function(hex_grid, swf_clipped) {
  # Plotting the hexgon grid with the SWF data on top
  plot(st_geometry(hex_grid), border = "grey", main = "Hexagon grid over hedge data")
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}

##########################################################################################

# function 6

clip_swf_to_hex <- function(swf_sf, hex_grid, hex_id) {
  # Selecting a hexagon via its ID and clipping the SWF data with it
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_clipped <- st_intersection(swf_sf, selected_hex)
  return(swf_clipped)
}

#########################################################################################

# function 7

plot_swf_hex <- function(hex_grid, swf_clipped, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Plotting the hexagon together with the accordingly clipped SWF data
  plot(st_geometry(selected_hex), border = "black", lwd = 2, main = paste("Small Woody Features in Hexagon", selected_hex$hex_id))
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}
