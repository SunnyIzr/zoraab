class AddColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gateway, :string
    add_column :orders, :shipping_charge, :float, :default => 0.0
    add_column :orders, :discount, :float, :default => 0.0
    add_column :orders, :fees, :float, :default => 0.0
  end
end
