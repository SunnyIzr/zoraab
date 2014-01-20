class Session < ActiveRecord::Base
  validates_presence_of :session_key
  validates_uniqueness_of :session_key

  serialize :product_ids, Array

end
