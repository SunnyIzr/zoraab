class CreateBraintreeRecs < ActiveRecord::Migration
  def change
    create_table :braintree_recs do |t|
      t.date :rec_date
      t.text :braintree_transactions
      t.text :grouped_transactions
    end
  end
end
