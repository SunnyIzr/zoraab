require 'spec_helper'

describe Order do
  let (:order1) {FactoryGirl.create(:order)}
  let (:order2) {FactoryGirl.create(:order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
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

  it 'should set the products of an order based on an ary of skus' do
    order1.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    order1.set_order_products(['sku_1','sku_2'])
    expect(order1.products).to eq([product1,product2])
  end

  it 'should obtain product data from Shopify for order items' do
    order1.save
    product1.sku = 'ms-cr704'
    product1.save
    product2.sku = 'ms-at707'
    product2.save
    product3.sku = 'ms-mk709'
    product3.save
    order1.products << [product1,product2,product3]
    order1.save
    expect(order1.get_prod_data).to eq([{:sku=>"ms-cr704",
       :title=>"Concrete Rose",
       :price=>nil,
       :q=>961,
       :vendor=>"Mint Socks",
       :tags=>"Blocks, Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Pink, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743",
       :publish_date=>"2013-11-26T15:41:02-05:00"},{:sku=>"ms-at707",
       :title=>"Antiquity",
       :price=>nil,
       :q=>901,
       :vendor=>"Mint Socks",
       :tags=>"Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047",
       :publish_date=>"2013-11-26T15:41:32-05:00"},{:sku=>"ms-mk709",
       :title=>"Marakkesh",
       :price=>nil,
       :q=>939,
       :vendor=>"Mint Socks",
       :tags=>"Blue, Brown, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Orange, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816",
       :publish_date=>"2013-11-26T15:40:37-05:00"}])
  end
end
