FactoryGirl.define do

  factory :sub do
    cid {4258861}
  end

  factory :sub_order do
    sub_id {1}
  end

  factory :pref do
    pref {'dress'}
  end

  factory :product do
    sku {'sku'}
  end

  factory :outstanding_signup do
    trans_id {123345}
  end

  factory :outstanding_renewal do
    trans_id {123345}
  end

  factory :batch do
  end

end
