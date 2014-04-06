class LineItem < ActiveRecord::Base
  belongs_to :line_itemable, polymorphic: true
  belongs_to :product
  validates_presence_of :product_id
  validates_presence_of :rate
  validates_presence_of :q
  
  def total
    (self.rate * self.q).round(2)
  end
end
