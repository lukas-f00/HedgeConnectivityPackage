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
  patches <- st_cast(dissolved, "POLYGON")

  patch_count <- length(patches)
  print(paste0("Hexagon ", hex_id, " contains ", patch_count, " distinct hedge objects"))
  return(patch_count)
}

######################################################################################

# function 12
hedge_points_percentage <- function(swf_clipped, random_points, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  inside_points <- st_intersects(random_points, swf_clipped, sparse = FALSE)
  ratio <- sum(inside_points) / nrow(random_points)
  percentage <- ratio * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " percentage of points within hedge objects: ", round(percentage, 2), " %"))
  return(ratio)
}

######################################################################################

# function 13
# only points outside of hedges
distance_to_nearest_hedge <- function(swf_clipped, random_points, hex_grid, hex_id) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  merged_hedges <- st_union(st_make_valid(swf_clipped))
  if (length(merged_hedges) == 0) {
    print(paste0("Hexagon ", hex_id, " contains 0 hedge objects"))
    return(list(outside_points = list(mean = NA, min = NA, max = NA), units = NA))
  }
  distances <- st_distance(random_points, st_boundary(merged_hedges))
  outside_points <- !st_intersects(random_points, merged_hedges, sparse = FALSE)
  numeric_dist <- as.numeric(distances)
  results <- list(
    outside_points = list(
      mean = mean(numeric_dist[outside_points]),
      min = min(numeric_dist[outside_points]),
      max = max(numeric_dist[outside_points])
    ),
    units = attributes(distances)$units
  )
  cat(paste0(
    "Hexagon ", hex_id, ":\n",
    "Points outside of hedge objects:\n",
    "  Avg. distance to closest hedge: ", round(results$outside_points$mean, 2), " ", results$units, "\n",
    "  Min. distance to closest hedge: ", round(results$outside_points$min, 2), " ", results$units, "\n",
    "  Max. distance to closest hedge: ", round(results$outside_points$max, 2), " ", results$units, "\n"
  ))
  return(results)
}

######################################################################################

# function 14
hedges_nn <- function(swf_clipped, hex_grid, hex_id, nn) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_in_hex <- st_intersection(st_make_valid(swf_clipped),
                                st_make_valid(selected_hex))

  buffered <- st_buffer(swf_in_hex, 0.01)
  dissolved <- st_union(buffered)
  dissolved <- st_buffer(dissolved, -0.01)

  patches <- st_cast(dissolved, "POLYGON")
  num_patches <- length(patches)
  if (length(patches) < 2) {
    message(paste0("Hexagon ", hex_id, " needs at least 2 patches, but only has " , length(patches)))
    return(list(mean = NA, min = NA, max = NA, units = NA))
  }
  if (nn >= length(patches)) {
    message(paste0("Hexagon ", hex_id, " has only ", length(patches), " patches with maximum ", length(patches)-1, " NN"))
    return(list(mean = NA, min = NA, max = NA, units = NA))
  }
  boundaries <- st_boundary(patches)
  dist_matrix <- st_distance(boundaries)
  dist_numeric <- matrix(as.numeric(dist_matrix), nrow = num_patches)
  diag(dist_numeric) <- NA
  all_distances <- c()
  for(i in 1:num_patches) {
    valid_dists <- sort(dist_numeric[i, ])[1:nn]
    all_distances <- c(all_distances, valid_dists)
  }
  stats <- list(
    mean = mean(all_distances),
    min = min(all_distances),
    max = max(all_distances),
    units = attributes(dist_matrix)$units
  )
  cat(paste0(
    "Hexagon ", hex_id, " (",nn, ". NN):\n",
    "Mean distance: ", round(stats$mean, 2), " ", stats$units, "\n",
    "Min. distance: ", round(stats$min, 2), " ", stats$units, "\n",
    "Max. distance: ", round(stats$max, 2), " ", stats$units, "\n"
  ))
  return(stats)
}
