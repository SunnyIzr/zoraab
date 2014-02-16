class CreateSubOrdersProducts < ActiveRecord::Migration
  def change
    create_table :sub_orders_products do |t|
      t.belongs_to :sub_order
      t.belongs_to :product
    end
  end
end
