require 'spec_helper'

describe Order do
  let (:order1) {FactoryGirl.create(:order)}
  let (:order2) {FactoryGirl.create(:order)}
  let (:sub) {FactoryGirl.create(:sub)}

  it {should validate_presence_of (:sub_id)}
  it {should have_and_belong_to_many (:products)}
  it {should belong_to (:sub)}
  it {should belong_to (:batch)}
  it "should create an order number that starts with prespecified prefix" do
    order1.save
    expect(order1.order_number[0]).to eq('K')
    expect(order1.order_number.length).to eq(5)
  end

  it "should set order details with appropriate response hash" do
    order1.sub = sub
    order1.set_order_details
    order1.save
    expect(order1.name).to eq ('SunnyShip IsraniShip')
    expect(order1.email).to eq ('sunny@zoraab.com')
    expect(order1.plan).to eq ('Sock Dabbler (2 Pairs/Mo)')
    expect(order1.address).to eq ('123 Shipping Street')
    expect(order1.address2).to eq (nil)
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

  it 'should provide a list of pending orders' do
    order1.save
    order2.save
    expect(Order.pending).to eq([order1,order2])
  end
end
