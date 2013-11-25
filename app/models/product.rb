class Product < ActiveRecord::Base
  validates_presence_of :sku
  validates_uniqueness_of :sku
  has_and_belongs_to_many :prefs

  def self.update_prods
    sample = [{sku: 'rp_wlk05', q: 100, prefs: ['Fashion Socks','Dress Socks']}]
    sample.each do |product|
      prod = Product.find_or_create_by(sku: product[:sku])
      prod.q = product[:q]
      product[:prefs].each do |pref|
        pref_parsed = pref.split(' ').first.downcase
        prod.prefs << Pref.find_by(pref: pref_parsed)
      end
      prod.save
    end
  end
end
