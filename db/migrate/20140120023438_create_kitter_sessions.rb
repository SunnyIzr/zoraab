class CreateKitterSessions < ActiveRecord::Migration
  def change
    create_table :kitter_sessions do |t|
      t.string :sub_id
      t.text :product_ids
      t.timestamps
    end
  end
end
