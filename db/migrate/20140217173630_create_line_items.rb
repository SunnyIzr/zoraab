class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :order
      t.references :product
      t.float :rate
      t.integer :q
      t.timestamps

    end
  end
end
