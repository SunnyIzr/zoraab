class Batch < ActiveRecord::Base
  has_many :orders

  def self.destroy_empty_batches
    all.each do |batch|
      batch.destroy if batch.orders.empty?
    end
  end

  def setup_new(days)
    subs = []
    orders = []
    Sub.pull_subs_due(days).each do |sub|
      subs << ChargifyResponse.parse(sub.chargify)
      orders << sub.orders.new
    end
    {subs: subs, orders: orders}
  end

  def get_prod_data
    products = []
    self.orders.each {|order| products << order.products }
    products.flatten!.uniq!
    product_data = {}
    products.each do |product|
      if product.active == true
        product_data[product.sku] = Shopify.data(product.sku)
      else
        product_data[product.sku] = {small_pic: '/assets/no-prev.jpg'}
      end
    end
    product_data
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
