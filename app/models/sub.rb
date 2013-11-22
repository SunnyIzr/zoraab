class Sub < ActiveRecord::Base
  has_and_belongs_to_many :prefs
  has_and_belongs_to_many :products
  validates_presence_of :cid
end