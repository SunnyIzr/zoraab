class UpfrontSubOrder < SubOrder
  def upfront_term
    self.sub.term
  end
  def single_installment
    if amt > 0.0
      amt/upfront_term
    else
      self.sub.sub_orders.first.amt/upfront_term
    end
  end
  def residual
    amt - single_installment
  end
  def set_order_line_items(ary_of_skus)
    li = self.line_items.new(q: 1, rate: single_installment)
    li.product = Product.find_or_create_by(sku: self.plan)
    li.save
    create_unearned_revenue_line
    ary_of_skus.each do |sku|
      li = self.line_items.new(q: 1, rate: 0.0)
      li.product = Product.find_or_create_by(sku: sku.downcase)
      li.save
    end
  end

  def create_unearned_revenue_line
    if amt > 0.0
      li = self.line_items.new(q: 1, rate: residual)
      li.product = Product.find_by(sku: 'Unearned Subscription Sales')
      li.save
    else
      li = self.line_items.new(q: 1, rate: -single_installment)
      li.product = Product.find_by(sku: 'Unearned Subscription Sales')
      li.save
    end
  end

  def braintree_id
    'Recurring Upfront Order'
  end
end
