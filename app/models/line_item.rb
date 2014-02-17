class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  validates_presence_of :order_id
  validates_presence_of :product_id
  validates_presence_of :rate
  validates_presence_of :q
end
