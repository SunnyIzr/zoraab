module Amazon
  extend self

  def get_orders(days_back)
    $mws.orders.list_orders(:last_updated_after => Time.now-days_back.days)
  end

  def save_order(order)
    ao = AmznOrder.new
    ao.order_number = order.amazon_order_id
    ao.created_at = order.last_update_date
    ao.name = order.buyer_name
    ao.email = order.buyer_email
    ao.address = order.shipping_address.address_line1
    ao.address2 = nil
    ao.city = order.shipping_address.city
    ao.state = order.shipping_address.state_or_region
    ao.zip = order.shipping_address.postal_code
    ao.country = order.shipping_address.country_code
    ao.billing_name = order.buyer_name
    ao.billing_address = order.shipping_address.address_line1
    ao.billing_address2 = nil
    ao.billing_city = order.shipping_address.city
    ao.billing_state = order.shipping_address.state_or_region
    ao.billing_zip = order.shipping_address.postal_code
    ao.billing_country = order.shipping_address.country_code
    ao.amt = order.order_total.amount.to_f
    ao.save
  end

end
