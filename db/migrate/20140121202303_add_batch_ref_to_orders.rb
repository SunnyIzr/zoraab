class AddBatchRefToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :batch, index: true
  end
end
