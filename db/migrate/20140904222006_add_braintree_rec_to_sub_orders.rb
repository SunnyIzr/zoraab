class AddBraintreeRecToSubOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :braintree_rec, index: true
  end
end
