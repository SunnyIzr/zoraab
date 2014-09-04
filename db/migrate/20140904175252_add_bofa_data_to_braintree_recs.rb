class AddBofaDataToBraintreeRecs < ActiveRecord::Migration
  def change
    add_column :braintree_recs, :bofa_data, :text
  end
end
