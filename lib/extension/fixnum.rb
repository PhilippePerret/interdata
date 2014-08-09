class Fixnum
  
  # Considère le nombre comme un nombre de secondes et retourne
  # une horloge HH:MM:SS
  # 
  # @param  options     Hash définissant les options
  #                     :short    Si TRUE, on ne met pas obligatoirement les heures
  def as_horloge options = nil
    options ||= {}
    hrs   = self / 3600
    rest  = self % 3600
    mns   = rest / 60
    scs   = rest % 60
    complete = options[:short] != true || hrs > 0
    mns = "0#{mns}" if complete && mns < 10
    scs = "0#{scs}" if scs < 10
    horloge = "#{mns}:#{scs}"
    horloge = "#{hrs}:#{horloge}" if complete
    horloge
  end
  # Raccourci pour as_horloge(:short=>true)
  def as_short_horloge
    self.as_horloge :short => true
  end
  
end