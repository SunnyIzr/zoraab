class AddShopifyToSubs < ActiveRecord::Migration
  def change
    add_column :subs, :shopify_id, :integer
  end
end
