load_swf_data <- function(path) {
  swf_raster <- raster(path)
  swf_vector <- rasterToPolygons(swf_raster, fun = function(x) x > 0, dissolve = TRUE)
  swf_sf <- st_as_sf(swf_vector)
  return(swf_sf)
}

###########################################################################################

create_hex_grid <- function(swf_sf, cellsize) {
  hex_grid <- st_make_grid(swf_sf, cellsize = cellsize, square = FALSE, what = "polygons")
  hex_grid <- st_sf(geometry = hex_grid)
  coords <- st_coordinates(st_centroid(hex_grid))
  hex_grid$hex_id <- rank(-coords[,2]) * 1e6 + rank(coords[,1])
  hex_grid$hex_id <- rank(hex_grid$hex_id)
  return(hex_grid)
}
