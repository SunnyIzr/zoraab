class RemoveBatchFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :batch
  end
end
