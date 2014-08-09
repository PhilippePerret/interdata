# Extension de la class Hash

class Hash
  
  # Remplace les "true", "false", "null" par true, false, nil
  def values_str_to_real
    self.each do |k,v|
      v = case v.class.to_s
      when 'Hash', 'Array' then v.values_str_to_real
      when 'String' then
        case v
        when "true" then true
        when "false" then false
        when "nil", "null" then nil
        else v
        end
      else v
      end
      self[k] = v
    end
  end
  
  # Permet de remplacer les clés 'string' par :string
  # Utile par exemple pour des données JSON récupérées
  def to_sym
    hash_ruby = {}
    self.each do |k, v|
      k = k.to_s[0..-3] if k.to_s.end_with? '[]'
      v_ruby =  case v.class.to_s
                  when 'Hash'   then v.to_sym
                  when 'Array'  then
                    v.collect do |e| 
                      case e.class.to_s
                        when 'Hash', 'Array' then e.to_sym
                        else e
                      end 
                    end
                  else v 
                end
      hash_ruby = hash_ruby.merge( k.to_sym => v_ruby )
    end
    hash_ruby
  end
end