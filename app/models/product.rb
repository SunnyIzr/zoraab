class Product < ActiveRecord::Base
  validates_presence_of :sku
  validates_uniqueness_of :sku
end
