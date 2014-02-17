require 'spec_helper'

describe SubOrder do
  let (:order1) {FactoryGirl.create(:order)}
  let (:order2) {FactoryGirl.create(:order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}

  it {should have_many (:line_items)}

  it 'should obtain product data from Shopify for order items' do
    order1.save
    product1.sku = 'ms-cr704'
    product1.save
    product2.sku = 'ms-at707'
    product2.save
    product3.sku = 'ms-mk709'
    product3.save
    order1.line_items.create(product_id: product1.id, q: 1, rate: 10.0)
    order1.line_items.create(product_id: product2.id, q: 1, rate: 10.0)
    order1.line_items.create(product_id: product3.id, q: 1, rate: 10.0)
    data = order1.get_prod_data

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

  it 'should indicate if an order was sent to shipstation and if/when it was shipped' do
    order1.save
    order2.ssid = 79066562
    order2.save
    expect(order1.ship_state).to eq('Never Sent to Shipstation')
    expect(order2.ship_state).to eq('Shipped - Mon 10 Feb 2014')
  end
end
