require 'spec_helper'

describe Sub do
  let (:sub) {FactoryGirl.create(:sub)}
  let (:sub1) {FactoryGirl.create(:sub)}
  let (:sub2) {FactoryGirl.create(:sub)}
  let (:sub3) {FactoryGirl.create(:sub)}
  let (:sub4) {FactoryGirl.create(:sub)}
  let (:sub5) {FactoryGirl.create(:sub)}
  let (:sub6) {FactoryGirl.create(:sub)}
  let (:order) {FactoryGirl.create(:sub_order)}
  let (:pref1) {FactoryGirl.create(:pref)}
  let (:pref2) {FactoryGirl.create(:pref)}
  let (:pref3) {FactoryGirl.create(:pref)}
  let (:pref4) {FactoryGirl.create(:pref)}
  let (:order1) {FactoryGirl.create(:sub_order)}
  let (:order2) {FactoryGirl.create(:sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:product4) {FactoryGirl.create(:product)}
  let (:product5) {FactoryGirl.create(:product)}

  it {should validate_presence_of (:cid)}
  it {should have_and_belong_to_many (:prefs)}
  it {should have_many (:sub_orders)}
  it {should validate_uniqueness_of(:cid) }

  it 'should obtain Chargify response based on cid that contains all pertinent information' do
      hash = sub.chargify
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
    
  it "should retrieve Wufoo preferences" do
    pref1.save
    pref2.pref = 'casual'
    pref2.save
    pref3.pref = 'fun'
    pref3.save

    expect(sub.retrieve_wufoo_prefs). to eq([pref1,pref3])

  end
  
  it 'should list prefs as string' do
    pref1.save
    pref2.pref = 'casual'
    pref2.save
    pref3.pref = 'fun'
    pref3.save
    pref4.pref = 'fashion'
    pref4.save
    sub1.prefs << [pref1,pref2,pref3,pref4]
    sub1.save
    
    expect(sub1.list_prefs).to eq('BCWF')
  end
    
  it "should provide a list of previously purchased SKUs" do
    sub.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    product4.sku = 'sku_4'
    product4.save
    product5.sku = 'sku_5'
    product5.save


    order1.line_items.create(product_id: product1.id, q: 1, rate: 0.0)
    order1.line_items.create(product_id: product2.id, q: 1, rate: 0.0)


    order2.line_items.create(product_id: product3.id, q: 1, rate: 0.0)
    order2.line_items.create(product_id: product4.id, q: 1, rate: 0.0)

    sub.sub_orders << [order1,order2]


    expect(sub.order_history).to eq(['sku_3', 'sku_4', 'sku_1', 'sku_2'])

  end
  
  it 'should indicate whether a given sku has already been sent to sub' do
    sub.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    product4.sku = 'sku_4'
    product4.save
    product5.sku = 'sku_5'
    product5.save
    
    order1.line_items.create(product_id: product1.id, q: 1, rate: 0.0)
    order1.line_items.create(product_id: product2.id, q: 1, rate: 0.0)

    order2.line_items.create(product_id: product3.id, q: 1, rate: 0.0)
    order2.line_items.create(product_id: product4.id, q: 1, rate: 0.0)
    
    sub.sub_orders << [order1,order2]
    
    expect(sub.dupe?('sku_5')).to eq(false)
    expect(sub.dupe?('sku_4')).to eq(true)
  end

  it 'should indicate whether a future order was already created given an order date' do
    sub.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    order1.line_items.create(product_id: product1.id, q: 1, rate: 0.0)
    order1.line_items.create(product_id: product2.id, q: 1, rate: 0.0)
    order1.created_at = Time.new(2014,1,1)
    order1.sub = sub
    order1.save
    
    expect(sub.order_already_created?(Time.new)).to eq(false)
    expect(sub.order_already_created?(Time.new(2014,1,1))).to eq(true)
  end
  
end
