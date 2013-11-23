class CreateOrdersProducts < ActiveRecord::Migration
  def change
    create_table :orders_products do |t|
      t.belongs_to :order
      t.belongs_to :product
    end
  end
end
