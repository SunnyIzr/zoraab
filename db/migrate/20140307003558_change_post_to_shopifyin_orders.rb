class ChangePostToShopifyinOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :post_to_shopify?, :post_to_shopify
  end
end
