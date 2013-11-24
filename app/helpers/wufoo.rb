# The Wufoo Module is responsible for retreiving subscriber preferences
# - Input: Chargify Subscription ID
# - Output: Array of Preferences Objects

module Wufoo
  extend self
  def find_prefs(cid)
    prefs = []
    entry = find_quiz_entry(cid)
    prefs << 'dress' if !entry["Field528"].empty?
    prefs << 'fun' if !entry["Field529"].empty?
    prefs << "fashion" if !entry["Field530"].empty?
    prefs << "casual" if !entry["Field531"].empty?

    prefs.map { |pref| Pref.find_by(pref: pref) }
    prefs
  end

  def find_quiz_entry(cid)
    all_forms.each do |form_id|
      entry = wufoo.form(form_id).entries(:sort => 'EntryId DESC', :limit => 100, :system => true, :filters => [['TransactionId','Is_equal_to',cid]] )
      return entry[0] unless entry.empty?
    end
  end

  def all_forms
    all_forms=[]
    wufoo.forms.each { |form| all_forms << form.details["Hash"]}
    all_forms
  end
  def wufoo
    WuParty.new(ENV['WUF_ACCOUNT'],ENV['WUF_API_KEY'])
  end
end
