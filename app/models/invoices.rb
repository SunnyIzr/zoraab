class Invoice < ActiveRecord::Base
  has_many :line_items, as: :line_itemable
end
