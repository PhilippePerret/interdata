=begin

Model Film
----------

Toute application utilisant les films peuvent requérir ce module pour
interagir avec les films.

Pour ENREGISTRER DE NOUVELLES DATA D'IDENTITÉ, il suffit d'invoquer :

    <instance du film>.merge <new_data>
    # Gère tout, et notamment l'actualisation des data de tous les
    # films si nécessaire.
    # Fonctionne aussi pour un nouveau film. Mais l'identifiant du
    # nouveau film doit avoir été calculé.


=end
require 'fileutils'
require 'json'

dbase     = File.expand_path(__FILE__)
while dbase && File.basename(File.dirname(dbase)) != "film"
  dbase = File.dirname(dbase)
end 
BASE            = File.dirname(dbase)
while dbase && File.basename(File.dirname(dbase)) != "interdata"
  dbase = File.dirname(dbase)
end 
BASE_INTERDATA  = File.dirname(dbase)
ROOT            = File.dirname(BASE_INTERDATA)

require File.join(ROOT, 'lib', 'ruby', 'extension', 'hash')
require File.join(ROOT, 'lib', 'ruby', 'extension', 'array')

# Convenient
RETOUR_AJAX = {} unless defined?(RETOUR_AJAX)
RETOUR_AJAX[:film_process] = []

class Film
  
  class << self
    
    def log txt
      txt = txt.inspect unless txt.class == String
      RETOUR_AJAX[:film_process] << txt
    end
    
    # Actualise la liste JS des films => FILMS et FILM_IDS
    # 
    # NOTES
    # -----
    #   ::  Le fichier contenant ces données se trouve dans
    #       `interdata/film/data_js/'
    # 
    def update_listes_js
      log "-> Film::update_listes_js (actualisation film list)"
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
      log "<- Film::update_listes_js (#{(code.length/1000).round} Ko)"
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
  # 
  def initialize id, options = nil
    if options && options[:path]
      @path = options[:path]
      @id   = data[:id]
    else
      @id = id
    end
  end
  
  # Raccourci (pour mettre dans RETOUR_AJAX[:film_process])
  def log txt; self.class.log txt end
  
  # Données (raccourcis)
  def id;       @id       ||= data[:id]         end
  def titre;    @titre    ||= data[:titre]      end
  def titre_fr; @titre_fr ||= data[:titre_fr]   end
  def annee;    @annee    ||= data[:annee].to_i end
  
  # Dispatch/merge les données +data+ dans l'instance.
  # 
  # NOTES
  # -----
  #   = En fait, on pourrait faire <film>.data = <nouvelles données>
  #     mais cette méthode permet :
  #       1 De symboliser les clés
  #       2 De merger les données d'identité en conservant celles
  #         qui ne sont pas fournies
  #       3 De faire quelques corrections d'usage.
  #         - Toutes les valeurs "" sont mises à nil
  #         - Les valeurs nombre sont mises en nombre
  # 
  # @param  imported_data   Données {Hash} importées ou les clés peuvent
  #                         être des strings.
  # 
  def merge imported_data
    log("-> <film>.merge")
    @imported_data = imported_data
    epure_imported_data
    log("Film list devra être updatée") if need_update_film_list?
    @data =
      if new?
        @imported_data.merge(:created_at => Time.now)
      else
        data.merge @imported_data
      end
    # On sauve en faisant un backup
    save
    self.class.update_listes_js if need_update_film_list?
    log("<- <film>.merge")
  end
  
  # Épure les données importées en mettant toutes les valeurs ""
  # à NIL et en transformant certaines valeurs nombre.
  # 
  # @requis   @imported_data
  def epure_imported_data
    d = @imported_data
    d = d.to_sym
    d.each{|prop, val| d[prop] = nil if d[prop] == ""}
    [:duree, :annee, :let].each{|p| d[p] = d[p].to_i unless d[p].nil?}
    d[:annee] = nil if d[:annee] == 0
    @imported_data = d # nécessaire ou référence ?
  end
  
  # Renvoie TRUE si le fichier des données de tous les films doit
  # être updaté en comparant les data courantes avant les data
  # importées.
  # 
  # @requis   @imported_data    {Hash} des données importées
  # 
  def need_update_film_list?
    @need_update_film_list ||= check_if_film_list_must_be_updated
  end
  def check_if_film_list_must_be_updated
    return true if new?
    [:titre, :titre_fr, :annee].each do |prop|
      return true if @imported_data[prop] != data[prop]
    end
    return false
  end
  
  # Enregistre le film (fiche d'identité)
  # 
  # @param  backup    Si TRUE, on fait une sauvegarde du fichier (s'il existe)
  # 
  def save backup = true
    do_backup if backup
    data[:updated_at] = Time.now
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
  
  # Retourne true si la fiche d'identité du film existe
  # 
  def exists?
    File.exists? path
  end
  # Retourne true si c'est un nouveau film
  # 
  def new?
    @is_new ||= (false == exists?)
  end
  
  # Destruction complète du film
  # 
  # @note   Actualise aussi la liste des données des films
  # 
  def destroy
    log "-> <film>.destroy"
    return if new?
    do_backup
    File.unlink path if File.exists? path
    # TODO: Plus tard, il faudra aussi voir si le film possède
    # d'autres dossiers/informations
    self.class.update_listes_js
    log "<- <film>.destroy"
  end
  
  # Path aux données générales du film (fiche identité)
  # 
  def path
    @path ||= File.join(self.class.folder_fiches_identite, "#{id}.msh")
  end
  
  # Path d'un backup courant
  # 
  def path_backup
    File.join(self.class.folder_backup_fiches_identite, "#{id}-#{Time.now}.msh")
  end
  
end