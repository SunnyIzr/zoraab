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

    expect(batch1.get_prod_data).to eq({'ms-cr704'=> {:sku=>"ms-cr704",
       :title=>"Concrete Rose",
       :price=>nil,
       :q=>961,
       :vendor=>"Mint Socks",
       :tags=>"Blocks, Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Pink, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-CR704.jpg?v=1385514743",
       :publish_date=>"2013-11-26T15:41:02-05:00"},'ms-at707'=> {:sku=>"ms-at707",
       :title=>"Antiquity",
       :price=>nil,
       :q=>901,
       :vendor=>"Mint Socks",
       :tags=>"Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047",
       :publish_date=>"2013-11-26T15:41:32-05:00"},'ms-mk709'=> {:sku=>"ms-mk709",
       :title=>"Marakkesh",
       :price=>nil,
       :q=>939,
       :vendor=>"Mint Socks",
       :tags=>"Blue, Brown, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Orange, Print",
       :pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816",
       :small_pic=>"http://cdn.shopify.com/s/files/1/0127/4312/products/MS-MK709.jpg?v=1385514816",
       :publish_date=>"2013-11-26T15:40:37-05:00"}})
  end

  it 'should prepare a new batch with subs and orders' do
    expect(batch1.setup_new(30)).to eq({subs: [], orders: []})
  end
end
