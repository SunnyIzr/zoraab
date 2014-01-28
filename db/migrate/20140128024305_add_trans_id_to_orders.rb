class AddTransIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :trans_id, :integer
  end
end
