class CreateProduct < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :warehouse, index: true, foreign_key: true

      t.string :name
      t.integer :volume
    end
  end
end
