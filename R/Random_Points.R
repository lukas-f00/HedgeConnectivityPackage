#' Function 8: Creating random points
#'
#' @param hex_grid The hexagon grid; created in function 2: create_hex_grid()
#' @param hex_id   The ID of the hexagon that should be selected
#' @param n_points The number of random points
#'
#' @returns        Random points over the extent of the selected hexagon are created
#' @export
#'
#' @examples       random_points("my_grid", "11", "20")
#' @examples       random_points(hex_grid = "my_grid", hex_id = "15", n_points = "100")


random_points <- function(hex_grid, hex_id, n_points) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  # Creating n (n_points) random points over it
  points <- st_sample(selected_hex, size = n_points)
  return(st_sf(geometry = points))
}

#########################################################################################

#' Function 9: Plotting random points over clipped SWF data
#'
#' @param hex_grid      The hexagon grid; created in function 2: create_hex_grid()
#' @param swf_clipped   The clipped SWF data; created in function 4: swf_grid()
#' @param hex_id        The ID of the hexagon that should be selected
#' @param random_points The random points; created in function 8: random_points()
#'
#' @returns             The random points get plotted over the selected SWF data clip
#' @export
#'
#' @examples            plot_random_points("my_grid", "data_clip", "11", "my_points")
#' @examples            plot_random_points(hex_grid = "my_grid", swf_clipped = "data_clip", hex_id = "11", random_points = "my_points")


plot_random_points <- function(hex_grid, swf_clipped, hex_id, random_points) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Plotting the selected hexagon with the matching SWF data and points on top
  plot(st_geometry(selected_hex), border = "black", lwd = 2, main = paste("Hexagon ", selected_hex$hex_id, " - random points over hedge areas"))
  plot(st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
  plot(st_geometry(random_points), col = "red", pch = 16, cex = 0.6, add = TRUE)
}
