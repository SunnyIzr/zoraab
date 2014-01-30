require 'spec_helper'

describe Product do
  let (:pref1) {FactoryGirl.create(:pref)}
  let (:pref2) {FactoryGirl.create(:pref)}
  let (:pref3) {FactoryGirl.create(:pref)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  it { should validate_presence_of (:sku)}
  it { should validate_uniqueness_of (:sku)}
  it { should have_and_belong_to_many (:prefs)}

  it 'should provide a filtered products list' do
    pref1.save
    pref2.pref = 'casual'
    pref2.save
    pref3.pref = 'fun'
    pref3.save

    product1.sku = 'sku_1'
    product1.prefs << pref1
    product1.prefs << pref2
    product1.q = 10
    product1.save

    product2.sku = 'sku_2'
    product2.prefs << pref2
    product2.prefs << pref3
    product2.q = 4
    product2.save

    product3.sku = 'sku_3'
    product3.prefs << pref1
    product3.prefs << pref3
    product3.q = 2
    product3.save

    expect(Product.filter('casual')).to eq([product1,product2])
  end


end
