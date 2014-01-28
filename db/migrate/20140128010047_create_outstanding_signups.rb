class CreateOutstandingSignups < ActiveRecord::Migration
  def change
    create_table :outstanding_signups do |t|
      t.integer :trans_id
      t.integer :cid
      t.string :name
      t.string :plan
      t.float :amount
      t.timestamps
    end
  end
end
