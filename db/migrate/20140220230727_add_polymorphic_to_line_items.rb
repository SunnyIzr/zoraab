class AddPolymorphicToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :line_itemable_id, :integer
    add_column :line_items, :line_itemable_type, :string, :default => 'Order'
  end
end
