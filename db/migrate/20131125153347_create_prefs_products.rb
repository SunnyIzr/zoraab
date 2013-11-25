class CreatePrefsProducts < ActiveRecord::Migration
  def change
    create_table :prefs_products do |t|
      t.belongs_to :pref
      t.belongs_to :product
    end
  end
end
