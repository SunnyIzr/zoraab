class Invoice < ActiveRecord::Base
  has_many :line_items, as: :line_itemable
  after_save :set_po_number

  def set_po_number
    unless self.po_number
      digits = 4 - self.id.to_s.length
      self.po_number = "I" + ("0"*digits) + self.id.to_s
      self.save
    end
  end

end
