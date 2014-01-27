class DropWebHooks < ActiveRecord::Migration
  def change
    drop_table :web_hooks
  end
end
