require 'spec_helper'

describe Webhooks do
  let (:payload) {{"subscription"=>{"activated_at"=>"2013-12-21 18:51:50 -0500", "balance_in_cents"=>"0", "cancel_at_end_of_period"=>"false", "canceled_at"=>"", "cancellation_message"=>"", "created_at"=>"2013-12-21 18:51:43 -0500", "current_period_ends_at"=>"2014-02-21 18:51:43 -0500", "expires_at"=>"", "id"=>"4403985", "next_assessment_at"=>"2014-02-21 18:51:43 -0500", "payment_collection_method"=>"automatic", "state"=>"active", "trial_ended_at"=>"", "trial_started_at"=>"", "updated_at"=>"2014-01-27 15:31:51 -0500", "current_period_started_at"=>"2014-01-21 18:51:43 -0500", "previous_state"=>"active", "signup_payment_id"=>"45957478", "signup_revenue"=>"45.00", "delayed_cancel_at"=>"", "coupon_code"=>"", "total_revenue_in_cents"=>"9000", "product_price_in_cents"=>"4500", "product_version_number"=>"4", "customer"=>{"address"=>"123 Main Lane", "address_2"=>"", "city"=>"Big City ", "country"=>"US", "created_at"=>"2013-12-21 18:51:42 -0500", "email"=>"john@gmail.com", "first_name"=>"John", "id"=>"4224498", "last_name"=>"Smith", "organization"=>"", "phone"=>"", "reference"=>"20_171_657126", "state"=>"new jersey", "updated_at"=>"2013-12-21 18:51:42 -0500", "zip"=>"07035"}, "product"=>{"accounting_code"=>"", "archived_at"=>"", "created_at"=>"2012-07-18 16:43:52 -0400", "description"=>"5 Brand New Pairs of Socks Every Month!", "expiration_interval"=>"", "expiration_interval_unit"=>"never", "handle"=>"5r", "id"=>"1899602", "initial_charge_in_cents"=>"0", "interval"=>"1", "interval_unit"=>"month", "name"=>"Sock Connoissseur (5 Pairs/Mo)", "price_in_cents"=>"4500", "request_credit_card"=>"true", "require_credit_card"=>"true", "return_params"=>"", "return_url"=>"", "trial_interval"=>"", "trial_interval_unit"=>"month", "trial_price_in_cents"=>"", "update_return_url"=>"", "updated_at"=>"2013-11-30 10:23:19 -0500", "product_family"=>{"accounting_code"=>"", "description"=>"", "handle"=>"subs1", "id"=>"206011", "name"=>"Subscription"}}, "credit_card"=>{"billing_address"=>"123 Main Lane", "billing_address_2"=>"", "billing_city"=>"Big City ", "billing_country"=>"US", "billing_state"=>"NJ", "billing_zip"=>"07035", "card_type"=>"visa", "current_vault"=>"braintree_blue", "customer_id"=>"4224498", "customer_vault_token"=>"", "expiration_month"=>"2", "expiration_year"=>"2016", "first_name"=>"John", "id"=>"2709942", "last_name"=>"Smith", "masked_card_number"=>"XXXX-XXXX-XXXX-1111", "vault_token"=>"16390247"}}, "transaction"=>{"amount_in_cents"=>"4500", "card_expiration"=>"02/2016", "card_number"=>"XXXX-XXXX-XXXX-1111", "card_type"=>"visa", "component_id"=>"", "created_at"=>"2014-01-27 15:31:50 -0500", "ending_balance_in_cents"=>"0", "gateway_used"=>"braintree_blue", "id"=>"48383911", "kind"=>"", "memo"=>"John Smith - Sock Connoissseur (5 Pairs/Mo): Renewal payment", "payment_id"=>"", "product_id"=>"1899602", "starting_balance_in_cents"=>"4500", "subscription_id"=>"4403985", "success"=>"true", "tax_id"=>"", "type"=>"Payment", "transaction_type"=>"payment", "gateway_transaction_id"=>"8qshdkg", "gateway_order_id"=>"", "statement_id"=>"28053368", "customer_id"=>"4224498"}, "site"=>{"id"=>"11297", "subdomain"=>"zoraab"}} }
  let (:sub) {FactoryGirl.create(:sub)}
  let (:order) {FactoryGirl.create(:sub_order)}

  it 'should create a new outstanding signup if the subscriber does not exist' do
    Webhooks.chargify(payload)

    expect(OutstandingRenewal.all).to eq([])
    expect(OutstandingSignup.last.trans_id).to eq(48383911)
    expect(OutstandingSignup.last.cid).to eq(4403985)
    expect(OutstandingSignup.last.name).to eq('Smith')
    expect(OutstandingSignup.last.plan).to eq('Sock Connoissseur (5 Pairs/Mo)')
    expect(OutstandingSignup.last.amount).to eq(45.0)
  end

  it 'should create an outstanding renewal if the signup exists but there were no orders for that transaction' do
    sub.cid = 4403985
    sub.save
    Webhooks.chargify(payload)

    expect(OutstandingSignup.all).to eq([])
    expect(OutstandingRenewal.last.trans_id).to eq(48383911)
    expect(OutstandingRenewal.last.cid).to eq(4403985)
    expect(OutstandingRenewal.last.name).to eq('Smith')
    expect(OutstandingRenewal.last.plan).to eq('Sock Connoissseur (5 Pairs/Mo)')
    expect(OutstandingRenewal.last.amount).to eq(45.0)
  end

  it 'should set the trans_id and amt of the pending order if the order already exists' do
    sub.cid = 4403985
    sub.save
    sub.sub_orders << order
    sub.save
    order.save
    Webhooks.chargify(payload)

    expect(OutstandingSignup.all).to eq([])
    expect(OutstandingRenewal.all).to eq([])
    expect(Order.last.trans_id).to eq(48383911)
    expect(Order.last.amt).to eq(45.0)
  end
end
