class Batch < ActiveRecord::Base
  has_many :sub_orders

  def self.destroy_empty_batches
    all.each do |batch|
      batch.destroy if batch.sub_orders.empty?
    end
  end

  def setup_new(ary_of_subs)
    subs = []
    orders = []
    ary_of_subs.each do |sub_id|
      sub = Sub.find(sub_id.to_i)
      subs << DataSession.last.data.select { |sub| sub[0] == sub_id.to_i}.first[1]
      orders << sub.sub_orders.new
    end
    {subs: subs, orders: orders}
  end

  def get_prod_data
    products = []
    self.sub_orders.each {|sub_order| products << sub_order.products }
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
      self.sub_orders.each do |order|
        order.products.each do |prod|
          csv << [order.order_number,order.created_at.strftime('%m/%d/%y'),order.plan,order.name,order.email,order.address,order.address2,order.city,order.state,order.zip,order.country,prod[:sku]]
        end
      end
    end
  end
end
