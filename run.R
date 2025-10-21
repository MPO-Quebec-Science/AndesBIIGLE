##
## connexion a la BD
##
url_bd <- "iml-science-4.ent.dfo-mpo.ca"
port_bd <- 25985 #IML-2025-015 Relevé Écosystemique
nom_bd <- "andesdb"
nom_usager <- Sys.getenv("NOM_USAGER_BD")
mot_de_passe <- Sys.getenv("MOT_DE_PASSE_BD")

# établir connexion BD (il faut être sur le réseau MPO)
source("R/andes_db_connect.R")
andes_db_connection <- andes_db_connect(
  url_bd = url_bd,
  port_bd = port_bd,
  nom_usager = nom_usager,
  mot_de_passe = mot_de_passe,
  nom_bd = nom_bd
)

##
## Table ANDES en dataframe
##
source("R/get_image_metadata.R")
image_metadata <- get_image_metadata(andes_db_connection)
View(image_metadata)
