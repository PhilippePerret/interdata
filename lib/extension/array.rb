#
# Extension à la class Array
#

class Array
  
  # Remplace les valeurs string comme "true" ou "false" par des valeurs
  # réelles (true ou false)
  def values_str_to_real
    self.collect! do |e|
      case e
      when "true" then true
      when "false" then false
      when "null", "nil" then nil
      else e
      end
    end
  end
  
  # =>  Renvoie un array ou les clés string des hash (if any) sont
  #     remplacées par des clés symboliques ('cle' => :cle)
  #     DANS TOUS LES ÉLÉMENTS ET SOUS-ÉLÉMENTS
  def to_sym
    self.collect do |e|
      case e.class.to_s
      when 'Hash', 'Array' then e.to_sym
      else e
      end
    end
  end
  # Construit une liste UL/LI/A à partir du array fourni
  # Requiert la class BMenu (lib/ruby/class/builder-menu.rb)
  #
  # Le array doit être une liste de Hash qui contiennent :
  #   :route    Le lien
  #   :class    La classe
  #   :title    Le texte du menu
  #   :visible  Si false, le menu n'est pas affiché
  #   + autres attributs ajoutés à la balise A du menu
  #
  # @note   Si :route et :href ne sont pas définis, c'est un li ne 
  #         contenant que le :title qui est affiché (par exemple avec la
  #         class 'disabled' — menu non sélectionnable)
  #
  # @param  attributes  Les attributs HTML à ajouter à la balise
  #                     Peut définir aussi :
  #                     
  def as_ul attributes = nil
    begin
      raise "La class BMenu doit être chargée" unless defined? BMenu
      BMenu::build( self, attributes || {} )
    rescue Exception => e
      F.error e.message
      F.backtrace e
      ""
    end
  end
  
  # Construit un menu select à partir de la liste fournie
  #
  # Chaque élément (qui donnera un item de menu) peut être un array ou un
  # hash
  #
  # @param  params    Les paramètres envoyés pour définir le menu
  #         
  #     :key_title    Clé (ou indice) dans l'élément pour trouver le titre
  #     :key_value    Clé (ou indice) dans l'élément pour trouver la valeur à
  #                   donner à l'OPTION (value)
  #     :key_selected Clé (ou indice) à prendre pour trouver l'élément 
  #                   sélectionné
  #     :selected     Valeur que doit avoir la clé :key_selected de l'élément
  #                   pour être l'élément sélectionné
  #     :name         Le name à donner au select
  #     ... autre paramètres HTML à ajouter au SELECT
  #
  #
  # Par défaut, c'est un array d'arrays, ou le premier élément est le titre
  # à donner à l'option et le second élément est la valeur de l'option.
  # Mais on peut envoyer ce qu'on veut, pour en tirer ce qu'on veut en
  # définissant les attributs :key_title et :key_value dans params
  #
  # Pour des arrays, :key_title sera l'indice de l'élément à prendre comme 
  # titre et :key_value sera l'indice de l'élément à prendre comme valeur.
  # Pour des hashs, :key_title sera la clé de l'élément à prendre comme titre
  # et :key_value sera la clé de l'élément à prendre comme valeur.
  #
  def as_select params = nil
    
    is_hash   = self[0].class == Hash
    is_array  = !is_hash

    # La clé à utiliser pour trouver le titre
    # Par défaut :id
    key_title = params.delete(:key_title)
    key_title ||= ( is_array ? 0 : :id )
    # La clé à utiliser pour trouver la valeur
    # Par défaut :value
    key_value = params.delete(:key_value)
    key_value ||= ( is_array ? 1 : :value )
    # La clé à utiliser pour la sélection
    key_selected  = params.delete( :key_selected )
    key_selected ||= ( is_array ? 1 : :value )
    selected      = params.delete( :selected )

    select = ""
    self.each do |ditem|
      params_item = { :value => ditem[key_value] }
      if key_selected != nil && ditem[key_selected] == selected
        params_item = params_item.merge( :selected => "SELECTED" )
      end
      select << ditem[key_title].as_option( params_item )
    end
    params[:name] = params[:id]   if params[:name].nil?
    params[:id]   = params[:name] if params[:id].nil?
    BuilderHtml::wrap( 'select', select, params )
  end
end