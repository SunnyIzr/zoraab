require 'spec_helper'

describe Qb do
  let (:sub_order1) {FactoryGirl.create(:sub_order)}
  let (:sub_order2) {FactoryGirl.create(:sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}
  let (:sub) {FactoryGirl.create(:sub)}

  it 'should create a sub_order with all the relevant details' do
    sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo)'
    sub_order1.amt = 39.0
    sub_order1.trans_id = 48837466
    sub_order1.sub = sub
    sub_order1.set_order_details
    sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    sub_order1.order_number = 'TEST SUBORDER'
    sub_order1.save
    qbo = sub_order1.qb
    Qb.create_order(qbo)
    qb_order = Qb.get_order('TEST SUBORDER')

    expect(qb_order.doc_number).to eq(sub_order1.order_number)
    expect(qb_order.customer_ref.name).to eq('Subscriptions')
    expect(qb_order.bill_email.address).to eq('sunny@zoraab.com')
    expect(qb_order.payment_method_ref.name).to eq('braintree')
    expect(qb_order.private_note).to eq('12345')
    expect(qb_order.bill_address.line1).to eq('Sunny Israni')
    expect(qb_order.bill_address.line2).to eq('43 Rosenbrook Drive')
    expect(qb_order.bill_address.city).to eq('Lincoln Park')
    expect(qb_order.bill_address.country_sub_division_code).to eq('NJ')
    expect(qb_order.bill_address.country).to eq('US')
    expect(qb_order.bill_address.postal_code).to eq('07035')

    expect(qb_order.ship_address.line1).to eq('SunnyShip IsraniShip')
    expect(qb_order.ship_address.line2).to eq('123 Shipping Street')
    expect(qb_order.ship_address.city).to eq('Ship City')
    expect(qb_order.ship_address.country_sub_division_code).to eq('ON')
    expect(qb_order.ship_address.country).to eq('CA')
    expect(qb_order.ship_address.postal_code).to eq('12345')

    expect(qb_order.deposit_to_account_ref.name).to eq('Braintree AR')
    expect(qb_order.total.to_f).to eq(37.57)

    Qb.delete_order('TEST SUBORDER')
  end

  it 'should create a sub_order with all the relevant line_item details' do
    sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo)'
    sub_order1.amt = 39.0
    sub_order1.trans_id = 12345
    sub_order1.sub = sub
    sub_order1.set_order_details
    sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    sub_order1.order_number = 'TEST SUBORDER'
    sub_order1.save
    qbo = sub_order1.qb
    Qb.create_order(qbo)
    qb_order = Qb.get_order('TEST SUBORDER')

    expect(qb_order.line_items[0].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[0].sales_item_line_detail.item_ref.name).to eq('Sock Dabbler (2 Pairs/Mo)')
    expect(qb_order.line_items[0].sales_item_line_detail.unit_price.to_f).to eq(39.0)
    expect(qb_order.line_items[0].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[0].amount.to_f).to eq(39.0)

    expect(qb_order.line_items[1].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[1].sales_item_line_detail.item_ref.name).to eq('MS-AT707')
    expect(qb_order.line_items[1].sales_item_line_detail.unit_price.to_f).to eq(0.0)
    expect(qb_order.line_items[1].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[1].amount.to_f).to eq(0.0)

    expect(qb_order.line_items[2].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[2].sales_item_line_detail.item_ref.name).to eq('MS-CE708')
    expect(qb_order.line_items[2].sales_item_line_detail.unit_price.to_f).to eq(0.0)
    expect(qb_order.line_items[2].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[2].amount.to_f).to eq(0.0)

    expect(qb_order.line_items[3].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[3].sales_item_line_detail.item_ref.name).to eq('Braintree Fee')
    expect(qb_order.line_items[3].sales_item_line_detail.unit_price.to_f).to eq(-sub_order1.fees)
    expect(qb_order.line_items[3].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[3].amount.to_f).to eq(-sub_order1.fees)

    expect(qb_order.line_items[4].detail_type).to eq('SubTotalLineDetail')
    expect(qb_order.line_items[4].amount.to_f).to eq(sub_order1.net_amt)

    Qb.delete_order('TEST SUBORDER')
  end

end
