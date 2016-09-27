class MongoModels::Product
  include Mongoid::Document
  field :name, type: String
  field :volume, type: Integer

  embedded_in :warehouse
end
