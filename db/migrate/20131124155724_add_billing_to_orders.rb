class AddBillingToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billing_name, :string
    add_column :orders, :billing_address, :string
    add_column :orders, :billing_address2, :string
    add_column :orders, :billing_city, :string
    add_column :orders, :billing_state, :string
    add_column :orders, :billing_zip, :string
    add_column :orders, :billing_country, :string
  end
end
