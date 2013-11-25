class AddQToProducts < ActiveRecord::Migration
  def change
    add_column :products, :q, :integer
  end
end
