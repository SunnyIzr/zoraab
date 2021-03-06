class Order < ActiveRecord::Base
  has_many :line_items, as: :line_itemable
  validates_uniqueness_of :order_number
  self.inheritance_column = :type

  def products
    products = []
    self.line_items.each do |li|
      unless li.product.sku.include?('Sock ') || li.product.sku.include?('Unearned Subscription Sales')
        products << li.product
      end
    end
    products
  end

  def sent_to_shopify?
    if self.post_to_shopify == true
      'Sent'
    else
      'Unsent'
    end
  end

  def get_prod_data
    self.products.map do |product|
      if product.active == true
        Shopify.data(product.sku)
      else
        {sku: product.sku, small_pic: '/assets/no-prev.jpg'}
      end
    end
  end

  def ship_state
    ss_order = Shipstation.get_order(self.ssid)
    if ss_order == nil
      return "Never Sent to Shipstation"
    elsif ss_order.ShipDate == nil
      return 'Unshipped'
    else
      return "Shipped - #{ss_order.ShipDate.strftime('%a %d %b %Y')}"
    end
  end

  def qb
      {
      type: self.qb_type,
      number: self.order_number,
      created_at: self.created_at,
      email: self.email,
      gateway: self.gateway,
      shipping_total: self.shipping_charge.to_s,
      gift_card_redemption: self.qb_gift_card,
      total: self.amt.to_s,
      fees: self.qb_fees,
      discount: self.discount.to_s,
      memo: self.qb_memo,
      billing_address: {
        name: self.billing_name,
        address1: self.billing_address,
        city: self.billing_city,
        state: self.billing_state,
        zip: self.billing_zip,
        country: self.billing_country
      },
      shipping_address: {
        name: self.name,
        address1: self.address,
        city: self.city,
        state: self.state,
        zip: self.zip,
        country: self.country
      },
      line_items: self.qb_line_items
    }
  end

  def qb_line_items
    ary = []
    self.line_items.each { |li| ary << { sku: li.product.sku, price: li.rate.to_s, q: li.q } }
    ary
  end

  def qb_type
    qb_types = {'SubOrder' => 'Subscription', 'ShopifyOrder' => 'Shopify', 'AmznOrder' => 'Amazon'}
    qb_types[self.type]
  end

  def net_amt
    return (self.amt - self.fees)
  end

  def set_order_line_items(ary_of_hashes)
    ary_of_hashes.each do |hash|
      li = self.line_items.new
      li.q = hash[:q]
      li.rate = hash[:rate]
      li.product = Product.find_or_create_by(sku: hash[:sku])
      li.save
    end
  end

  def save_to_qb
    Qb.create_order(self.qb)
  end


end
