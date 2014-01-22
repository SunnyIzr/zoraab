class Batch < ActiveRecord::Base
  has_many :orders
  accepts_nested_attributes_for :orders

  def self.destroy_empty_batches
    all.each do |batch|
      batch.destroy if batch.orders.empty?
    end
  end
end
