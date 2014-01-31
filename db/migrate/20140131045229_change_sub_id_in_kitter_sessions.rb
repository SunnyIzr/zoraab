class ChangeSubIdInKitterSessions < ActiveRecord::Migration
  def change
    change_column :kitter_sessions, :sub_id, 'integer USING CAST(sub_id AS integer)'
  end
end
