class Invoice < ActiveRecord::Base
  has_many :line_items, as: :line_itemable
  after_save :set_po_number

  def set_po_number
    unless self.po_number
      digits = 4 - self.id.to_s.length
      self.po_number = "I" + ("0"*digits) + self.id.to_s
      self.save
    end
  end

  def set_line_items(data)
    data.each do |li|
      prod = Product.find_or_create_by(sku: li[:sku].downcase)
      line_item = self.line_items.new(q: li[:q], rate: li[:price])
      line_item.product = prod
      line_item.save
    end
    self.calc_total
    self.save
  end

  def calc_total
    self.total = (self.line_items.map { |li| li.q*li.rate }.inject(:+)).round(2)
  end



  def qb
    {
      number: self.po_number,
      created_at: self.created_at,
      vendor: self.vendor,
      total: self.total.to_s,
      shipping: self.shipping.to_s,
      discount: self.discount.to_s,
      line_items: self.qb_line_items
    }
  end

  def qb_line_items
    ary = []
    self.line_items.each do |li|
      ary << {sku: li.product.sku, price: li.rate.to_s, q: li.q}
    end
    ary
  end

  def save_to_qb
    Qb.create_po(self.qb)
  end

end
