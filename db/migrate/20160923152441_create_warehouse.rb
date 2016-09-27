class CreateWarehouse < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :name
      t.integer :capacity
      t.integer :capacity_taken
    end
  end
end
