# AndesBIIGLE
Scripts de gestion de volume BIIGLE a partir de missions ANDES



## Connexion et authentification a la BD ANDES  

Il est FORTEMENT DÉCONSIELLER de mettre les mots de passes directement dans un script (mais vouz pouvez le faire temporairement pour déboguguer). Il faut voir les scripts comme étant publique et ouvert a tous.

Pour sauvegarder les mots de passes de BD, il faut faire une copie du fichier gabarit `exemple.Renviron` et le nomer `.Renviron`. Par la suite il faut remplir le nom d'usagé et le mot de passe pour pouvoir faire une connexion a la BD. Il est possible de falloir redémarré `R` apres avoir modifier `.Renviron` car la lecture est uniquement fait au démarage de `R`. Le fichier `.Renviron` peut être placé dans le dossier home de l'usager `C:\Users\TON_NOM` (sur windows) ou `/home/TON_NOM` (sur Linux).

Ces informations seront par la suite disponnible via la fonction `Sys.getenv()`, comme dans cette exemple ci-bas.

``` R
# Infos connexion BD, voir section Authentification Connexion BD
url_bd <- "iml-science-4.ent.dfo-mpo.ca"
port_bd <- 25993
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
```

## Obtenir les tables en dataframes
``` R
source("R/get_image_metadata.R")
image_metadata <- get_image_metadata(andes_db_connection)
View(image_metadata)
```


Il éxiste deux variantes de script à rouler:
 - `run_create_labeltree.R` Dans cette variante, un nouveau labeltree va être ajouter comme source de labels.
 - `run_reuse_labeltree.R` Dans cette variante, les labeltrees éxiste déja (possiblement avec d'autres projets) et ils seront réutilisé sur le nouveau volume.

