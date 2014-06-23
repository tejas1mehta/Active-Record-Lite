require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require_relative '00_attr_accessor_object'
#require_relative '03_searchable.rb'

class MassObject < AttrAccessorObject
  def self.parse_all(results)
    # ...
    objects = []

    results.each do |result|
      objects << self.new(result)
    end

    return objects
  end
end

class SQLObject < MassObject

  def self.columns
    # ...
    columns = DBConnection.execute2("SELECT * FROM #{self.table_name}").first.map(&:to_sym)
    #p columns
    my_attr_accessor(*columns)

    return columns
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.name.underscore.pluralize
  end

  def self.all
    # ...
    hash_obj = DBConnection.execute("SELECT * FROM #{self.table_name}") # try array?
    return self.parse_all(hash_obj)

  end

  def self.find(find_id)
    # ...
    obj = DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = #{find_id} LIMIT 1")
    return self.parse_all(obj).first
  end

  def attributes
    # ...
    cols = self.class.columns
    @attributes = Hash.new
    cols.each {|col| @attributes[col.to_s] = send(col) }

    @attributes #||= {}
  end

  def insert
    # ...
    attributes_array = self.attributes.keys
    attributes_string = attributes_array.join(', ')
    quesmarks_string = (["?"] * attributes_array.length).join(', ')

    sql_string = "
    INSERT INTO
      #{self.class.table_name}
    VALUES
      #{quesmarks_string}
    "

    attr_values = self.attribute_values
    DBConnection.execute("INSERT INTO #{self.class.table_name} ( #{attributes_string} ) VALUES ( #{quesmarks_string} )", *attr_values)

    @id = DBConnection.instance.last_insert_row_id
  end

  def initialize(params = {})
    # ...
    cols = self.class.columns

    params.each do |attribute, value|
      attr_sym = attribute.to_sym
      if cols.include?(attr_sym) #class instance variable @column?
        self.send((attr_sym.to_s + "=").to_sym, value)
      else
        raise " unknown attribute '#{attribute}'"
      end
    end


    #@attributes = #DBconnection
  end

  def save
    # ...
    self.id.nil? ? self.insert : self.update
  end

  def update
    # ...
    attributes_array = self.attributes.keys
    attributes_string = attributes_array.join(' = ?, ') + " = ?"
    sql_string = "
    UPDATE
      #{self.class.table_name}
    SET
      #{attributes_string}
    WHERE
      id = ?
    "

    DBConnection.execute(sql_string, *self.attribute_values, self.id)

  end

  def attribute_values
    # ...
    self.attributes.values
  end
end
