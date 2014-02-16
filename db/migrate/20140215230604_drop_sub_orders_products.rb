class DropSubOrdersProducts < ActiveRecord::Migration
  def change
    drop_table :sub_orders_products
  end
end
