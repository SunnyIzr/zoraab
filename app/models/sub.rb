class Sub < ActiveRecord::Base
  validates_presence_of :cid
  validates_uniqueness_of :cid
  has_and_belongs_to_many :prefs
  has_many :sub_orders

  def chargify
    Chargify::Subscription.find(cid).attributes
  end

  def retrieve_wufoo_prefs
    self.prefs << Wufoo.find_prefs(cid)
  end

  def list_prefs
    str = ''
    self.prefs.each do |p|
      case p.pref
      when 'dress'
        str += 'B'
      when 'fashion'
        str += 'F'
      when 'fun'
        str += 'W'
      when 'casual'
        str += 'C'
      end
    end
    str
  end

  def order_history
    prod_skus = []
    self.sub_orders.each do |sub_order|
      sub_order.products.each do |prod|
        prod_skus << prod.sku
      end
    end
    prod_skus
  end

  def get_prod_data
    products = []
    self.sub_orders.each {|sub_order| products << sub_order.products }
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

  # def self.pull_subs_due
  #   subs = []
  #   cdata = retrieve_all_active_subs
  #   cdata.each do |cid,value|

  #     subs <<  if sub.due?(days,cdata[sub.cid])
  #   end
  #   subs
  # end

  def self.active
    i = 1
    subs = {}
    while true
      current_page = Chargify::Subscription.find(:all, params: {per_page: 200, page: i, state: 'active'})
      break if current_page.count == 0
      current_page.each do |sub_response|
        sub = Sub.find_by(cid: sub_response.id)
        if sub
          subs[sub.id] = ChargifyResponse.parse(sub_response.attributes)
        end
      end
      i +=1
    end
    subs.sort_by { |sub| sub[1][:next_pmt_date]}
  end

  def self.os_renewals
    subs = {}
    OutstandingRenewal.all.each do |oren|
      sub = Sub.find_by(cid: oren.cid)
      subs[sub.id] = ChargifyResponse.parse(sub.chargify)
      subs[sub.id][:next_pmt_date] = oren.created_at
    end
    subs.sort_by { |sub| sub[1][:next_pmt_date]}
  end

  def self.due
    subs = os_renewals
    active.each {|sub| subs<<sub}
    subs
  end

  def due?(days,cdata)
    return false if cdata.nil?
    return cdata[:days_till_due]<= days && cdata[:status] == 'active' && self.not_exist?(cdata[:next_pmt_date])
  end

  def not_exist?(next_pmt_date)
    self.sub_orders.each do |sub_order|
      if next_pmt_date == sub_order.created_at
        return false
      end
    end
    return true
  end

end
