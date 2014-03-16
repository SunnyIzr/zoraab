class DataSession < ActiveRecord::Base
  serialize :data, Array

  def self.refresh
    DataSession.destroy_all
    DataSession.create(data: Sub.due)
  end

  def remove_order_due(order)
    item = self.data.select { |e| e[0] == order.sub.id }
    data = self.data
    new_data = data - item
    self.data = new_data
    self.save
  end
end
