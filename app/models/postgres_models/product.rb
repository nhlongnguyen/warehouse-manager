class PostgresModels::Product
  belongs_to :warehouse, class_name: 'PostgresModels::Warehouse'
end
