require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    # ...
    where_line = params.keys.join(" = ? AND ") + " = ?"

    sql_string = "
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    "

    array_hashes = DBConnection.execute(sql_string, *params.values)

    self.parse_all(array_hashes)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
