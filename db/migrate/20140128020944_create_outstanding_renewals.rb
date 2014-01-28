class CreateOutstandingRenewals < ActiveRecord::Migration
  def change
    create_table :outstanding_renewals do |t|
      t.integer :trans_id
      t.integer :cid
      t.string :name
      t.string :plan
      t.float :amount
      t.timestamps
    end
  end
end
