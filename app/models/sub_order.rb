  class SubOrder < Order
  after_save :set_order_number
  belongs_to :sub
  belongs_to :batch
  validates_presence_of :sub_id
  validates_uniqueness_of :trans_id, :allow_nil => true
  before_save :calc_fees, :set_gateway

  def self.pending
    pending_orders = []
    all.each do |sub_order|
      pending_orders << sub_order unless sub_order.trans_id
    end
    pending_orders.sort_by! { |order| order.created_at }
  end

  def pmt_status
    if self.trans_id.nil?
      return 'Pending'
    else
      return "Recvd"
    end
  end

  def set_order_number
    unless self.order_number
      digits = 4 - self.id.to_s.length
      self.order_number = "ZK" + ("0"*digits) + self.id.to_s
      self.save
    end
  end

  def send_to_shopify
    self.products.each do |product|
      Shopify.reduce_shopify_inv(product.sku)
    end
    self.post_to_shopify = true
    self.save
  end

  def set_order_details
    response = ChargifyResponse.parse(self.sub.chargify)

    self.name = response[:name]
    self.email = response[:email]
    self.plan = response[:plan]

    self.address = response[:shipping_address][:address]
    self.address2 = response[:shipping_address][:address2]
    self.city = response[:shipping_address][:city]
    self.state = response[:shipping_address][:state]
    self.zip = response[:shipping_address][:zip]
    self.country = response[:shipping_address][:country]

    self.billing_name = response[:billing_address][:name]
    self.billing_address = response[:billing_address][:address]
    self.billing_address2 = response[:billing_address][:address2]
    self.billing_city = response[:billing_address][:city]
    self.billing_state = response[:billing_address][:state]
    self.billing_zip = response[:billing_address][:zip]
    self.billing_country = response[:billing_address][:country]
  end

  def set_order_line_items(ary_of_skus)
    li = self.line_items.new(q: 1, rate: self.amt)
    li.product = Product.find_or_create_by(sku: self.plan)
    li.save
    ary_of_skus.each do |sku|
      li = self.line_items.new(q: 1, rate: 0.0)
      li.product = Product.find_or_create_by(sku: sku.downcase)
      li.save
    end
  end

  def calc_fees
    if self.amt.nil?
      self.amt = 0.0
      self.save
    end
    if self.amt > 0.0
      fee = ( self.amt * 0.029 ) + 0.3
      self.fees = fee.round(2)
    end
  end

  def set_gateway
    self.gateway = 'braintree'
  end

  def qb_fees
    {'Braintree Fee' => self.fees.to_s}
  end

  def qb_memo
    self.trans_id.to_s
  end

  def qb_gift_card
    nil
  end

  def to_csv(prods)
    CSV.generate() do |csv|
      csv << ['Order #','Order Date','Plan','customer_name','customer_email','shipping_address','shipping_address_2','shipping_city','shipping_state','shipping_zip','shipping_country','SKU']
      prods.each do |prod|
        csv << [self.order_number,self.created_at.strftime('%m/%d/%y'),self.plan,self.name,self.email,self.address,self.address2,self.city,self.state,self.zip,self.country,prod[:sku]]
      end
    end
  end


end
