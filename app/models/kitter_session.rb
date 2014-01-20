class KitterSession < ActiveRecord::Base
  serialize :product_ids, Array

end
