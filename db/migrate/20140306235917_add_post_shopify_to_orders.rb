class AddPostShopifyToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :post_to_shopify?, :boolean, :default => true
  end
end
