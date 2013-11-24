FactoryGirl.define do

  factory :sub do
    cid {2387050}
  end

  factory :order do
    sub_id {1}
  end

  factory :pref do
    pref {'dress'}
  end

end
