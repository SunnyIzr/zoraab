require 'spec_helper'

describe Order do
  it {should validate_presence_of (:order_number)}
  it {should have_and_belong_to_many (:products)}
end