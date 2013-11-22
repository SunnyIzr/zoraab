require 'spec_helper' 

describe Product do
  it { should validate_presence_of (:sku)}
end