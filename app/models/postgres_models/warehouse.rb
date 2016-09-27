class PostgresModels::Warehouse < ActiveRecord::Base
  has_many :products, class_name: 'PostgresModels::Product'

  def insert_product(product_params)
    params = product_params.merge(warehouse_id: id)
    product = PostgresModels::Product.new(params)
    if free_capacity > product.volume
      self.capacity_taken += product.volume
      ActiveRecord::Base.transaction do
        raise 'Transaction Failed' unless save && product.save
      end
    else
      raise 'Not enough free capacity in warehouse'
    end
  end

  def move_product_to_warehouse(product, new_warehouse)
    if new_warehouse.free_capacity > product.volume
      self.capacity_taken -= product.volume
      new_warehouse.capacity_taken += product.volume
      product.warehouse = new_warehouse
      ActiveRecord::Base.transaction do
        raise 'Transaction Failed' unless save && new_warehouse.save && product.save
      end
    else
      raise 'Not enough free capacity in warehouse'
    end
  end

  def remove_product(product)
    raise 'Cannot remove product from another warehouse' if product.warehouse_id != id

    self.capacity_taken -= product.volume

    ActiveRecord::Base.transaction do
      raise 'Transaction Failed' unless save && product.destroy
    end
  end

  private

  def free_capacity
    capacity - capacity_taken
  end
end
