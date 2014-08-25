=begin

Script permettant d'ajouter un film (fiche d'identité)

Note : pour éditer un film (modifier ses données), utiliser "edit_film.rb"

=end
# Permet de forcer l'enregistrement même si le fichier existe
# Attention : cela détruira les données enregistrées pour mettre les données ci-dessous
# Si false (valeur à laisser), produira une erreur si le fichier existe déjà
FORCE_SAVE = false 
FILM_DATA = <<-YAML

id:           127Hours2010
titre:        127 Hours
titre_fr:     127 Heures
pays:         us
annee:        2010
duree:        94 # minutes
resume:       "L'histoire vraie d'Aron Ralston, coincé 127 heures dans une crevasse par un rocher."
realisateur:  [
  {prenom: "Danny", nom: "Boyle"}
]
auteurs:      [
  {prenom: "Aron", nom: "Ralston", fonction: "Livre"},
  {prenom: "Danny", nom: "Boyle", fonction: "Scénario"},
  {prenom: "Simon", nom: "Beaufoy", fonction: "Scénario"}
]
acteurs: [
  {prenom: "James", nom: "Franco", prenom_perso: "Aron", nom_perso: "Ralston", fct_perso: "Protagoniste"},
  {prenom: "Kate", nom: "Mara", prenom_perso: "Kristi", nom_perso: "", fct_perso: ""},
  {prenom: "Amber", nom: "Tamblyn", prenom_perso: "Megan", nom_perso: "", fct_perso: ""}
]
producteur:   [
  {prenom: "Danny", nom: "Boyle"},
  {prenom: "Christian", nom: "Colson"},
  {prenom: "John", nom: "Smithson"}
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