class AddAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :name, :string
    add_column :orders, :email, :string
    add_column :orders, :address, :string
    add_column :orders, :address2, :string
    add_column :orders, :city, :string
    add_column :orders, :state, :string
    add_column :orders, :zip, :string
    add_column :orders, :country, :string
  end
end
