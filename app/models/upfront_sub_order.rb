class UpfrontSubOrder < SubOrder
  def upfront_term
    self.sub.term
  end
  def single_installment
    amt/upfront_term
  end
  def residual
    amt - single_installment
  end
  def set_order_line_items(ary_of_skus)
    li = self.line_items.new(q: 1, rate: single_installment)
    li.product = Product.find_or_create_by(sku: self.plan)
    li.save
    li = self.line_items.new(q: 1, rate: residual)
    li.product = Product.find_by(sku: 'Unearned Subscription Sales')
    li.save
    ary_of_skus.each do |sku|
      li = self.line_items.new(q: 1, rate: 0.0)
      li.product = Product.find_or_create_by(sku: sku.downcase)
      li.save
    end
  end
end
