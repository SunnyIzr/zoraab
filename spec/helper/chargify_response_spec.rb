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
    expect(ChargifyResponse.price(response)).to eq(22)
  end
  it "should display number of items in each subscription" do
    expect(ChargifyResponse.items(response)).to eq(2)
  end

  it 'should display plan status' do
    expect(ChargifyResponse.status(response)).to eq('canceled')
  end

  it "should display start_date" do
    expect(ChargifyResponse.start_date(response)).to eq('09 Oct 2012')
  end


  it "should display shipping_address" do
    expect(ChargifyResponse.shipping_address(response)).to eq({
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
    expect(ChargifyResponse.parse(response)).to eq ({
        name: 'SunnyShip IsraniShip',
        email: 'sunny@zoraab.com',
        plan: 'Sock Dabbler (2 Pairs/Mo)',
        price: 22,
        items: 2,
        status: 'canceled',
        start_date: '09 Oct 2012',
        shipping_address: {
          :name => 'SunnyShip IsraniShip',
          :address => '123 Shipping Street',
          :address2 => 'Shipping Apt Number',
          :city => 'Ship City',
          :state => 'ON',
          :zip => '12345',
          :country => 'CA',
          :phone => '2012749118'
        },
        billing_address: {
          :name => 'Sunny Israni',
          :address => '43 Rosenbrook Drive',
          :address2 => nil,
          :city => 'Lincoln Park',
          :state => 'NJ',
          :zip => '07035',
          :country => 'US',
          :phone => nil
        }
      })
  end


end
