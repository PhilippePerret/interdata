=begin

Class PFile
----------
Pour la gestion des fichiers de tout type connu

Traitement du fichier
---------------------
  -> raw_code   Le code tel qu'enregistré dans le fichier
  -> to_s       Le texte est produit d'après le code en fonction du type
  -> format     Le texte est formaté en fonction du format de sortie désiré

=end
unless defined?(UNIVERSAL_ROOT)
  unless defined?(BASE_INTERDATA)
    folder_model = File.dirname(__FILE__)
    folder_ruby  = File.dirname(folder_model)
    folder_pfile  = File.dirname(folder_ruby)
    BASE_INTERDATA = File.expand_path(File.dirname(folder_pfile))
  end
  UNIVERSAL_ROOT = File.dirname(BASE_INTERDATA)
end
require File.join(UNIVERSAL_ROOT, 'lib', 'ruby', 'extension', 'string')
require 'rdiscount' # pour markdown

class PFile
  
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------
  
  # Path au fichier
  # 
  attr_reader :path
  
  def initialize path
    @path = path
  end
  
  # True si le fichier existe
  # 
  def exists?
    File.exists? path
  end
  
  # Retourne le type du fichier (son extension sans point)
  # 
  def type
    @type ||= File.extname(path)[1..-1]
  end
  
  # Retourne le code brut du fichier
  # 
  def raw_code
    @raw_code ||= (File.read path).to_s.force_encoding(Encoding::UTF_8)
  end
  
  # Retourne le fichier comme un texte en fonction de son type
  # @note: alias `to_text`
  def to_s
    @to_s ||= traite_to_text
  end
  alias :to_text :to_s
  
  # Retourne le contenu du fichier comme un code HTML
  # 
  def to_html
    @to_html ||= traite_to_html
  end
  
  # Traite le fichier suivant son type
  # 
  # @note:  Appeler <pfile>.to_s plutôt que cette méthode
  # 
  def traite_to_text
    case type
    when 'txt', 'text'    then raw_code
    when 'rb'             then eval(raw_code) # sensible
    when 'evc'            then traite_as_evenemencier
    when 'md', 'markdown' then traite_as_markdown.text
    else "Type de fichier #{@type} pas pris en charge au format text."
    end
  end
  
  # Traite le texte pour pouvoir produire un code HTML
  # 
  # @return {StringHTML} Le texte issu du fichier, au format HTML
  # 
  def traite_to_html
    case type
    when 'md', 'markdown' then traite_as_markdown.to_html # rdiscount s'en charge
    when 'html', 'htm'    then raw_code
    else  self.to_s.to_html
    end
  end

  # Traite le fichier comme un fichier markdown
  # 
  def traite_as_markdown
    @as_markdown ||= RDiscount.new(raw_code)
  end
  
  # Traite le fichier comme un évènemencier
  # 
  # @return Le texte formaté
  def traite_as_evenemencier
    "Un évènemencier n'est pas encore traité"
  end
  
  # Crée le fichier en y injectant un texte provisoire en fonction de son type
  # 
  def create
    File.open(path, 'wb'){|f| f.write texte_provisoire}
    File.chmod(0777, path)
  end
  
  # Texte provisoire à la création du fichier
  # 
  # @return {String} Le texte provisoire adapté au type du fichier
  def texte_provisoire
    @texte_provisoire ||= begin
      t = "Texte provisoire du fichier #{path}"
      case type
      when 'text', 'txt'    then t
      when 'rb'             then "# #{t}"
      when 'html', 'htm'    then "<i>#{t}</i>"
      when 'md', 'markdown' then "> #{t}"
      when 'evc'            then "# #{t}"
      else t
      end
    end
  end
end