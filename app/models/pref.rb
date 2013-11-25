class Pref < ActiveRecord::Base
validates_presence_of :pref
has_and_belongs_to_many :products

end
