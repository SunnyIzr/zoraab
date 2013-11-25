class Product < ActiveRecord::Base
  validates_presence_of :sku
  validates_uniqueness_of :sku
  has_and_belongs_to_many :prefs
end
