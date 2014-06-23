class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|

      inst_var = "@" + name.to_s

      define_method(name){instance_variable_get(inst_var)}
      define_method((name.to_s + "=").to_sym){|val| instance_variable_set(inst_var, val)}
    end
  end

end
