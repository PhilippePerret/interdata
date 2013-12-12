require 'fileutils'


ROOT = ".." unless defined?( ROOT )
BASE_INTERDATA = File.expand_path(File.join('..', 'interdata')) unless defined?(BASE_INTERDATA)

require File.join(ROOT, 'lib', 'ruby', 'extension', 'hash')
require File.join(ROOT, 'lib', 'ruby', 'extension', 'array')

class Film
  
  class << self
    
    # Actualise la liste JS des films => FILMS et FILM_IDS
    # 
    # NOTES
    # -----
    #   ::  Le fichier contenant ces données se trouve dans
    #       `interdata/film/data_js/'
    # 
    def update_listes_js
      data_film = {}
      Dir["#{folder_fiches_identite}/*.msh"].each do |path|
        ifilm = Film.new(nil, :path => path)
        let = ifilm.id[0..0].ord
        let = 0 if let.between?(48, 57)
        data_film = data_film.merge(
          ifilm.id => {
            :id       => ifilm.id, 
            :let      => let,
            :titre    => ifilm.titre, 
            :titre_fr => ifilm.titre_fr, 
            :annee    => ifilm.annee}
        )
      end
      # On enregistre la donnée dans le fichier
      code = "FILMS.DATA = #{data_film.to_json}"
      File.open(File.join(folder_data_js, 'films_data.js'), 'wb'){|f| f.write code }
    end
    
    
    
    
    # Path du dossier backup courant des fiches d'identité
    # 
    def folder_backup_fiches_identite
      folder_backup_fiches_identite ||= (getfolder File.join(folder_backup_of_day, 'fiches_identite'))
    end
        
    # Path du dossier backup du jour
    # 
    def folder_backup_of_day
      @folder_backup_of_day ||= (getfolder File.join(folder_backup, Time.now.strftime("%Y-%m-%d")))
    end

    # Path au dossier contenant les DATA JS
    # 
    # @note   C'est principalement ce dossier qui est utilisé par les applications
    #         pour charger des données générales
    # 
    def folder_data_js
      @folder_data_js ||= (getfolder File.join(folder, 'data_js'))
    end

    # Path au dossier des fiches d'identité
    # 
    def folder_fiches_identite
      @folder_fiches_identite ||= (getfolder File.join(folder, 'fiches_identite'))
    end

    # Path du dossier backup général
    # 
    def folder_backup
      @folder_backup ||= (getfolder File.join(folder, 'backup'))
    end
    
    # Path du dossier général 'film' de interdata
    # 
    def folder
      @folder ||= (getfolder File.join(BASE_INTERDATA, 'film'))
    end

    # Créer le dossier s'il n'existe pas 
    def getfolder path
      Dir.mkdir(path, 0777) unless File.exists? path
      path      
    end
  end
  
  # ---------------------------------------------------------------------
  #   INSTANCE
  # ---------------------------------------------------------------------
  
  # Identifiant du film
  # 
  attr_reader :id
  
  # Données du film
  # 
  attr_accessor :data
  
  # Instanciation
  # 
  # Pour une instanciation par le path, utiliser :
  #     Film.new( nil, :path => <path> )
  def initialize id, options = nil
    if options && options[:path]
      @path = options[:path]
      @id   = data[:id]
    else
      @id = id
    end
  end
  
  # Données (raccourcis)
  def id;       @id       ||= data[:id]         end
  def titre;    @titre    ||= data[:titre]      end
  def titre_fr; @titre_fr ||= data[:titre_fr]   end
  def annee;    @annee    ||= data[:annee].to_i end
  
  
  # Enregistre le film (fiche d'identité)
  # 
  # @param  backup    Si TRUE, on fait une sauvegarde du fichier (s'il existe)
  # 
  def save backup = true
    do_backup if backup
    @data[:updated_at] = Time.now
    File.unlink path if File.exists? path
    File.open(path, 'wb'){|f| f.write (Marshal.dump data) }
  end
  
  # Produire une sauvegarde
  # 
  def do_backup
    return if new?
    FileUtils.cp path, path_backup
  end
  
  # Data du film (les charge si nécessaire)
  # 
  def data
    @data ||= Marshal.load(File.read path)
  end
  
  # Retourne true si c'est un nouveau film
  # 
  def new?
    @is_new ||= false == (File.exists? path)
  end
  
  # Path aux données générales du film (fiche identité)
  # 
  def path
    @path ||= File.join(self.class.folder_fiches_identite, "#{id}.msh")
  end
  
  # Path d'un backup courant
  # 
  def path_backup
    File.join(self.class.folder_backup_fiches_identite, "#{id}.msh")
  end
  
end