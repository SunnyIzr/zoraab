require 'spec_helper'

describe Product do
  it { should validate_presence_of (:sku)}
  it { should validate_uniqueness_of (:cid)}
end
