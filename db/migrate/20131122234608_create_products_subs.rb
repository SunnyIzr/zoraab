class CreateProductsSubs < ActiveRecord::Migration
  def change
    create_table :products_subs do |t|
      t.belongs_to :product
      t.belongs_to :sub
    end
  end
end
