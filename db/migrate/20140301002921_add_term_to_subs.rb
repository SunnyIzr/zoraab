class AddTermToSubs < ActiveRecord::Migration
  def change
    add_column :subs, :term, :integer
  end
end
