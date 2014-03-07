class ChangePostShopifyInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :post_to_shopify?, :boolean, :default => false
  end
end
