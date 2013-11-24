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
    p "hello world"
    p "*"*1000
    p WUFOO
    # self.prefs << Wufoo.find_prefs(cid)
  end
end
