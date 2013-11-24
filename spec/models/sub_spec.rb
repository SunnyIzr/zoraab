require 'spec_helper'

describe Sub do
  let (:sub) { FactoryGirl.create(:sub)}
  let (:response) {sub.chargify}
  it {should validate_presence_of (:cid)}
  it {should have_and_belong_to_many (:prefs)}
  it {should have_many (:orders)}

  it "should display name" do
    expect(sub.name(response)).to eq('SunnyShip IsraniShip')
  end

  it "should dispaly email" do
    expect(sub.email(response)).to eq('sunny@zoraab.com')
  end


  it "should display plan" do
    expect(sub.plan(response)).to eq('Sock Dabbler (2 Pairs/Mo)')
  end

  it 'should display plan status' do
    expect(sub.status(response)).to eq('canceled')
  end


  it "should display start_date" do
    expect(sub.start_date(response)).to eq('09 Oct 2012')
  end


  it "should display shipping_address" do
    expect(sub.shipping_address(response)).to eq({
        :name => 'SunnyShip IsraniShip',
        :address => '123 Shipping Street',
        :address2 => 'Shipping Apt Number',
        :city => 'Ship City',
        :state => 'ON',
        :zip => '12345',
        :country => 'CA',
        :phone => '2012749118'
      })
  end


  it "should display billing_address" do
    expect(sub.billing_address(response)).to eq({
        :name => 'Sunny Israni',
        :address => '43 Rosenbrook Drive',
        :address2 => nil,
        :city => 'Lincoln Park',
        :state => 'NJ',
        :zip => '07035',
        :country => 'US',
        :phone => nil
      })
  end


end
