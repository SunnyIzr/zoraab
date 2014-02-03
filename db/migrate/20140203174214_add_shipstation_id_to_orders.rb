class AddShipstationIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ssid, :integer
  end
end
