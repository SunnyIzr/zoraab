require 'spec_helper'

describe Order do
  it {should validate_presence_of (:sub_id)}
  it {should have_and_belong_to_many (:products)}
  it {should belong_to (:sub)}
  let (:order1) {FactoryGirl.create(:order)}
  let (:response) {{
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
      }}

  it "should set order details with appropriate resposne hash" do
    order1.set_order_details(response)
    order1.save
    expect(order1.name).to eq ('SunnyShip IsraniShip')
    expect(order1.email).to eq ('sunny@zoraab.com')
    expect(order1.plan).to eq ('Sock Dabbler (2 Pairs/Mo)')
    expect(order1.address).to eq ('123 Shipping Street')
    expect(order1.address2).to eq ('Shipping Apt Number')
    expect(order1.city).to eq ('Ship City')
    expect(order1.state).to eq ('ON')
    expect(order1.zip).to eq ('12345')
    expect(order1.country).to eq ('CA')
    expect(order1.billing_name).to eq ('Sunny Israni')
    expect(order1.billing_address).to eq ('43 Rosenbrook Drive')
    expect(order1.billing_address2).to eq (nil)
    expect(order1.billing_city).to eq ('Lincoln Park')
    expect(order1.billing_state).to eq ('NJ')
    expect(order1.billing_zip).to eq ('07035')
    expect(order1.billing_country).to eq ('US')
  end
end
