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

end
