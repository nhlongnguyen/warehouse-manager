class MongoModels::Warehouse
  include Mongoid::Document
  field :name, type: String
  field :capacity, type: Integer
  field :capacity_taken, type: Integer

  embeds_many :products, class_name: 'MongoModels::Product'

  def insert_product(product_params)
    old_capacity = self.capacity_taken
    product = products.new(product_params)
    if free_capacity > product.volume
      self.capacity_taken += product.volume
      if save
        if product.save
          return product
        else
          update_attributes(capacity_taken: old_capacity)
        end
      else
        raise 'Error while saving warehouse'
      end
    else
      raise 'Not enough free capacity in warehouse'
    end
  end

  def move_product_to_warehouse(product, new_warehouse)
    if new_warehouse.free_capacity > product.volume
      old_capacity = self.capacity_taken
      new_warehouse_old_capacity = new_warehouse.capacity_taken
      self.capacity_taken -= product.volume
      new_warehouse.capacity_taken += product.volume
      product.warehouse = new_warehouse
      if save
        if new_warehouse.save
          if product.save
            return product
          else
            update_attributes(capacity_taken: old_capacity)
            new_warehouse.update_attributes(capacity_taken: new_warehouse_old_capacity)
          end
        else
          update_attributes(capacity_taken: old_capacity)
        end
      end
    else
      raise 'Not enough free capacity in warehouse'
    end
  end

  def remove_product(product)
    if product.destroy
      capacity_taken -= product.volume
      save
    else
      raise 'Product destroy failed'
    end
  end

  private

  def free_capacity
    capacity - capacity_taken
  end
end
