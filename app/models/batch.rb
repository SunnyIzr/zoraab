class Batch < ActiveRecord::Base
  has_many :orders
  accepts_nested_attributes_for :orders

  def self.destroy_empty_batches
    all.each do |batch|
      batch.destroy if batch.orders.empty?
    end
  end

  def to_csv
    CSV.generate() do |csv|
      csv << ['Order #','Order Date','Plan','customer_name','customer_email','shipping_address','shipping_address_2','shipping_city','shipping_state','shipping_zip','shipping_country','SKU']
      self.orders.each do |order|
        order.products.each do |prod|
          csv << [order.order_number,order.created_at.strftime('%m/%d/%y'),order.plan,order.name,order.email,order.address,order.address2,order.city,order.state,order.zip,order.country,prod[:sku]]
        end
      end
    end
  end
end
