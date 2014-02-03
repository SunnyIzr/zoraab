require 'spec_helper'

describe Batch do
  let (:batch1) {FactoryGirl.create(:batch)}
  let (:batch2) {FactoryGirl.create(:batch)}
  let (:batch3) {FactoryGirl.create(:batch)}
  let (:order1) {FactoryGirl.create(:order)}
  let (:order2) {FactoryGirl.create(:order)}
  let (:order3) {FactoryGirl.create(:order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}


  it {should have_many (:orders)}

  it 'should destroy all batches' do
    batch1.save
    batch2.save
    batch3.save
    order1.save
    order2.save
    order3.save
    batch1.orders << order1
    batch3.orders << [order2,order3]
    Batch.destroy_empty_batches

    expect(Batch.all).to eq ([batch1,batch3])
  end

  it 'should obtain product data from Shopify for all batch order items' do
    batch1.save
    order1.save
    order2.save
    order3.save
    product1.sku = 'ms-cr704'
    product1.save
    product2.sku = 'ms-at707'
    product2.save
    product3.sku = 'ms-mk709'
    product3.save
    order1.products << [product1,product2]
    order1.save
    order2.products << [product2,product3]
    order2.save
    order3.products << product3
    order3.save
    batch1.orders << [order1,order2,order3]
    data = batch1.get_prod_data
    p data

     expect(data['ms-cr704'][:sku]).to eq("ms-cr704")
     expect(data['ms-cr704'][:title]).to eq("Concrete Rose")
     expect(data['ms-cr704'][:price]).to eq(11.0)
     expect(data['ms-cr704'][:vendor]).to eq("Mint Socks")
     expect(data['ms-cr704'][:tags]).to eq("Blocks, Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Pink, Print")
     expect(data['ms-cr704'][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743")
     expect(data['ms-cr704'][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743")
     expect(data['ms-cr704'][:publish_date]).to eq("2013-11-26T15:41:02-05:00")
     expect(data['ms-at707'][:sku]).to eq("ms-at707")
     expect(data['ms-at707'][:title]).to eq("Antiquity")
     expect(data['ms-at707'][:price]).to eq(11.0)
     expect(data['ms-at707'][:vendor]).to eq("Mint Socks")
     expect(data['ms-at707'][:tags]).to eq("Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Print")
     expect(data['ms-at707'][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047")
     expect(data['ms-at707'][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047")
     expect(data['ms-at707'][:publish_date]).to eq("2013-11-26T15:41:32-05:00")
     expect(data['ms-mk709'][:sku]).to eq("ms-mk709")
     expect(data['ms-mk709'][:title]).to eq("Marakkesh")
     expect(data['ms-mk709'][:price]).to eq(11.0)
     expect(data['ms-mk709'][:vendor]).to eq("Mint Socks")
     expect(data['ms-mk709'][:tags]).to eq("Blue, Brown, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Orange, Print")
     expect(data['ms-mk709'][:pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816")
     expect(data['ms-mk709'][:small_pic]).to eq("http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816")
     expect(data['ms-mk709'][:publish_date]).to eq("2013-11-26T15:40:37-05:00")
  end

  it 'should prepare a new batch with subs and orders' do
    expect(batch1.setup_new(30)).to eq({subs: [], orders: []})
  end
end
