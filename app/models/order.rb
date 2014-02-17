class Order < ActiveRecord::Base
  has_many :line_items
  self.inheritance_column = :type






end
