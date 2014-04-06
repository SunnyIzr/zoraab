require 'spec_helper'

describe Invoice do

  it 'should reallocate shipping charge to line items' do
    invoice = FactoryGirl.create(:invoice, shipping: 375.00)
    3.times do |i|
      line_item = invoice.line_items.new(rate: (i+1)*10, q: (i+1)*7)
      line_item.product = FactoryGirl.create(:product, sku: 'sku' + i.to_s)
      line_item.save
    end
    invoice.allocate_shipping
    
    expect(invoice.total).to eq(1355.00)
    expect(invoice.shipping).to eq(0.0)
  end

end
