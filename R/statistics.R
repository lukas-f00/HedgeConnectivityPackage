# function 10
hedge_area_percentage <- function(swf_clipped, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  hedge_area <- sum(st_area(swf_clipped))
  hex_area <- st_area(selected_hex)
  percentage <- as.numeric(hedge_area / hex_area) * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " hedge area percentage: ", round(percentage, 2), "%"))
  return(percentage)
}

#######################################################################################

# function 11
count_hedge_objects <- function(swf_clipped, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_valid <- st_make_valid(swf_clipped)
  hex_valid <- st_make_valid(selected_hex)
  swf_in_hex <- st_intersection(swf_valid, hex_valid)
  if (nrow(swf_in_hex) == 0) {
    message(paste("Hexagon", hex_id, "contains 0 hedge objects"))
    return(0L)
  }
  dissolved <- st_union(swf_in_hex)
  individual_patches <- st_cast(dissolved, "POLYGON")
  patch_count <- length(individual_patches)
  print(paste0("Hexagon", hex_id, "contains", patch_count, "distinct hedge objects"))
  return(patch_count)
}

######################################################################################

# function 12
hedge_points_percentage <- function(swf_clipped, random_points, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  inside <- st_intersects(random_points, swf_clipped, sparse = FALSE)
  percentage <- sum(inside) / nrow(random_points) * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " percentage of points within swf-objects: ", round(percentage, 2), "%"))
  return(percentage)
}

######################################################################################
