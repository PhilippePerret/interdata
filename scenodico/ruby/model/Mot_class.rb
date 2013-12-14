=begin

  Class Mot
  ---------
  Elle peut s'entendre, au niveau Class, comme le dictionnaire lui-même

=end

require 'json'
require 'fileutils'

# Chemins d'accès pour pouvoir être appelé de n'importe
# quelle application.

dbase     = File.expand_path(__FILE__)
while File.basename(File.dirname(dbase)) != "scenodico"
  dbase = File.dirname(dbase)
end 
BASE            = File.dirname(dbase)
while File.basename(File.dirname(dbase)) != "interdata"
  dbase = File.dirname(dbase)
end 
BASE_INTERDATA  = File.dirname(dbase)
ROOT            = File.dirname(BASE_INTERDATA)

# # Debug
# puts "BASE : #{BASE}"
# puts "BASE_INTERDATA : #{BASE_INTERDATA}"
# puts "ROOT : #{ROOT}"

# Pour un retour quand c'est une requête Ajax
RETOUR_AJAX = {} unless defined?(RETOUR_AJAX)
RETOUR_AJAX[:process_dico] = []

class Mot
  
  class << self
    attr_reader :categories
    
    def log txt
      puts txt
      RETOUR_AJAX[:process_dico] << txt
    end
    def add_categories arr
      @categories ||= []
      @categories += arr
    end
    
    # Update la table JS {Hash} de tous les mots du scénodico
    # 
    def update_dico_data_js
      log "-> update_dico_data_js"
      hash = {}
      Dir["#{folder_mots}/*.msh"].each do |mpath|
        dmot = Marshal.load(File.read mpath)
        hash = hash.merge dmot[:id] => {
          :id   => dmot[:id],
          :let  => dmot[:id][0..0].ord,
          :mot  => dmot[:mot]
        }
      end
      code = "DICO.DATA=#{hash.to_json};"
      File.unlink path_dico_data_js if File.exists? path_dico_data_js
      File.open(path_dico_data_js, 'wb'){|f| f.write code }
      log "<- update_dico_data_js"
    end

    # Chemin d'accès au fichier contenant tous les
    # mots en définissant DICO.DATA
    # 
    def path_dico_data_js
      @path_dico_data_js ||= File.join(folder_data_js, 'dico_data.js')
    end

    def folder_ruby
      folder_ruby ||= (getfolder File.join(folder, 'ruby'))
    end
    def folder_data_js
      @folder_data_js ||= (getfolder File.join(folder, 'data_js'))
    end
    def folder_mots
      @folder_mots ||= (getfolder File.join(folder, 'mots'))
    end
    def folder_backup
      @folder_backup ||= (getfolder File.join(folder, 'backup'))
    end
    
    def folder
      @folder ||= BASE
    end
    
    # Pour reconstruire tous les dossiers manquant (et seulement
    # les dossiers manquants)
    # 
    def build_folders
      folder
      folder_backup
      folder_mots
      folder_data_js
      folder_ruby
      getfolder File.join(folder_ruby, 'model')
      getfolder File.join(folder_ruby, 'module')
    end
    
    def getfolder path
      Dir.mkdir(path, 0777) unless File.exists? path
      path
    end
  end
end