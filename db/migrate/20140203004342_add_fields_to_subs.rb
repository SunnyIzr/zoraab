class AddFieldsToSubs < ActiveRecord::Migration
  def change
    add_column :subs, :active, :boolean, :default => true
    add_column :subs, :next_assessment_at, :datetime
  end
end
