class CreatePrefsSubs < ActiveRecord::Migration
  def change
    create_table :prefs_subs do |t|
      t.belongs_to :pref
      t.belongs_to :sub
    end
  end
end
