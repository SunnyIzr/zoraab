require 'spec_helper'

describe SubOrder do
  let (:sub_order1) {FactoryGirl.create(:sub_order)}
  let (:sub_order2) {FactoryGirl.create(:sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:sub) {FactoryGirl.create(:sub)}

  it {should validate_presence_of (:sub_id)}
  it {should validate_uniqueness_of (:trans_id)}
  it {should belong_to (:sub)}
  it {should belong_to (:batch)}

  it 'should provide a list of pending orders' do
    sub_order1.save
    sub_order2.save
    expect(SubOrder.pending).to eq([sub_order1,sub_order2])
  end

  it "should create an order number that starts with prespecified prefix" do
    sub_order1.save
    expect(sub_order1.order_number[0]).to eq('Z')
    expect(sub_order1.order_number[1]).to eq('K')
    expect(sub_order1.order_number.length).to eq(6)
  end

  it "should set order details with appropriate response hash" do
    sub_order1.sub = sub
    sub_order1.set_order_details
    sub_order1.save
    expect(sub_order1.name).to eq ('SunnyShip IsraniShip')
    expect(sub_order1.email).to eq ('sunny@zoraab.com')
    expect(sub_order1.plan).to eq ('Sock Dabbler (2 Pairs/Mo)')
    expect(sub_order1.address).to eq ('123 Shipping Street')
    expect(sub_order1.address2).to eq (nil)
    expect(sub_order1.city).to eq ('Ship City')
    expect(sub_order1.state).to eq ('ON')
    expect(sub_order1.zip).to eq ('12345')
    expect(sub_order1.country).to eq ('CA')
    expect(sub_order1.billing_name).to eq ('Sunny Israni')
    expect(sub_order1.billing_address).to eq ('43 Rosenbrook Drive')
    expect(sub_order1.billing_address2).to eq (nil)
    expect(sub_order1.billing_city).to eq ('Lincoln Park')
    expect(sub_order1.billing_state).to eq ('NJ')
    expect(sub_order1.billing_zip).to eq ('07035')
    expect(sub_order1.billing_country).to eq ('US')
  end


  it 'should set the line items of an order based on an ary of skus' do
    sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo)'
    sub_order1.amt = 39.0
    sub_order1.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    sub_order1.set_order_line_items(['sku_1','sku_2'])
    expect(sub_order1.line_items[0].product.sku).to eq(sub_order1.plan)
    expect(sub_order1.line_items[0].q).to eq(1)
    expect(sub_order1.line_items[0].rate).to eq(sub_order1.amt)
    expect(sub_order1.line_items[1].product.sku).to eq(product1.sku)
    expect(sub_order1.line_items[1].q).to eq(1)
    expect(sub_order1.line_items[1].rate).to eq(0.0)
    expect(sub_order1.line_items[2].product.sku).to eq(product2.sku)
    expect(sub_order1.line_items[2].q).to eq(1)
    expect(sub_order1.line_items[2].rate).to eq(0.0)
  end

  it 'should calc and save fees once sub order is saved' do
    sub_order1.save
    sub_order1.amt = 18.0
    sub_order1.save
    expect(sub_order1.fees).to eq(0.82)
  end

  it 'should not calc any fees once sub order is saved if amt is 0' do
    sub_order1.save
    expect(sub_order1.fees).to eq(0.0)
  end

  it 'should set braintree as the payment gateway upon saving' do
    sub_order1.save
    expect(sub_order1.gateway).to eq('braintree')
  end

  it 'should create a formatted hash for QB order import' do
    sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo)'
    sub_order1.amt = 39.0
    sub_order1.trans_id = 12345
    sub_order1.sub = sub
    sub_order1.set_order_details
    sub_order1.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    sub_order1.set_order_line_items(['sku_1','sku_2'])
    qbo = sub_order1.qb

    expect(qbo[:type]).to eq('Subscription')
    expect(qbo[:number]).to eq(sub_order1.order_number)
    expect(qbo[:created_at]).to eq(sub_order1.created_at)
    expect(qbo[:email]).to eq('sunny@zoraab.com')
    expect(qbo[:gateway]).to eq('braintree')
    expect(qbo[:shipping_total]).to eq('0.0')
    expect(qbo[:gift_card_redemption]).to eq(nil)
    expect(qbo[:total]).to eq('39.0')
    expect(qbo[:fees]).to eq({'Braintree Fee' => '1.43'})
    expect(qbo[:discount]).to eq('0.0')
    expect(qbo[:memo]).to eq('12345')
    expect(qbo[:billing_address][:name]).to eq('Sunny Israni')
    expect(qbo[:billing_address][:address1]).to eq('43 Rosenbrook Drive')
    expect(qbo[:billing_address][:city]).to eq('Lincoln Park')
    expect(qbo[:billing_address][:state]).to eq('NJ')
    expect(qbo[:billing_address][:zip]).to eq('07035')
    expect(qbo[:billing_address][:country]).to eq('US')
    expect(qbo[:shipping_address][:name]).to eq('SunnyShip IsraniShip')
    expect(qbo[:shipping_address][:address1]).to eq('123 Shipping Street')
    expect(qbo[:shipping_address][:city]).to eq('Ship City')
    expect(qbo[:shipping_address][:state]).to eq('ON')
    expect(qbo[:shipping_address][:zip]).to eq('12345')
    expect(qbo[:shipping_address][:country]).to eq('CA')
  end

  it 'should create a formatted hash for QB order line items import' do
    sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo)'
    sub_order1.amt = 39.0
    sub_order1.trans_id = 12345
    sub_order1.sub = sub
    sub_order1.set_order_details
    sub_order1.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    sub_order1.set_order_line_items(['sku_1','sku_2'])
    qbo = sub_order1.qb

    expect(qbo[:line_items][0][:sku]).to eq('Sock Dabbler (2 Pairs/Mo)')
    expect(qbo[:line_items][0][:price]).to eq('39.0')
    expect(qbo[:line_items][0][:q]).to eq(1)
    expect(qbo[:line_items][1][:sku]).to eq('sku_1')
    expect(qbo[:line_items][1][:price]).to eq('0.0')
    expect(qbo[:line_items][1][:q]).to eq(1)
    expect(qbo[:line_items][2][:sku]).to eq('sku_2')
    expect(qbo[:line_items][2][:price]).to eq('0.0')
    expect(qbo[:line_items][2][:q]).to eq(1)

  end



end
