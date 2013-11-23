class AddSubRefToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :sub, index: true
  end
end
