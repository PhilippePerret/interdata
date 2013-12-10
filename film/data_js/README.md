Ce dossier contient tous les fichiers qui peuvent être importés dans les applications.

##films_data.js

Définit la pseudo-constantes :

    FILMS.DATA {Hash}

*Note&nbsp;: L'application doit obligatoirement définir l'objet `FILMS`.*
Cette table contient en clé l'identifiant du film et en valeur un {Hash} contenant&nbsp;:

    id          Identifiant du film (sert aux fichiers)
    titre       Le titre original
    titre_fr    Le titre français, if any
    annee       L'année de sortie du film.
    
Pour importer ce fichier dans une application :

<script type="text/javascript" charset="utf-8" src="../interdata/film/data_js/films_data.js"></script>