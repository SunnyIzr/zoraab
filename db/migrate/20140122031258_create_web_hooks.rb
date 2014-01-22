class CreateWebHooks < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.text :webhook_response
      t.timestamps
    end
  end
end
