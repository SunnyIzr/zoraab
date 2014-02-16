require 'spec_helper'

describe OutstandingSignup do
  let (:order) {FactoryGirl.create(:sub_order)}

  it { should validate_presence_of (:trans_id)}
  it { should validate_uniqueness_of (:trans_id)}

  it 'should destroy last outstanding signup if an order has been placed with that trans id' do
    outstanding_signup = FactoryGirl.build(:outstanding_signup)
    outstanding_signup.save
    order.save
    order.trans_id = OutstandingSignup.last.trans_id
    order.save
    OutstandingSignup.refresh_outstanding_signups
    expect(OutstandingSignup.all).to eq([])
  end

  it 'should not save down if the tran id already exists on an order' do
    outstanding_signup = FactoryGirl.build(:outstanding_signup)
    order.trans_id = 123345
    order.save

    expect(outstanding_signup.valid?).to eq(false)

  end

end
