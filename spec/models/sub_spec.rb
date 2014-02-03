require 'spec_helper'

describe Sub do
  let (:sub) {FactoryGirl.create(:sub)}
  let (:sub1) {FactoryGirl.create(:sub)}
  let (:sub2) {FactoryGirl.create(:sub)}
  let (:sub3) {FactoryGirl.create(:sub)}
  let (:sub4) {FactoryGirl.create(:sub)}
  let (:sub5) {FactoryGirl.create(:sub)}
  let (:sub6) {FactoryGirl.create(:sub)}
  let (:order) {FactoryGirl.create(:order)}
  let (:pref1) {FactoryGirl.create(:pref)}
  let (:pref2) {FactoryGirl.create(:pref)}
  let (:pref3) {FactoryGirl.create(:pref)}
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

  it "should retrieve Wufoo preferences" do
    pref1.save
    pref2.pref = 'casual'
    pref2.save
    pref3.pref = 'fun'
    pref3.save

    expect(sub.retrieve_wufoo_prefs). to eq([pref1,pref3])

  end

  it 'should obtain Chargify response based on cid that contains all pertinent information' do
    expect(sub.chargify['state']).to eq('canceled')
    expect(sub.chargify['customer'].first_name).to eq('SunnyShip')
    expect(sub.chargify['customer'].last_name).to eq('IsraniShip')
    expect(sub.chargify['customer'].email).to eq('sunny@zoraab.com')
    expect(sub.chargify['product'].name).to eq('Sock Dabbler (2 Pairs/Mo)')

  end

  it 'should indicate whether an order for the next pmt date was NOT created' do
    sub.save
    next_pmt_date = ChargifyResponse.next_pmt_date(sub.chargify)
    order.created_at = next_pmt_date
    order.save
    sub.orders << order
    expect(sub.not_exist?(next_pmt_date)).to eq(false)
  end

  it "should pull back all subs that are due within a time period" do
    subs = Sub.retrieve_all_active_subs
    subs_due = []
    subs_not_due = []
    subs.each { |key,value| subs_due << key if value[:next_pmt_date] < (Time.new + (5.day)) }
    subs.each { |key,value| subs_not_due << key if value[:next_pmt_date] > (Time.new + (5.day)) }
    sub1.cid = subs_due[0]
    sub1.save
    sub2.cid = subs_due[1]
    sub2.save
    sub3.cid = subs_due[2]
    sub3.save
    sub4.cid = subs_not_due[0]
    sub4.save
    sub5.cid = subs_not_due[1]
    sub5.save
    sub6.cid = subs_not_due[2]
    sub6.save
    expect(Sub.pull_subs_due(5)).to eq({sub1.cid => subs[sub1.cid], sub2.cid => subs[sub2.cid], sub3.cid => subs[sub3.cid]})
  end



end
