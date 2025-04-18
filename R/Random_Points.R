# function 8

random_points <- function(hex_grid, hex_id, n_points) {
  hex_polygon <- hex_grid[hex_grid$hex_id == hex_id, ]
  points <- st_sample(hex_polygon, size = n_points)
  return(st_sf(geometry = points))
}

# function 9

plot_random_points <- function(hex_grid, swf_clipped, hex_id, random_points) {
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  plot(st_geometry(selected_hex), border = "black", lwd = 2, main = paste("Hexagon", selected_hex$hex_id))
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
  plot(st_geometry(random_points), col = "red", pch = 16, cex = 0.6, add = TRUE)
}
