require 'spec_helper'

describe ChargifyResponse do
  let (:sub) { FactoryGirl.create(:sub)}
  let (:response) {sub.chargify}

   it "should display name" do
    expect(ChargifyResponse.name(response)).to eq('SunnyShip IsraniShip')
  end

  it "should dispaly email" do
    expect(ChargifyResponse.email(response)).to eq('sunny@zoraab.com')
  end

  it "should display plan" do
    expect(ChargifyResponse.plan(response)).to eq('Sock Dabbler (2 Pairs/Mo)')
  end

  it "should display price" do
    expect(ChargifyResponse.price(response)).to eq(20)
  end
  it "should display number of items in each subscription" do
    expect(ChargifyResponse.items(response)).to eq(2)
  end

  it 'should display plan status' do
    expect(ChargifyResponse.status(response)).to eq('canceled')
  end

  it "should display start_date" do
    expect(ChargifyResponse.start_date(response)).to eq('25 Nov 2013')
  end


  it "should display shipping_address" do
    expect(ChargifyResponse.shipping_address(response)).to eq({
        :name => 'SunnyShip IsraniShip',
        :address => '123 Shipping Street',
        :address2 => nil,
        :city => 'Ship City',
        :state => 'ON',
        :zip => '12345',
        :country => 'CA',
        :phone => nil
      })
  end


  it "should display billing_address" do
    expect(ChargifyResponse.billing_address(response)).to eq({
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

  it "should display all parsed data in a hash" do
    hash = ChargifyResponse.parse(response)
    expect(hash[:id]).to eq(4258861)
    expect(hash[:name]).to eq('SunnyShip IsraniShip')
    expect(hash[:email]).to eq('sunny@zoraab.com')
    expect(hash[:plan]).to eq('Sock Dabbler (2 Pairs/Mo)')
    expect(hash[:price]).to eq(20)
    expect(hash[:items]).to eq(2)
    expect(hash[:status]).to eq('canceled')
    expect(hash[:start_date]).to eq('25 Nov 2013')
    expect(hash[:shipping_address]).to eq({
          :name => 'SunnyShip IsraniShip',
          :address => '123 Shipping Street',
          :address2 => nil,
          :city => 'Ship City',
          :state => 'ON',
          :zip => '12345',
          :country => 'CA',
          :phone => nil
        })
    expect(hash[:billing_address]).to eq({
          :name => 'Sunny Israni',
          :address => '43 Rosenbrook Drive',
          :address2 => nil,
          :city => 'Lincoln Park',
          :state => 'NJ',
          :zip => '07035',
          :country => 'US',
          :phone => nil})
  end


end
