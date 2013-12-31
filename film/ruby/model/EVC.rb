=begin

Class EVC
---------
Classe qui gère les évènemenciers

=end

unless defined? ROOT
  dbase     = File.expand_path(__FILE__)
  while dbase && File.basename(File.dirname(dbase)) != "film"
    dbase = File.dirname(dbase)
  end 
  BASE_FILMS            = File.dirname(dbase)
  while dbase && File.basename(File.dirname(dbase)) != "interdata"
    dbase = File.dirname(dbase)
  end 
  BASE_INTERDATA  = File.dirname(dbase)
  ROOT            = File.dirname(BASE_INTERDATA)
end
this_folder = File.dirname(__FILE__)

require File.join(ROOT, 'lib', 'ruby', 'extension', 'string')
require "#{this.folder}/Event"
require "#{this.folder}/film"

class EVC
  # ---------------------------------------------------------------------
  #   Constantes
  # ---------------------------------------------------------------------

  # Échelles d'evc
  # 
  SCALES = {
    :acte     => {:hname => "Actes"},
    :metaseq  => {:hname => "Métaséquencier"},
    :sequence => {:hname => "Séquencier"},
    :metasce  => {:hname => "Métascénier"},
    :scene    => {:hname => "Scénier"}, # => scénier si type :total
    :beat     => {:hname => "Beat-scène"},
    :event    => {:hname => "Events"}
  }
  
  # Types d'EVC
  # 
  TYPES = {
    :total    => {:hname => "total"},
    :brin     => {:hname => "brin"}
  }
  
  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self
  end
  
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------
  
  # --- Data enregistrées ---
  
  # {String} Identifiant de l'Evc
  # C'est son affixe de fichier, tiré du premier titre donné
  # Cf. la méthode
  # ::id
  
  # {String} Titre de l'evc
  # 
  attr_reader :titre
  
  # {Film} Film de l'evc
  # 
  # Une instance {Film} du film portant cet evc
  attr_reader :film
  
  # {String} Identifiant du film de l'Evc
  # 
  attr_reader :film_id
  
  # {String} Description résumé de l'Evc
  # 
  attr_reader :resume
  
  # {Symbol} Échelle de l'évènemencier
  # 
  # Chaque evc a une échelle, qui correspond à l'échelle des évènements
  # qu'il contient.
  # cf. EVC::SCALES
  attr_reader :scale
  
  # {String} Type de l'Evc
  # 
  # cf. EVC::TYPES
  attr_reader :type
  
  # {Boolean} Complétude de l'evc
  # 
  # L'evc peut être complet (s'il va du début à la fin du film) ou partiel
  # s'il ne couvre qu'une partie du film.
  attr_reader :complet
  
  # {Array} Liste de ses évènements
  # 
  # Array des instances Event de l'évènemencier
  # @note : À la sauvegarde, on n'enregistre que les identifiants
  #         des events.
  attr_reader :events
  
  # Instanciation de l'Evc
  # 
  # @param  {Hash} params   Paramètres permettant d'instancier l'Evc
  #   @param params[:path]    Instanciation par le path du fichier de l'evc
  #   @param params[:film]    Instance {Film} du film
  #   @param params[:film_id] Identifiant du film de l'Evc
  #   @param params[:id]      Identifiant {String} de l'Evc
  def initialize params
    if params[:path].nil?
      @film = Film.new params[:film_id] unless params[:film_id].nil?
      @film = params[:film] unless params[:film].nil?
      @id   = params[:id]   unless params[:id].nil?
    else
      @path = params[:path]
    end
  end
  
  # Charge l'Evc
  # 
  def load
    raise "Evc #{path} introuvable" unless File.exists? path
    @data = Marshal.load(File.read path)
  end
  
  # Sauve l'Evc
  # 
  def save
    @data ||= define_data
    @data[:updated_at] = Time.now.to_i
    File.open(path, 'wb'){|f| f.write Marshal.dump(@data) }
  end
  
  # Dispatch les données @data
  # Notes
  # -----
  #  * Définit l'instance Film
  # 
  def dispatch_data
    @data.each{|k,v| instance_variable_set("@#{k}", v)}
    @film   = Film.new @film_id
  end
  
  # Définit les data à sauvegarder
  def define_data
    @data = {
      :id         => id,
      :film_id    => @film_id,
      :titre      => @titre,
      :scale      => @scale,
      :type       => @type,
      :events     => @events,
      :resume     => @resume,
      :complet    => @complet,
      :created_at => (@created_at || Time.now.to_i)
    }
  end
  
  def id
    @id ||= define_id_from_titre
  end
  
  # Définit l'identifiant d'après le titre
  # 
  def define_id_from_titre
    raise "Aucun titre pour cet évènemencier" if @titre.nil?
    @titre.as_normalized_id
  end
  
  def path
    @path ||= File.join(Film::folder,'films', film.id, 'evc', "#{id}.msh")
  end
  
end