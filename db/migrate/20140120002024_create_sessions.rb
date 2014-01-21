class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_key
      t.text :product_ids
      t.timestamps
    end
  end
end
