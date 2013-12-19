=begin

Actualisation du fichier `film/data_js/films_data.js' utilisé
par les applications pour avoir la liste des films.

Le module passe en revue toutes les fiches d'identité et relève
les data mini (titre, titre_fr, let, annee) pour en faire une
donnée javascript (JSON)

NOTES
-----

  = Le module peut être invoqué depuis une autre application par :
      require File.join('..', 'interdata', 'film', 'ruby', 'module', 'update_films_data_js.rb')
    Mais si le modèle 'film' est déjà chargé, il suffit de faire :
      Film::update_listes_js

---------------------------------------------------------------------
=end
dbase     = File.expand_path(__FILE__).split('/')
while dbase.shift != 'film'; end 
BASE_FILMS            = File.join(dbase, 'film')
while dbase.shift != 'interdata'; end
BASE_INTERDATA  = File.join(dbase, 'interdata')
ROOT            = File.join(dbase)

require File.join(BASE_FILMS, 'ruby', 'model', 'film')

Film::update_listes_js