require 'spec_helper'

describe UpfrontSubOrder do
  let (:upfront_sub_order1) {FactoryGirl.create(:upfront_sub_order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}
  let (:product3) {FactoryGirl.create(:product)}

  it 'should return single installment value' do
    sub = FactoryGirl.create(:sub, type: 'UpfrontSub', term: 6)
    upfront_sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo) - Upfront'
    upfront_sub_order1.amt = 120.0
    upfront_sub_order1.trans_id = 12345
    upfront_sub_order1.sub = sub
    upfront_sub_order1.set_order_details
    upfront_sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    upfront_sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    upfront_sub_order1.order_number = 'TEST UPFRONTSUBORDER'
    upfront_sub_order1.save

    expect(upfront_sub_order1.single_installment).to eq(20.0)

  end

  it 'should return residual' do
    sub = FactoryGirl.create(:sub, type: 'UpfrontSub', term: 6)
    upfront_sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo) - Upfront'
    upfront_sub_order1.amt = 120.0
    upfront_sub_order1.trans_id = 12345
    upfront_sub_order1.sub = sub
    upfront_sub_order1.set_order_details
    upfront_sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    upfront_sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    upfront_sub_order1.order_number = 'TEST UPFRONTSUBORDER'
    upfront_sub_order1.save

    expect(upfront_sub_order1.residual).to eq(100.0)

  end

  it 'should installment and residual line items for first upfront sub order' do
    sub = FactoryGirl.create(:sub, type: 'UpfrontSub', term: 6)
    upfront_sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo) - Upfront'
    upfront_sub_order1.amt = 120.0
    upfront_sub_order1.trans_id = 12345
    upfront_sub_order1.sub = sub
    upfront_sub_order1.set_order_details
    upfront_sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    product4 = Product.create(sku:'Unearned Subscription Sales')
    upfront_sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    upfront_sub_order1.order_number = 'TEST UPFRONTSUBORDER'
    upfront_sub_order1.save

    expect(upfront_sub_order1.line_items.size).to eq(4)
    expect(upfront_sub_order1.line_items[0].product).to eq(Product.find_by(sku:upfront_sub_order1.plan))
    expect(upfront_sub_order1.line_items[0].rate).to eq(upfront_sub_order1.single_installment)
    expect(upfront_sub_order1.line_items[1].product).to eq(Product.find_by(sku:'Unearned Subscription Sales'))
    expect(upfront_sub_order1.line_items[1].rate).to eq(upfront_sub_order1.residual)

  end

  it 'should create an upfront sub order for a new sub with appropriate line items' do
    sub = FactoryGirl.create(:sub, type: 'UpfrontSub', term: 6)
    upfront_sub_order1.amt = 120.0
    upfront_sub_order1.trans_id = 12345
    upfront_sub_order1.sub = sub
    upfront_sub_order1.set_order_details
    upfront_sub_order1.plan = 'Sock Dabbler (2 Pairs/Mo) - 6 Months Upfront'
    upfront_sub_order1.save
    product1.sku = 'ms-at707'
    product1.save
    product2.sku = 'ms-ce708'
    product2.save
    product3.sku = 'ms-hk702'
    product3.save
    product4 = Product.create(sku:'Unearned Subscription Sales')
    upfront_sub_order1.set_order_line_items(['ms-at707','ms-ce708'])
    upfront_sub_order1.order_number = 'TEST UPFRONTSUBORDER'
    upfront_sub_order1.save

    upfront_sub_order1.save_to_qb
    qb_order = Qb.get_order('TEST UPFRONTSUBORDER')

    expect(qb_order.line_items[0].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[0].sales_item_line_detail.item_ref.name).to eq('Sock Dabbler (2 Pairs/Mo) - 6 Months Upfront')
    expect(qb_order.line_items[0].sales_item_line_detail.unit_price.to_f).to eq(20.0)
    expect(qb_order.line_items[0].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[0].amount.to_f).to eq(20.0)

    expect(qb_order.line_items[0].detail_type).to eq('SalesItemLineDetail')
    expect(qb_order.line_items[0].sales_item_line_detail.item_ref.name).to eq('Unearned Subscription Sales')
    expect(qb_order.line_items[0].sales_item_line_detail.unit_price.to_f).to eq(100.0)
    expect(qb_order.line_items[0].sales_item_line_detail.quantity.to_i).to eq(1)
    expect(qb_order.line_items[0].amount.to_f).to eq(20.0)

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

    Qb.delete_order('TEST UPFRONTSUBORDER')

  end
end
