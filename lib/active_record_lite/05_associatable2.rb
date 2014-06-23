require_relative '04_associatable'

# Phase V
module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      self.send(through_name).send(source_name)
    end
  end

end
