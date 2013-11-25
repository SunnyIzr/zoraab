class Product < ActiveRecord::Base
  validates_presence_of :sku
  validates_uniqueness_of :sku
  has_and_belongs_to_many :prefs

  def self.update_prods
    Shopify.retrieve_shopify_products.each do |product|
      prod = Product.find_or_create_by(sku: product[:sku])
      prod.q = product[:q]
      prod.save
    end
  end
end
