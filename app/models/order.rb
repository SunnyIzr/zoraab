class Order < ActiveRecord::Base
  has_many :line_items
  self.inheritance_column = :type


  def products
    self.line_items.map { |li| li.product }
  end

  def get_prod_data
    self.products.map do |product|
      if product.active == true
        Shopify.data(product.sku)
      else
        {sku: product.sku, small_pic: '/assets/no-prev.jpg'}
      end
    end
  end


  def ship_state
    ss_order = Shipstation.get_order(self.ssid)
    if ss_order == nil
      return "Never Sent to Shipstation"
    elsif ss_order.ShipDate == nil
      return 'Unshipped'
    else
      return "Shipped - #{ss_order.ShipDate.strftime('%a %d %b %Y')}"
    end
  end


end
