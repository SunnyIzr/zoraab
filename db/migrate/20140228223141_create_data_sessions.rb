class CreateDataSessions < ActiveRecord::Migration
  def change
    create_table :data_sessions do |t|
      t.string :session_key
      t.text :data
      t.timestamps
    end
  end
end
