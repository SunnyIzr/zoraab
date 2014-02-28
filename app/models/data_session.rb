class DataSession < ActiveRecord::Base
  serialize :data, Array

end
