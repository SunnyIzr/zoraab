class AddAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :amt, :float, :default => 0.0
  end
end
