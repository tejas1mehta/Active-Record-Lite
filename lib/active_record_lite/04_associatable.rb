require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  extend Searchable

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...

    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end


end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    # ...
    @name = name
    @class_name = options[:class_name] || @name.to_s.camelcase
    @primary_key = options[:primary_key] || :id

    foreign_sub = options[:class_name] ? (options[:class_name].downcase + "_id" ).to_sym
                  : (@name.to_s + "_id").to_sym

    @foreign_key = options[:foreign_key] || foreign_sub
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    @name = name
    @class_name = options[:class_name] || @name.to_s.singularize.camelcase
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || (self_class_name.downcase + "_id").to_sym

  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    # ...
    belongs_options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = belongs_options

    define_method(name) do
      fk_id = send(belongs_options.foreign_key)
      m_class = belongs_options.model_class
      m_class.where({ 'id' => fk_id }).first
    end

  end

  def has_many(name, options = {})
    #...
    has_options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      pk_id = send(has_options.primary_key)
      m_class = has_options.model_class
      foreign_key_name = has_options.foreign_key
      m_class.where({ foreign_key_name => pk_id })

    end

  end

  def assoc_options
    @assoc_opt ||= Hash.new
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
