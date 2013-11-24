require 'spec_helper'

describe Wufoo do
  let (:dress) {FactoryGirl.create(:pref)}
  let (:sub2) {FactoryGirl.create(:sub, {cid: 4194305})}

    it "should find array of preferences from Wufoo" do
      dress
      prefs = Wufoo.find_prefs(sub2.cid)

      expect(prefs).to eq ([dress])
    end

end
