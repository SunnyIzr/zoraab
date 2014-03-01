class AddTypeToSubs < ActiveRecord::Migration
  def change
    add_column :subs, :type, :string
  end
end
