# function 10

hedge_area <- function(swf_clipped, hex_grid, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Calculating the total area of the clipped SWF data
  hedge_area <- sum(st_area(swf_clipped))
  # Calculating the area of the hexagon
  hex_area <- st_area(selected_hex)

  # Calculating the ratio and percentage of the SWF area to the hexagon area without units
  ratio <- as.numeric(hedge_area / hex_area)
  percentage <- ratio * 100

  # Printing and returning the overall hedge area and the area percentage
  print(paste0("Hexagon ", selected_hex$hex_id, " hedge area: ", round(hedge_area, 2), " ", units::deparse_unit(hedge_area)))
  print(paste0("Hexagon ", selected_hex$hex_id, " hedge area percentage: ", round(percentage, 2), "%"))
  return(list(hedge_area = hedge_area, ratio = ratio))
}

#######################################################################################

# function 11

count_hedge_obj <- function(swf_clipped, hex_grid, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  # Making geometries valid to prevent errors and keep data clean
  # Also clipping the data in case it wasn't done in a previous step
  swf_valid <- st_make_valid(swf_clipped)
  hex_valid <- st_make_valid(selected_hex)
  swf_in_hex <- st_intersection(swf_valid, hex_valid)

  # Buffering the data to merge neighbouring patches together and removing the buffer afterwards
  # Did not work without the buffer
  buffered <- st_buffer(swf_in_hex, 0.01)
  dissolved <- st_union(buffered)
  dissolved <- st_buffer(dissolved, -0.01)
  patches <- st_cast(dissolved, "POLYGON")

  # Counting the patches and printing the result
  patch_count <- length(patches)
  print(paste0("Hexagon ", hex_id, " contains ", patch_count, " distinct hedge objects"))
  return(patch_count)
}

######################################################################################

# function 12

hedge_points_percentage <- function(swf_clipped, random_points, hex_grid, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Getting the points INSIDE of hedge objects
  inside_points <- st_intersects(random_points, swf_clipped, sparse = FALSE)

  # Calculating and printing the ratio and percentage of points inside of hedge objects to all points
  ratio <- sum(inside_points) / nrow(random_points)
  percentage <- ratio * 100
  print(paste0("Hexagon ", selected_hex$hex_id, " percentage of points within hedge objects: ", round(percentage, 2), " %"))
  return(ratio)
}

######################################################################################

# function 13

# Only for points outside of hedge objects
distance_to_nearest_hedge <- function(swf_clipped, random_points, hex_grid, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  # Making geometries valid
  merged_hedges <- st_union(st_make_valid(swf_clipped))

  # If-loop for areas with 0 hedge objects
  if (length(merged_hedges) == 0) {
    print(paste0("Hexagon ", hex_id, " contains 0 hedge objects"))
    return(list(outside_points = list(mean = NA, min = NA, max = NA), units = NA))
  }

  # Calculating the distances from the random points to the nearest hedge boundary
  distances <- st_distance(random_points, st_boundary(merged_hedges))
  # Selecting only the points laying outside of the hedge objects
  outside_points <- !st_intersects(random_points, merged_hedges, sparse = FALSE)
  # Converting the distances to numeric values without units
  numeric_dist <- as.numeric(distances)

  # Storing the mean, minimum and maximum distances for points outside the hedges in a list
  results <- list(
    outside_points = list(
      mean = mean(numeric_dist[outside_points]),
      min = min(numeric_dist[outside_points]),
      max = max(numeric_dist[outside_points])
    ),
    units = attributes(distances)$units
  )

  # Printing the results
  # Using cat() instead of print() because of multi-line strings
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
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  # Making geometries valid
  # Also clipping the data in case it wasn't done in a previous step
  swf_in_hex <- st_intersection(st_make_valid(swf_clipped),
                                st_make_valid(selected_hex))
  # Buffering the data to merge neighbouring patches together and removing the buffer afterwards
  # Did not work without the buffer
  buffered <- st_buffer(swf_in_hex, 0.01)
  dissolved <- st_union(buffered)
  dissolved <- st_buffer(dissolved, -0.01)
  patches <- st_cast(dissolved, "POLYGON")

  # Getting the number of patches
  num_patches <- length(patches)

  # If-loop for hexagons with less than two patches
  if (length(patches) < 2) {
    message(paste0("Hexagon ", hex_id, " needs at least 2 patches, but only has " , length(patches)))
    return(list(mean = NA, min = NA, max = NA, units = NA))
  }

  # If-loop for a NN input that is higher than the available NN options
  if (nn >= length(patches)) {
    message(paste0("Hexagon ", hex_id, " has only ", length(patches), " patches with maximum ", length(patches)-1, " NN"))
    return(list(mean = NA, min = NA, max = NA, units = NA))
  }

  # Creating a line at the edge of the polygons for measuring the distances
  boundaries <- st_boundary(patches)
  # Creating a matrix with the distances between every polygon
  dist_matrix <- st_distance(boundaries)
  dist_numeric <- matrix(as.numeric(dist_matrix), nrow = num_patches)
  # Setting self-distance to NA instead of 0
  diag(dist_numeric) <- NA

  # For-loop to go through every distance and selecting the respectively shortest one
  all_distances <- c()
  for(i in 1:num_patches) {
    valid_dists <- sort(dist_numeric[i, ])[1:nn]
    all_distances <- c(all_distances, valid_dists)
  }

  # Storing the mean, minimum and maximum distances that were measured in the for loop in a list
  stats <- list(
    mean = mean(all_distances),
    min = min(all_distances),
    max = max(all_distances),
    units = attributes(dist_matrix)$units
  )

  # Printing the results
  cat(paste0(
    "Hexagon ", hex_id, " (",nn, ". NN):\n",
    "Mean distance: ", round(stats$mean, 2), " ", stats$units, "\n",
    "Min. distance: ", round(stats$min, 2), " ", stats$units, "\n",
    "Max. distance: ", round(stats$max, 2), " ", stats$units, "\n"
  ))
  return(stats)
}
