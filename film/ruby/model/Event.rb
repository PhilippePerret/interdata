=begin

  Class Event
  -----------
  Class d'un évènement d'évènemencier

=end
class Event
  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self
  end
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------
  
  # {Fixnum} Point temps de l'event
  # 
  # @note: Exprimé en secondes
  attr_accessor :time
  
  # {Fixnum} Durée de l'event
  # Exprimée en secondes
  attr_accessor :duration
  
  # {String} Description de l'event
  # 
  attr_accessor :description
  
  # --- Data non enregistrées ---
  
  # {EVC} Evenmencier de l'event
  attr_reader :evc
  
  # {Film} Film de l'event
  # Pris dans Evc, raccourci de @evc.film
  attr_reader :film
  
  # {Fixnum} Fin de l'event
  # Exprimée en secondes
  # Cf. la méthode
  # ::end
  
  # {Symbol} Échelle de l'even
  # Héritée de l'Evc
  # Cf. la méthode
  # ::scale
  
  # Instanciation de l'Event
  # @param  {Film}  evc     Instance EVC de l'évènemencier possédant l'event
  # @param  {Hash}  params  Les paramètres transmis ou NIL
  #                         Peut contenir n'importe quelle propriété de l'event
  def initialize evc, params = nil
    @evc  = evc
    @film = evc.film
    params.each{|k,v| instance_variable_set("@#{k}", v)} unless params.nil?
  end
  
  # {Fixnum} Fin de l'event (en secondes)
  def end; @end ||= @time + @duration end
  
  # {Symbol} Échelle de l'event
  def scale; @scale ||= @evc.scale end
  
end