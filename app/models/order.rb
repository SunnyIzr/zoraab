class Order < ActiveRecord::Base
  after_save :set_order_number
  has_and_belongs_to_many :products
  belongs_to :sub
  belongs_to :batch
  validates_presence_of :sub_id

  def self.pending
    pending_orders = []
    all.each do |order|
      pending_orders << order unless order.trans_id
    end
    pending_orders.sort_by! { |order| order.created_at }
  end

  def set_order_number
    unless self.order_number
      digits = 4 - self.id.to_s.length
      self.order_number = "K" + ("0"*digits) + self.id.to_s
      self.save
    end
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

  def get_prod_data
    self.products.map { |product| Shopify.data(product.sku)}
  end

  def set_order_products(ary_of_skus)
    ary_of_skus.each do |sku|
      self.products << Product.find_or_create_by(sku: sku)
    end
  end

  def to_csv(prods) #untested
    CSV.generate() do |csv|
      csv << ['Order #','Order Date','Plan','customer_name','customer_email','shipping_address','shipping_address_2','shipping_city','shipping_state','shipping_zip','shipping_country','SKU']
      prods.each do |prod|
        csv << [self.order_number,self.created_at.strftime('%m/%d/%y'),self.plan,self.name,self.email,self.address,self.address2,self.city,self.state,self.zip,self.country,prod[:sku]]
      end
    end
  end






end
