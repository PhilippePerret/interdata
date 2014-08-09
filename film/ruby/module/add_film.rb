=begin

Script permettant d'ajouter un film (fiche d'identité)

Note : pour éditer un film (modifier ses données), utiliser "edit_film.rb"

=end
# Permet de forcer l'enregistrement même si le fichier existe
# Attention : cela détruira les données enregistrées pour mettre les données ci-dessous
# Si false (valeur à laisser), produira une erreur si le fichier existe déjà
FORCE_SAVE = true 
FILM_DATA = <<-YAML

id:           MariasLovers
titre:        Maria's Lovers
titre_fr:     null
pays:         us
annee:        1984
producteur:   [
  {prenom: "Bosko", nom: "Djordjevic"},
  {prenom: "Lawrence", nom: "Taylor-Mortoff"}
]
realisateur:  [
  {prenom: "Andrey", nom: "Konchalovskiy"}
]
auteurs:      [
  {prenom: "Gérard", nom: "Brach", fonction: "Scénario"},
  {prenom: "Andrey", nom: "Konchalovskiy", fonction: "Scénario"},
  {prenom: "Paul", nom: "Zindel", fonction: "Scénario"},
  {prenom: "Marjorie", nom: "David", fonction: "Scénario"}
]
duree:        109 # minutes
resume:       "Ivan Bibic rentre chez lui de la guerre du Vietnam, et retrouve son amour d'enfance, Maria Bosic."
acteurs: [
  {prenom: "Nastassja", nom: "Kinski", prenom_perso: "Maria", nom_perso: "Bosic", fct_perso: "Protagoniste"},
  {prenom: "John", nom: "Savage", prenom_perso: "Ivan", nom_perso: "Bibic", fct_perso: "Co-protagoniste"},
  {prenom: "Robert", nom: "Mitchum", prenom_perso: "Père", nom_perso: "Bibic", fct_perso: null},
  {prenom: "Keith", nom: "Carradine", prenom_perso: "Clarence", nom_perso: "Butts", fct_perso: null}
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