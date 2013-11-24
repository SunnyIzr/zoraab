require 'spec_helper'

describe Order do
  it {should validate_presence_of (:sub_id)}
  it {should have_and_belong_to_many (:products)}
  it {should belong_to (:sub)}
end
