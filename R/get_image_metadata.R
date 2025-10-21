
library(readr)
library(DBI)

#' Gets image metadata as dataframe from a database query to ANDES
#'
#' This function executes a SQL query to retrieve the needed andes data to construct the image metadata table.
#' The current ANDES active mission will determine for which data are returned.
#'
#'
#' @param andes_db_connection a connection object to the ANDES database.
#' @return A dataframe containing the image metadata: filename, aphia_id, scientific_name, set_number, latitude, longitude, station_name, code.
#' @export
get_image_metadata <- function(andes_db_connection) {
    # query <- readr::read_file(system.file("sql_queries",
    #                                       "image_metadata.sql",
    #                                       package = "ANDESBIIGLE"))
    query <- readr::read_file("inst/sql_queries/image_metadata.sql")

    # add mission filter
    # use the active misison for now.
    # query <- paste(query, "WHERE shared_models_mission.is_active=1")

    # one day you can choose a different mission by ID,
    # WHERE mission_id={mission_id}

    result <- DBI::dbSendQuery(andes_db_connection, query)
    df <- DBI::dbFetch(result, n = Inf)
    DBI::dbClearResult(result)

    return(df)
}

