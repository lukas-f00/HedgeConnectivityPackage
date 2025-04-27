#' Function 1: Loading in the SWF data
#'
#' @param path   Character. Path to the SWF raster file (.tif)
#' @param CRS    Numeric. EPSG code defining the target Coordinate Reference System (e.g., 3035 for ETRS89 / LAEA Europe).
#'
#' @returns      An `sf` object with hedge/SWF polygons
#' @export
#'
#' @examples     load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'
#' @examples     load_swf_data(path = system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), CRS = 3035)
#'
#' @description  Data from the SWF Layer from Copernicus
#'
#' @source       COPERNICUS LAND MONITORING SERVICE (2018): High Resolution Layer Small Woody Features.URL:https://land.copernicus.eu/en/products/high-resolution-layer-small-woody-features.
#'


load_swf_data <- function(path, CRS) {
  # Loading in the raster data and converting it to polygons, then to a sf-object
  swf_raster <- raster::raster(path)
  swf_raster_trans <- raster::projectRaster(swf_raster, crs = sf::st_crs(CRS)$proj4string)
  swf_vector <- raster::rasterToPolygons(swf_raster_trans, fun = function(x) x > 0, dissolve = TRUE)
  swf_sf <- sf::st_as_sf(swf_vector)
  return(swf_sf)
}

###########################################################################################

#' Function 2: Creating a hexagon grid
#'
#' @param swf_sf   An `sf` object of SWF polygons; created in function 1: load_swf_data()
#' @param diameter Numeric. Diameter of the hexagons in map units (e.g., meters)
#'
#' @returns        An `sf` object containing the hexagon grid with assigned IDs
#' @export
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'
#'                 create_hex_grid(my_data, 500)
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#' #'
#'                 create_hex_grid(swf_sf = my_data, diameter = 500)


create_hex_grid <- function(swf_sf, diameter) {
  # Creating a hexagon grid with the extent of the SWF data and agiven cellsize. Also converting it to a sf-object
  hex_grid <- sf::st_make_grid(swf_sf, cellsize = diameter, square = FALSE, what = "polygons")
  hex_grid <- sf::st_sf(geometry = hex_grid)

  # getting the coordinates of the centroids
  coords <- sf::st_coordinates(sf::st_centroid(hex_grid))
  # Assingning a ID to each hexagon and ranking them in consecutive order
  hex_grid$hex_id <- rank(-coords[,2]) * 1e6 + rank(coords[,1])
  hex_grid$hex_id <- rank(hex_grid$hex_id)
  return(hex_grid)
}

############################################################################################

#' Function 3: Plotting the hexagon grid with IDs
#'
#' @param hex_grid An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#'
#' @returns        An plot showing the hexagons labeled by ID
#' @export
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 plot_hex_ids(my_grid)
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 plot_hex_ids(hex_grid = my_grid)


plot_hex_ids <- function(hex_grid) {
  # Plotting the hexagons and adding the IDs into them
  plot(sf::st_geometry(hex_grid), border = "black", main = "Hexagon IDs")
  text(sf::st_coordinates(sf::st_centroid(hex_grid)),
       labels = hex_grid$hex_id,
       cex = 0.7, col = "blue")
}

###########################################################################################

#' Function 4: Clipping the whole SWF data with the hexagon grid
#'
#' @param swf_sf   An `sf` object of SWF polygons; created in function 1: load_swf_data()
#' @param hex_grid An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#'
#' @returns        An `sf` object of clipped SWF data
#' @export
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 swf_grid(my_data, my_grid)
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 swf_grid(swf_sf = my_data, hex_grid = my_grid)


swf_grid <- function(swf_sf, hex_grid) {
  # Clipping the SWF-data with the hexagon grid
  swf_clipped <- sf::st_join(swf_sf, hex_grid, join = sf::st_intersects)
  return(swf_clipped)
}

##########################################################################################

#' Function 5: Plotting the whole clipped SWF data with the hexagon grid
#'
#' @param hex_grid    An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#' @param swf_clipped An `sf` object of clipped SWF polygons; created in function 4: swf_grid()
#'
#' @returns           A plot showing the SWF data and hexagon grid
#' @export
#'
#' @examples          my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                    my_grid <- create_hex_grid(my_data, 500)
#'                    data_clip <- swf_grid(my_data, my_grid)
#'
#'                    plot_swf_grid(my_grid, data_clip)
#'
#' @examples          my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                    my_grid <- create_hex_grid(my_data, 500)
#'                    data_clip <- swf_grid(my_data, my_grid)
#'
#'                    plot_swf_grid(hex_grid = my_grid, swf_clipped = data_clip)


# This plot takes a while, even if the console suggests, that the process is finished
plot_swf_grid <- function(hex_grid, swf_clipped) {
  # Plotting the hexgon grid with the SWF data on top
  plot(sf::st_geometry(hex_grid), border = "grey", main = "Hexagon grid over hedge data")
  plot(sf::st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}

##########################################################################################

#' Function 6: Clipping the SWF data to the extent of one selected hexagon
#'
#' @param swf_sf   An `sf` object of SWF polygons; created in function 1: load_swf_data()
#' @param hex_grid An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#' @param hex_id   Numeric. ID of the selected hexagon
#'
#' @returns        An `sf` object of SWF polygons inside the selected hexagon
#' @export
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 clip_swf_to_hex(my_data, my_grid, 11)
#'
#' @examples       my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                 my_grid <- create_hex_grid(my_data, 500)
#'
#'                 clip_swf_to_hex(swf_sf = my_data, hex_grid = my_grid, hex_id = 15)


clip_swf_to_hex <- function(swf_sf, hex_grid, hex_id) {
  # Selecting a hexagon via its ID and clipping the SWF data with it
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]
  swf_clipped <- sf::st_intersection(swf_sf, selected_hex)
  return(swf_clipped)
}

#########################################################################################

#' Function 7: Plotting the clipped SWF data with the corresponding hexagon
#'
#' @param hex_grid    An `sf` object of hexagons with assigned IDs; created in function 2: create_hex_grid()
#' @param swf_clipped An `sf` object of clipped SWF polygons; created in function 4: swf_grid()
#' @param hex_id      Numeric. ID of the selected hexagon
#'
#' @returns           A plot showing the SWF polygons inside a hexagon
#' @export
#'
#' @examples          my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                    my_grid <- create_hex_grid(my_data, 500)
#'                    data_clip <- swf_grid(my_data, my_grid)
#'
#'                    plot_swf_hex(my_grid, data_clip, 11)
#'
#' @examples          my_data <- load_swf_data(system.file("extdata", "HRL_Small_Woody_Features_2018_005m.tif", package = "HedgeConnectivityPackage"), 3035)
#'                    my_grid <- create_hex_grid(my_data, 500)
#'                    data_clip <- swf_grid(my_data, my_grid)
#'
#'                    plot_swf_hex(hex_grid = my_grid, swf_clipped = data_clip, hex_id = 15)


plot_swf_hex <- function(hex_grid, swf_clipped, hex_id) {
  # Selecting a specific hexagon
  selected_hex <- hex_grid[hex_grid$hex_id == hex_id, ]

  # Plotting the hexagon together with the accordingly clipped SWF data
  plot(sf::st_geometry(selected_hex), border = "black", lwd = 2, main = paste("Small Woody Features in Hexagon", selected_hex$hex_id))
  plot(sf::st_geometry(swf_clipped), col = "forestgreen", add = TRUE)
}
