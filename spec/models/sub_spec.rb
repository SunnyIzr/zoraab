require 'spec_helper'

describe Sub do
  let (:sub) {FactoryGirl.create(:sub)}
  let (:order1) {FactoryGirl.create(:order)}
  let (:order2) {FactoryGirl.create(:order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:product4) {FactoryGirl.create(:product)}
  let (:product5) {FactoryGirl.create(:product)}

  it {should validate_presence_of (:cid)}
  it {should have_and_belong_to_many (:prefs)}
  it {should have_many (:orders)}
  it {should validate_uniqueness_of(:cid) }

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

    order1.products << [product1,product2]
    order2.products << [product3,product4]
    sub.orders << [order1,order2]


    expect(sub.order_history).to eq(['sku_3', 'sku_4', 'sku_1', 'sku_2'])




  end

end
