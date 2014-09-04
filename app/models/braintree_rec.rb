class BraintreeRec < ActiveRecord::Base
  serialize :braintree_transactions, Array
  serialize :grouped_transactions, Array
end