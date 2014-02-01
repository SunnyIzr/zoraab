require 'spec_helper'

describe Pref do
  it { should validate_presence_of(:pref)}
  it {should have_and_belong_to_many (:products)}
end
