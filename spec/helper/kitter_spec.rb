require 'spec_helper'

describe Kitter do
  let (:dress_prod_list) {%w[D0 D1 D2 D3]}
  let (:fashion_prod_list) {%w[F0 F1 F2 F3]}
  let (:casual_prod_list) {%w[C0 C1 C2 C3]}
  let (:wild_prod_list) {%w[W0 W1 W2 W3]}
  let (:sub) {FactoryGirl.create(:sub)}
  let (:pref1) {FactoryGirl.create(:pref)}
  let (:pref2) {FactoryGirl.create(:pref)}
  let (:pref3) {FactoryGirl.create(:pref)}
  let (:pref4) {FactoryGirl.create(:pref)}
  let (:order1) {FactoryGirl.create(:sub_order)}
  let (:order2) {FactoryGirl.create(:sub_order)}
  let (:order3) {FactoryGirl.create(:sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:product4) {FactoryGirl.create(:product)}
  let (:product5) {FactoryGirl.create(:product)}
  let (:product6) {FactoryGirl.create(:product)}

  it "should produce the inputted list of there is only one list" do
    expect(Kitter.alt_between_lists([dress_prod_list])).to eq (%w[D0 D1 D2 D3])
  end

  it "should produce an array that alternates between an array of 2 separate product lists" do
    expect(Kitter.alt_between_lists([dress_prod_list,fashion_prod_list])).to eq (%w[D0 F0 D1 F1 D2 F2 D3 F3])
  end

  it "should produce an array that alternates between an array of 3 separate product lists" do
    expect(Kitter.alt_between_lists([dress_prod_list,fashion_prod_list, casual_prod_list])).to eq (%w[D0 F0 C0 D1 F1 C1 D2 F2 C2 D3 F3 C3])
  end

  it "should produce an array that alternates between an array of 4 separate product lists" do
    expect(Kitter.alt_between_lists([dress_prod_list,fashion_prod_list, casual_prod_list,wild_prod_list])).to eq (%w[D0 F0 C0 W0 D1 F1 C1 W1 D2 F2 C2 W2 D3 F3 C3 W3])
  end

  it 'should provide list of products based on a given pref that does not contain any previously ordered items' do
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

    product4.sku = 'sku_4'
    product4.prefs << pref1
    product4.prefs << pref3
    product4.q = 2
    product4.save

    product5.sku = 'sku_5'
    product5.prefs << pref3
    product5.q = 3
    product5.save

    order1.products << [product1,product2]
    order2.products << [product3]
    sub.sub_orders << [order1,order2]

    expect(Kitter.remove_dupes(pref3.pref,sub.id)).to eq([product5,product4])
  end

  it 'should generate a list of suggestions based on prefs and order history in descending quantity order' do
    pref1.save
    pref2.pref = 'casual'
    pref2.save
    pref3.pref = 'fun'
    pref3.save
    pref4.pref = 'wild'
    pref4.save

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
    product3.q = 20
    product3.save

    product4.sku = 'sku_4'
    product4.prefs << pref1
    product4.prefs << pref3
    product4.q =1
    product4.save

    product5.sku = 'sku_5'
    product5.prefs << pref3
    product5.q = 3
    product5.save

    product6.sku = 'sku_6'
    product6.prefs << pref4
    product6.q = 3
    product6.save

    order1.products << [product1,product2]
    sub.sub_orders << order1
    sub.prefs << pref3

    expect(Kitter.generate_kitter_suggestions(sub.id)).to eq([product3,product5,product4])
    expect(Kitter.suggest_prod_ids(sub.id)).to eq([product3.id, product5.id, product4.id])

  end
end
