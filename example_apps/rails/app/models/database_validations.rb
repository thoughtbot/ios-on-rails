module DatabaseValidations
  extend ActiveSupport::Concern

  included do
    columns.each do |column|
      if %w(id created_at updated_at).include? column.name
        next
      end

      if column.null != nil
        name = column.name.sub(/_id$/, "")
        if column.null
          message = /absence_message: "([^"])"/.match(column.comment)[1]
          validates_absence_of name, message: message
        else
          message = /presence_message: "([^"])"/.match(column.comment)[1]
          validates_presence_of name, message: message
        end
      end
    end

    connection.indexes(table_name).each do |idx|
      if idx.unique
        message = /uniqueness_message: "([^"])"/.match(idx.comment)[1]
        validates_uniqueness_of idx.columns[0], scope: idx.columns[1..-1], message: message
      end
    end
  end
end
