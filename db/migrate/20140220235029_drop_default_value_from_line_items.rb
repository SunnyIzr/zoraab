class DropDefaultValueFromLineItems < ActiveRecord::Migration
  def change
    change_column :line_items, :line_itemable_type, :string, :default=>nil
  end
end
