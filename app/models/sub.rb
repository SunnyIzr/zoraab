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
    products.flatten!.uniq! if !products.empty?
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
    subs = {}
    cdata = retrieve_all_active_subs
    all.each do |sub|
      subs[sub.cid] = cdata[sub.cid] if sub.due?(days,cdata[sub.cid])
    end
    subs
  end

  def self.retrieve_all_active_subs
    i = 0
    current_page = [1]
    subs = {}
    while current_page.count > 0 do
      i +=1
      current_page = Chargify::Subscription.find(:all, params: {per_page: 200, page: i, state: 'active'})
      if current_page.count > 0
        current_page.each do |sub|
          if sub.product.attributes['product_family'].attributes['name'] != 'Shipping for Fab'
            subs[sub.id] = ChargifyResponse.parse(sub.attributes)
          end
        end
      end
    end
    subs
  end

  def due?(days,cdata)
    return false if cdata.nil?
    return cdata[:days_till_due]<= days && cdata[:status] == 'active' && self.not_exist?(cdata[:next_pmt_date])
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
