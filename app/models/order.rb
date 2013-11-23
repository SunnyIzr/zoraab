class Order < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :sub
  validates_presence_of :order_number
  validates_presence_of :sub_id

end
