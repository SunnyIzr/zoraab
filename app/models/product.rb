class Product < ActiveRecord::Base
  validates_presence_of :sku
end