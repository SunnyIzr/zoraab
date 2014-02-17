class ChangeTypeColumnInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :type, :string, :default => nil
  end
end
