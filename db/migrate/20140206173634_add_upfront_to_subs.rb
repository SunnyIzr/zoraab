class AddUpfrontToSubs < ActiveRecord::Migration
  def change
    add_column :subs, :upfront, :boolean, :default => false
  end
end
