#' Function 8: Creating random points
#'
#' @param hex_grid An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#' @param hex_id   Numeric. ID of the selected hexagon
#' @param n_points Numeric. Number of random points
#'
#' @returns        An `sf` object of random points
#' @export
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 random_points(my_grid, 11, 20)
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 random_points(hex_grid = my_grid, hex_id = 15, n_points = 25)


random_points <- function(hex_grid, hex_id, n_points) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  # Creating n (n_points) random points over it
  points <- sf::st_sample(selected_hex, size = n_points)
  return(sf::st_sf(geometry = points))
}

#########################################################################################

#' Function 9: Plotting random points over clipped SWF data
#'
#' @param hex_grid      An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#' @param swf_clipped   An `sf` object of clipped SWF polygons; created in function 4: swf_grid()
#' @param hex_id        Numeric. ID of the selected hexagon
#' @param random_points An `sf` object of random points; created in function 8: random_points()
#'
#' @returns             A plot showing random points over clipped SWF polygons
#' @export
#'
#' @examples            my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                      my_grid <- create_hex_grid(my_data, 500)
#'                      data_clip <- swf_grid(my_data, my_grid)
#'                      my_points <- random_points(my_grid, 11, 20)
#'
#'                      plot_random_points(my_grid, data_clip, 11, my_points)
#'
#' @examples            my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                      my_grid <- create_hex_grid(my_data, 500)
#'                      data_clip <- swf_grid(my_data, my_grid)
#'                      my_points <- random_points(my_grid, 15, 25)
#'
#'                      plot_random_points(hex_grid = my_grid, swf_clipped = data_clip, hex_id = 15, random_points = my_points)


plot_random_points <- function(hex_grid, swf_clipped, hex_id, random_points) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Plotting the selected hexagon with the matching SWF data and points on top
  plot(sf::st_geometry(selected_hex), border = "black", lwd = 2, main = paste("Hexagon ", selected_hex$hex_id, " - random points over hedge areas"))
  plot(sf::st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
  plot(sf::st_geometry(random_points), col = "red", pch = 16, cex = 0.6, add = TRUE)
}
