class Order < ActiveRecord::Base
  after_save :set_order_number
  has_and_belongs_to_many :products
  belongs_to :sub
  validates_presence_of :sub_id

  def set_order_number
    unless self.order_number
      digits = 4 - self.id.to_s.length
      self.order_number = "K" + ("0"*digits) + self.id.to_s
      self.save
    end
  end
end
