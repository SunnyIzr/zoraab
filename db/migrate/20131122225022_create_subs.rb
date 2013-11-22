class CreateSubs < ActiveRecord::Migration
  def change
    create_table :subs do |t|
      t.integer :cid
    end
  end
end
