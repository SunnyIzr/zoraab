require 'spec_helper'

describe OutstandingRenewal do
  let (:order) {FactoryGirl.create(:order)}

  it { should validate_presence_of (:trans_id)}
  it { should validate_uniqueness_of (:trans_id)}

  it 'should destroy last outstanding renewal if an order has been placed with that trans id' do
    outstanding_renewal = FactoryGirl.build(:outstanding_renewal)
    outstanding_renewal.save
    order.save
    order.trans_id = OutstandingRenewal.last.trans_id
    order.save
    OutstandingRenewal.refresh_outstanding_renewals
    expect(OutstandingRenewal.all).to eq([])
  end

  it 'should not save down if the trans id already exists on an order' do
    outstanding_renewal = FactoryGirl.build(:outstanding_renewal)
    order.trans_id = 123345
    order.save

    expect(outstanding_renewal.valid?).to eq(false)
  end
end
