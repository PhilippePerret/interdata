# coding: utf-8

class String
  # Translate self in HTML code
  # 
  def to_html
    t = self.split("\n").collect do |para|
          "<div style=\"margin-bottom:4px;\">#{para}</div>"
        end.join("")
    '<div style="font-family:inherit;font-size:inherit;">'+t+'</div>'
  end
  
  # Transformer les caractères diacritiques et autres en ASCII
  # 
  DATA_NORMALIZE = {
    :from => "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
    :to   => "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  }
  def normalize
    self.tr(DATA_NORMALIZE[:from], DATA_NORMALIZE[:to])
  end
  
  # Transforme la chaine en “id normalizé”, c'est-à-dire un 
  # identifiant de type String, ne contenant que des lettres et
  # des chiffres, avec capitalisation de la première lettre de
  # chaque mot.
  # Par exemple :
  #     "Ça c'est l'été et mon titre" => "CaCestLeteEtMonTitre"
  def as_normalized_id separateur = nil
    separateur ||= ""
    self.normalize.gsub(/[^a-zA-Z0-9 ]/, separateur).downcase.split.collect{|m|m.capitalize}.join('')
  end
  
  # Retire les slashes
  # 
  def strip_slashes
    self.gsub(/\\(['"])/, '\\1')
  end
end