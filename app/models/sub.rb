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
    p ">"*100
    p WUFOO
    all_forms=[]
    WUFOO.forms.each { |form| all_forms << form.details["Hash"]}
    all_forms.each do |form_id|
      entry = WUFOO.form(form_id).entries(:sort => 'EntryId DESC', :limit => 100, :system => true, :filters => [['TransactionId','Is_equal_to',cid]] )
      p entry[0] unless entry.empty?
    end
    # self.prefs << Wufoo.find_prefs(cid)
  end
end
