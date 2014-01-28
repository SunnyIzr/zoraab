class Sub < ActiveRecord::Base
  validates_presence_of :cid
  validates_uniqueness_of :cid
  before_save :retrieve_wufoo_prefs
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

  def self.pull_subs_due(days)
    ary = []
    all.each do |sub|
      # data = ChargifyResponse.parse(sub.chargify)
      # ary << sub if data[:days_till_due]<= days && data[:status] == 'active'
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
