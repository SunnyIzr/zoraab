class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :sku
    end
  end
end
