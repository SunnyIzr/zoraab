class DropFieldsFromSubs < ActiveRecord::Migration
  def change
    remove_column :subs, :active
    remove_column :subs, :next_assessment_at
  end
end
