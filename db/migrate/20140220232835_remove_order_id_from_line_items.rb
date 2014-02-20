class RemoveOrderIdFromLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :order_id
  end
end
