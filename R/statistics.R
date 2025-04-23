# function 10
hedge_area <- function(swf_clipped, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  hedge_area <- sum(st_area(swf_clipped))
  hex_area <- st_area(selected_hex)
  ratio <- as.numeric(hedge_area / hex_area)
  percentage <- ratio * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " hedge area: ", round(hedge_area, 2), " ", units::deparse_unit(hedge_area)))
  print(paste0("Hexagon ", selected_hex$hex_id, " hedge area percentage: ", round(percentage, 2), "%"))
  return(list(hedge_area = hedge_area, ratio = ratio))
}

#######################################################################################

# function 11
count_hedge_obj <- function(swf_clipped, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_valid <- st_make_valid(swf_clipped)
  hex_valid <- st_make_valid(selected_hex)
  swf_in_hex <- st_intersection(swf_valid, hex_valid)
  buffered <- st_buffer(swf_in_hex, 0.01)
  dissolved <- st_union(buffered)
  dissolved <- st_buffer(dissolved, -0.01)
  individual_patches <- st_cast(dissolved, "POLYGON")
  patch_count <- length(individual_patches)
  print(paste0("Hexagon ", hex_id, " contains ", patch_count, " distinct hedge objects"))
  return(patch_count)
}

######################################################################################

# function 12
hedge_points_percentage <- function(swf_clipped, random_points, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  inside <- st_intersects(random_points, swf_clipped, sparse = FALSE)
  ratio <- sum(inside) / nrow(random_points)
  percentage <- ratio * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " percentage of points within hedge objects: ", round(percentage, 2), " %"))
  return(ratio)
}
