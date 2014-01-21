class AddBatchToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :batch, :boolean, :default => false
  end
end
