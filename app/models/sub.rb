class Sub < ActiveRecord::Base
  has_and_belongs_to_many :prefs
  validates_presence_of :cid
end