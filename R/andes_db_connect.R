

#' Establish a connection to the andes database
#'
#' This is a wrapper for the `DBI::dbConnect`, see it's documentation for more details.
#' @param url_bd URL of the ANDES database server.
#' @param port_bd Port number for the ANDES database connection.
#' @param nom_usager Username for the ANDES database.
#' @param mot_de_passe Password for the ANDES database.
#' @param nom_bd Name of the ANDES database. Default is "andesdb".
#' @return A connection object to the ANDES database.
#' @export
andes_db_connect <- function(
                            url_bd,
                            port_bd,
                            nom_usager,
                            mot_de_passe,
                            nom_bd = "andesdb") {

    # ODBC needs to to wrap the password string in {} in case the password contains semicolons
    mot_de_passe <- paste("{", mot_de_passe, "}", sep = "")

    # TODO There is also the need to escape curly braces inside the password (if present).

    # The {MySQL ODBC 8.0 Unicode Driver} should be available on DFO workstations.
    # It can be installed in the software center.
    # Name: MySQL Connector ODBC
    # Version 8.0.22
    # URL: softwarecenter:SoftwareID=ScopeId_A90E3BBE-DB35-4A92-A44E-15F8C7C595B3/Application_dec16a4a-d57f-44b1-8a9f-8f6267f34539
    # List available drivers using odbc::odbcListDrivers()

    connection_string <- paste(
        "Driver={MySQL ODBC 8.0 Unicode Driver};",
        "SERVER=", url_bd, ";",
        "Port=", port_bd, ";",
        "DATABASE=", nom_bd, ";",
        "USER=", nom_usager, ";",
        "PASSWORD=", mot_de_passe,
        sep = "")

    andes_db_connection <- DBI::dbConnect(odbc::odbc(),
                      .connection_string = connection_string,
                      timeout = 10)
    return(andes_db_connection)
}