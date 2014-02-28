class DataSession < ActiveRecord::Base
  serialize :data, Hash

end
