class Product < ActiveRecord::Base
  validates_presence_of :sku
  validates_uniqueness_of :sku
  has_and_belongs_to_many :prefs

  def self.update_prods
    sample = [{sku: 'rp_wlk05', q: 100, prefs: ['fun','dress']}]
    sample.each do |shopify_product|
      prod = Product.find_or_create_by(sku: shopify_product[:sku])
      prod.q = shopify_product[:q]
      update_prefs(shopify_product,prod)
      prod.save
    end
  end

  def self.update_prefs(shopify_product, coz_product)
    shopify_product[:prefs].each do |pref|
      coz_product.prefs << Pref.find_by(pref: pref) if pref_unique?(pref,coz_product)
    end
  end

  def self.pref_unique?(pref,product)
    total_prefs = product.prefs.map { |pref| pref.pref }
    !total_prefs.include?(pref)
  end
end
