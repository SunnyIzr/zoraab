class FixOrdersProductsTable < ActiveRecord::Migration
  def change
    rename_column :orders_products, :order_id, :sub_order_id
  end
end
