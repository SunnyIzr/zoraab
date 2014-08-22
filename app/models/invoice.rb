class Invoice < ActiveRecord::Base
  has_many :line_items, as: :line_itemable
  after_save :set_po_number
  accepts_nested_attributes_for :line_items, allow_destroy: true


  def set_po_number
    unless self.po_number
      digits = 4 - self.id.to_s.length
      self.po_number = "I" + ("0"*digits) + self.id.to_s
      self.save
    end
  end

  def set_line_items(skus,rates,qs)
    skus.each_with_index do |sku,i|
      rate = rates[i].to_f
      q = qs[i].to_f
      prod = Product.find_or_create_by(sku: sku.downcase)
      line_item = self.line_items.new(q: q, rate: rate)
      line_item.product = prod
      line_item.save
    end
    self.calc_total
    self.save
  end

  def calc_total
    self.total = (self.line_items.map { |li| li.q*li.rate }.inject(:+)).round(2)
  end
  
  def total_q
    self.line_items.pluck(:q).sum
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
      ary << {sku: li.product.sku, price: li.rate.to_s, q: li.q.to_s}
    end
    ary
  end

  def save_to_qb
    Qb.create_po(self.qb)
  end
  
  def sent_to_qb?
    Qb.po_exist?(self.po_number)
  end
  
  def items_not_in_qb
    ids = self.line_items.pluck(:product_id)
    products = ids.select { |id| !Product.find(id).exists_in_qb? }
    products.map { |id| Product.find(id).sku }
  end
  
  def create_items_in_qb_for_missing_skus
    missing = self.items_not_in_qb
    missing.each do |sku|
      Qb.create_product(sku)
    end
  end
  
  def allocate_shipping
    cost_per_unit = self.shipping / self.total_q
    self.line_items.each do |line_item|
      line_item.rate += cost_per_unit
    end
    self.shipping = 0
    self.calc_total
    self.save
  end
  
  def allocate_discount
    discount_per_unit = self.discount / self.total_q
    self.line_items.each do |line_item|
      line_item.rate -= discount_per_unit
    end
    self.discount = 0
    self.calc_total
    self.save
  end

end
