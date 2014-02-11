module Shopify
  BRANDS = [  "Foot Traffic",
              "Hot Sox",
              "Happy Socks",
              "Mint Socks",
              "Pact",
              "Perry Ellis",
              "Richer Poorer",
              "Sock it to Me",
              "Solmate",
              "Unsimply Stitched"]
  PRICE_MAX = 12

  extend self

  def data(sku)
    hash = {}
    res = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first.attributes
    {
      sku: sku,
      title: res['title'],
      price: res['variants'][0].attributes['price'].to_f,
      q: res['variants'][0].attributes['inventory_quantity'],
      vendor: res['vendor'],
      tags: res['tags'],
      pic: res['image'].attributes['src'],
      small_pic: res['image'].attributes['src'].gsub(/(.jpeg)/,'_small.jpeg'),
      publish_date: res['published_at']
    }
  end

  def reduce_shopify_inv(sku)
    res = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first
    res.attributes['variants'][0].attributes['inventory_quantity'] -= 1
    res.save
  end

  def retrieve_shopify_products
    products = []
    BRANDS.each do |brand|
      ven_prods = ShopifyAPI::Product.find(:all, :params => {"vendor"=>brand, :limit =>200})
      ven_prods.each do |prod|
        if published?(prod) && not_sale?(prod)
          products << { sku: handle_sku(prod) , q: q(prod), prefs: prefs(prod)}
        end
      end
    end
    products
  end

  def published?(prod)
    !!prod.attributes['published_at']
  end

  def not_sale?(prod)
    !prod.attributes['tags'].include?('Sale')
  end

  def handle_sku(prod)
    prod.attributes['handle']
  end

  def q(prod)
    prod.attributes['variants'].first.attributes['inventory_quantity']
  end

  def prefs(prod)
    prefs = []
    prod.attributes['tags'].split(', ').each do |tag|
      prefs << parse_pref(tag) if ['Fashion Socks', 'Dress Socks', 'Fun Socks', 'Casual Socks'].include?tag
    end
    prefs
  end

  def parse_pref(shopify_pref)
    shopify_pref.split(' ').first.downcase
  end

  def order(order)
    {
      number: order.name,
      created_at: order.created_at,
      email: order.email,
      gateway: order.gateway,
      total: order.total_price,
      discount: order.total_discounts,
      billing_address: {
        name: order.billing_address.first_name + ' ' + order.billing_address.last_name,
        address1: order.billing_address.address1,
        city: order.billing_address.city,
        state: order.billing_address.province_code,
        zip: order.billing_address.zip,
        country: order.billing_address.country_code
      },
      shipping_address: {
        name: order.shipping_address.first_name + ' ' + order.shipping_address.last_name,
        address1: order.shipping_address.address1,
        city: order.shipping_address.city,
        state: order.shipping_address.province_code,
        zip: order.shipping_address.zip,
        country: order.shipping_address.country_code
      },
      line_items: order.line_items.map {|item| {
        sku: item.sku,
        price: item.price,
        q: item.quantity } }
    }
  end

  def get_single_day(date)
    ShopifyAPI::Order.find(:all, :params => {'created_at_max' => date+1.day, 'created_at_min' => date})
  end

end
