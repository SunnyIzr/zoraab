class DropUpfrontBoolFromSubs < ActiveRecord::Migration
  def change
    remove_column :subs, :upfront
  end
end
