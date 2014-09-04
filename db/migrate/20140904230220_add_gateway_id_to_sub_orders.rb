class AddGatewayIdToSubOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gateway_id, :string
  end
end
