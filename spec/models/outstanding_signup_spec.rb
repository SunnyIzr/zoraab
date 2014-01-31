require 'spec_helper'

describe OutstandingSignup do
  let (:order) {FactoryGirl.create(:order)}
  let (:outstanding_signup) {FactoryGirl.create(:outstanding_signup)}


  it { should validate_presence_of (:trans_id)}
  it { should validate_uniqueness_of (:trans_id)}

  it 'should destroy any outstanding signup if an order has been placed with that trans id' do
    outstanding_signup.save
    order.save
    order.trans_id = OutstandingSignup.last.trans_id
    order.save
    OutstandingSignup.refresh_outstanding_signups
    expect(OutstandingSignup.all).to eq([])
  end
end
