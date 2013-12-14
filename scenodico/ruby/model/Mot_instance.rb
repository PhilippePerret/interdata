class Mot
  
  # ---------------------------------------------------------------------
  #   INSTANCE
  # ---------------------------------------------------------------------
  attr_reader :id
  
  
  def initialize id
    @id = id
  end
  
  # Dispatch/merge les données +data+ dans l'instance.
  # 
  # NOTES
  # -----
  #   = En fait, on pourrait faire <mot>.data = <nouvelles données>
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
    log("-> <mot>.merge")
    @imported_data = imported_data
    epure_imported_data
    log("dico_data.js devra être updaté.") if need_update_mot_list?
    @data =
      if new?
        @imported_data.merge(:created_at => Time.now)
      else
        data.merge @imported_data
      end
    # On sauve en faisant un backup
    save
    self.class.update_dico_data_js if need_update_mot_list?
    log("<- <mot>.merge")
  end
 
  # Enregistre le mot
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
 
  # Retourne true si la fiche d'identité du mot existe
  # 
  def exists?
    File.exists? path
  end
  # Retourne true si c'est un nouveau mot
  # 
  def new?
    @is_new ||= (false == exists?)
  end
  
  # Destruction complète du mot
  # 
  # @note   Actualise aussi la liste des données des mots
  # 
  def destroy
    log "-> <mot>.destroy"
    return if new?
    do_backup
    File.unlink path if File.exists? path
    self.class.update_dico_data_js
    log "<- <mot>.destroy"
  end
 
  def data
    @data ||= Marshal.load(File.read path)
  end
    
  def mot;        data[:mot]        end
  def categorie;  data[:categorie]  end
  def relatifs;   data[:relatifs]   end
  def synonymes;  data[:synonymes]  end
  def contraires; data[:contraires] end
  def lien;       data[:lien]       end
  def type_def;   data[:type_def]   end
  
  # Épure les données importées en mettant toutes les valeurs ""
  # à NIL et en transformant certaines valeurs nombre.
  # 
  # @requis   @imported_data
  def epure_imported_data
    d = @imported_data
    d = d.to_sym
    d.each{|prop, val| d[prop] = nil if d[prop] == "" || d[prop] == []}
    [:let].each{|p| d[p] = d[p].to_i unless d[p].nil?}
    @imported_data = d # nécessaire ou référence ?
  end
  
  # Renvoie TRUE si le fichier des données de tous les mots doit
  # être updaté en comparant les data courantes avant les data
  # importées.
  # 
  # @requis   @imported_data    {Hash} des données importées
  # 
  def need_update_mot_list?
    @need_update_mot_list ||= check_if_mot_list_must_be_updated
  end
  def check_if_mot_list_must_be_updated
    return true if new?
    [:titre, :titre_fr, :annee].each do |prop|
      return true if @imported_data[prop] != data[prop]
    end
    return false
  end
  
  def let
    @let ||= id[0..0].ord
  end
  
  def path
    @path ||= File.join(self.class.folder_mots, "#{id}.msh")
  end
  
  # Path d'un backup courant
  # 
  def path_backup
    @folder_backup_mots ||= (self.class.getfolder File.join(self.class.folder_backup,'mots'))
    File.join(@folder_backup_mots, "#{id}-#{Time.now}.msh")
  end
    
end