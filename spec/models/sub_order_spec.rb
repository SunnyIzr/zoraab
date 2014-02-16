require 'spec_helper'

describe SubOrder do
  let (:sub_order1) {FactoryGirl.create(:sub_order)}
  let (:sub_order2) {FactoryGirl.create(:sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:sub) {FactoryGirl.create(:sub)}

  it {should validate_presence_of (:sub_id)}
  it {should have_and_belong_to_many (:products)}
  it {should belong_to (:sub)}
  it {should belong_to (:batch)}

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

  it 'should provide a list of pending orders' do
    sub_order1.save
    sub_order2.save
    expect(SubOrder.pending).to eq([sub_order1,sub_order2])
  end

  it 'should set the products of an order based on an ary of skus' do
    sub_order1.save
    product1.sku = 'sku_1'
    product1.save
    product2.sku = 'sku_2'
    product2.save
    product3.sku = 'sku_3'
    product3.save
    sub_order1.set_order_products(['sku_1','sku_2'])
    expect(sub_order1.products).to eq([product1,product2])
  end

  it 'should obtain product data from Shopify for order items' do
    sub_order1.save
    product1.sku = 'ms-cr704'
    product1.save
    product2.sku = 'ms-at707'
    product2.save
    product3.sku = 'ms-mk709'
    product3.save
    sub_order1.products << [product1,product2,product3]
    sub_order1.save
    data = sub_order1.get_prod_data

     expect(data[0][:sku]).to eq("ms-cr704")
     expect(data[0][:title]).to eq("Concrete Rose")
     expect(data[0][:price]).to eq(11.0)
     expect(data[0][:vendor]).to eq("Mint Socks")
     expect(data[0][:tags]).to eq("Blocks, Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Pink, Print")
     expect(data[0][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743")
     expect(data[0][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743")
     expect(data[0][:publish_date]).to eq("2013-11-26T15:41:02-05:00")
     expect(data[1][:sku]).to eq("ms-at707")
     expect(data[1][:title]).to eq("Antiquity")
     expect(data[1][:price]).to eq(11.0)
     expect(data[1][:vendor]).to eq("Mint Socks")
     expect(data[1][:tags]).to eq("Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Print")
     expect(data[1][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047")
     expect(data[1][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047")
     expect(data[1][:publish_date]).to eq("2013-11-26T15:41:32-05:00")
     expect(data[2][:sku]).to eq("ms-mk709")
     expect(data[2][:title]).to eq("Marakkesh")
     expect(data[2][:price]).to eq(11.0)
     expect(data[2][:vendor]).to eq("Mint Socks")
     expect(data[2][:tags]).to eq("Blue, Brown, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Orange, Print")
     expect(data[2][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816")
     expect(data[2][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816")
     expect(data[2][:publish_date]).to eq("2013-11-26T15:40:37-05:00")
  end
end
