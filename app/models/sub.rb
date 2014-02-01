class Sub < ActiveRecord::Base
  validates_presence_of :cid
  validates_uniqueness_of :cid
  has_and_belongs_to_many :prefs
  has_many :orders

  def chargify
    Chargify::Subscription.find(cid).attributes
  end

  def retrieve_wufoo_prefs
    self.prefs << Wufoo.find_prefs(cid)
  end

  def order_history
    prod_skus = []
    self.orders.each do |order|
      order.products.each do |prod|
        prod_skus << prod.sku
      end
    end
    prod_skus
  end

  def get_prod_data
    products = []
    self.orders.each {|order| products << order.products }
    products.flatten!.uniq!
    product_data = {}
    products.each do |product|
      if product.active == true
        product_data[product.sku] = Shopify.data(product.sku)
      else
        product_data[product.sku] = {small_pic: '/assets/no-prev.jpg'}
      end

    end
    product_data
  end

  def self.pull_subs_due(days)
    ary = []
    all.each do |sub|
      ary << sub if sub.due?(days)
    end
    ary
  end

  def due?(days)
    data = ChargifyResponse.parse(self.chargify)
    return data[:days_till_due]<= days && data[:status] == 'active' && self.not_exist?(data[:next_pmt_date])
  end

  def not_exist?(next_pmt_date)
    self.orders.each do |order|
      if next_pmt_date == order.created_at
        return false
      end
    end
    return true
  end

end
