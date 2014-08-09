=begin

Script permettant d'ajouter un film (fiche d'identité)

Note : pour éditer un film (modifier ses données), utiliser "edit_film.rb"

=end
# Permet de forcer l'enregistrement même si le fichier existe
# Attention : cela détruira les données enregistrées pour mettre les données ci-dessous
# Si false (valeur à laisser), produira une erreur si le fichier existe déjà
FORCE_SAVE = true 
FILM_DATA = <<-YAML

id:           Her
titre:        Her
titre_fr:     null
pays:         us
annee:        2013
duree:        126 # minutes
realisateur:  [
  {prenom: "Spike", nom: "Jonze"}
]
auteurs:      [
  {prenom: "Spike", nom: "Jonze", fonction: "Scénario"}
]
producteur:   [
  {prenom: "Patrick", nom: "Markey"},
  {prenom: "Robert", nom: "Redford"}
]
resume:       "Dans un futur proche, et en pleine procédure de divorce, Theodore tombe amoureux de son tout nouvel OS (système d'exploitation informatique)."
acteurs: [
  {prenom: "Joaquin", nom: "Phoenix", prenom_perso: "Theodore", nom_perso: "", fct_perso: "Protagoniste"},
  {prenom: "Scarlett", nom: "Johansson", prenom_perso: "Samantha", nom_perso: "", fct_perso: "Objet de la quête"},
  {prenom: "Amy", nom: "Adams", prenom_perso: "Amy", nom_perso: "", fct_perso: "Amie de Theodore"}
]
  YAML

FOLDER_INTERDATA = File.expand_path('.')
FOLDER_FILM = File.join(FOLDER_INTERDATA,'film')
FOLDER_FICHES_IDENTITE = File.join(FOLDER_FILM,'fiches_identite')

require 'yaml'
require File.join(FOLDER_INTERDATA, 'lib', 'extension', 'hash')

Dir["#{FOLDER_FICHES_IDENTITE}/*.msh"].each do |path|
  dfilm = Marshal.load(File.read path)
  # puts dfilm[:auteurs].inspect
  # puts dfilm.inspect
  break
end

# Les données du film, à enregistrer
data = YAML.load_stream(FILM_DATA).first.to_sym
puts data.inspect
film_id = data[:id]

puts "\n\n"
if data[:id] == "ID_UNIQUE" || data[:id].to_s == ""
  puts "ERREUR : Il faut donner un identifiant au film"
elsif !FORCE_SAVE && File.exists?( File.join(FOLDER_FICHES_IDENTITE, "#{data[:id]}.msh"))
  puts "ERREUR : Un film portant l'identifiant `#{data[:id]}' existe déjà. Si vous voulez le modifier, utiliser le script edit_film.rb"
else
  # === On peut créer la fiche d'identité ===
  film_path = File.join(FOLDER_FICHES_IDENTITE, "#{film_id}.msh")
  File.open(film_path, 'wb'){|f| f.write Marshal.dump(data) }
  puts "OK. Fiche d'identité créée. Vous pouvez lancer le module 'update_film_data_js' pour actualiser les données JS"
end