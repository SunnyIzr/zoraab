class Sub < ActiveRecord::Base
  before_save :retrieve_wufoo_prefs
  has_and_belongs_to_many :prefs
  has_many :orders
  validates_presence_of :cid

  def chargify
    Chargify::Subscription.find(cid).attributes
  end

  def retrieve_wufoo_prefs
    self.prefs << Wufoo.find_prefs(cid)
  end
end
