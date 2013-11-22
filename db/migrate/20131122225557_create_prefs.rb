class CreatePrefs < ActiveRecord::Migration
  def change
    create_table :prefs do |t|
      t.string :pref
    end
  end
end
