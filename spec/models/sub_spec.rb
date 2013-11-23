require 'spec_helper'

describe Sub do
  it {should validate_presence_of (:cid)}
  it {should have_and_belong_to_many (:prefs)}
  it {should have_many (:orders)}
end