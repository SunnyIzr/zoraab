module ZoraabUsers
  extend self
  def data(entry_id)
    url = 'http://zoraab-users.herokuapp.com/entries/'+entry_id.to_s+'.json'
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    data = JSON.parse(res.body)
  end
  
  def get_prefs(entry_id)
    data = data(entry_id)
    prefs = data['prefs']
    prefs.map! { |pref| Pref.find_by(pref: pref) }
    prefs
  end
end
