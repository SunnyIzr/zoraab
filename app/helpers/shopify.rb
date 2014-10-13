module Shopify
  BRANDS = [  "Ashi Dashi",
              "Foot Traffic",
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
      if ven_prods.size == 200
        ary = ven_prods.map{|e| e}
        addl_prods = ShopifyAPI::Product.find(:all, :params => {"vendor"=>brand, :limit =>200,:page => 2})
        ary << addl_prods
        ven_prods = ary.flatten
      end
      ven_prods.each do |prod|
        if published?(prod) && not_sale?(prod)
          products << { sku: handle_sku(prod) , q: q(prod), prefs: prefs(prod)}
        end
      end
    end
    products
  end
  
  def all_products
    skus = []
    collection_size = 1
    page = 0
    while collection_size > 0
      page += 1
      collection = ShopifyAPI::Product.find(:all, :params => {:limit =>250, :page=> page})
      collection_size = collection.size
      skus << collection.map{ |product| product.variants.first.sku.downcase }
    end
    skus.flatten
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
      type: 'Shopify',
      number: order.name,
      created_at: order.created_at,
      email: order.email,
      gateway: order.gateway,
      total: order.total_price,
      discount: order.total_discounts,
      memo: '',
      shipping_total: shipping_total(order),
      billing_address: billing_address(order),
      shipping_address: shipping_address(order),
      gift_card_redemption: gift_card_redemption(order),
      fees: calc_fees(order),
      line_items: order.line_items.map {|item| {
        sku: check_for_missing(item),
        price: item.price,
        q: item.quantity } }
    }
  end
  
  def check_for_missing(item)
    missing = {'US_UNST12-002-2' => 'us_12-002-2', 'hs_bd01-68' => 'hs_bd01-068'}
    if missing.keys.include?(item.sku)
      missing[item.sku]
    else
      # ShopifyAPI::Product.find(item.product_id).handle
      item.sku
    end
  end
  
  def billing_address(order)
    {
        name: order.billing_address.first_name.to_s + ' ' + order.billing_address.last_name.to_s,
        address1: order.billing_address.address1,
        city: order.billing_address.city,
        state: order.billing_address.province_code,
        zip: order.billing_address.zip,
        country: order.billing_address.country_code
      }
  end

  def shipping_address(order)
    if requires_shipping(order)
      {
          name: order.shipping_address.first_name.to_s + ' ' + order.shipping_address.last_name.to_s,
          address1: order.shipping_address.address1,
          city: order.shipping_address.city,
          state: order.shipping_address.province_code,
          zip: order.shipping_address.zip,
          country: order.shipping_address.country_code
        }
      else
        billing_address(order)
    end
  end

  def requires_shipping(order)
    line_items = order.line_items.map {|li| li.requires_shipping}
    line_items.include?(true)
  end

  def shipping_total(order)
    if order.shipping_lines.empty?
      return '0.0'
    else
      return order.shipping_lines.first.price
    end

  end

  def gift_card_redemption(order)
    gift_card_trans = order.transactions.select { |t| t.gateway == 'gift_card' }
    if gift_card_trans.empty?
      return nil
    else
      amt = 0.0
      gift_card_trans.each { |trans| amt += trans.amount.to_f }
      return amt
    end
  end

  def calc_fees(order)
    if gift_card_redemption(order).nil?
      gift_card_redemption = 0.0
    else
      gift_card_redemption = gift_card_redemption(order)
    end
    pmt_amt = ((order.total_price.to_f) - gift_card_redemption)
    if order.gateway == 'paypal'
      if order.billing_address.country_code == 'US'
        fee =  ( pmt_amt * 0.029 ) + 0.3
        return {'Paypal Fee' => fee.round(2).to_s}
      else
        fee =  ( pmt_amt * 0.039 ) + 0.3
        return {'Paypal Fee' => fee.round(2).to_s}
      end
    elsif order.gateway == 'shopify_payments'
      fee = (pmt_amt * 0.0225).round(3) + 0.3
      return {'Shopify Payments Fee' => fee.round(2).to_s}
    else
      return {'Shopify Payments Fee' => '0.0' }
    end

  end

  def get_order(order_number)
    order(ShopifyAPI::Order.find(:all, :params => {'name' => order_number}).first)
  end

  def get_single_day(date)
    orders = []
    ShopifyAPI::Order.find(:all, :params => {'created_at_max' => date+1.day, 'created_at_min' => date}).each do |o|
      orders << order(o)
    end
    orders.reverse!
  end

  def get_range(start_date,end_date)
    orders = []
    shopify_orders = ShopifyAPI::Order.find(:all, :params => {'created_at_max' => end_date, 'created_at_min' => start_date,:limit =>250})
    shopify_transactions = ShopifyAPI::Transaction.find(:all, :params => {'created_at_max' => end_date, 'created_at_min' => start_date,:limit =>250})
    puts "Getting #{shopify_orders.size} Shopify Orders"
    shopify_orders.each_with_index do |o,i|
      puts "Getting Order #{i}/#{shopify_orders.size}"
      orders << order(o)
    end
    orders.reverse!
  end

  def remove_zero_orders(orders)
    orders.select {|o| o if o[:total].to_f > 0.0}
  end
  
  def nil_product_id?(order)
    order.line_items.map { |li| li.product_id }.include?(nil)
  end
  
  def create_customer(customer_info)
    customer = ShopifyAPI::Customer.new
    customer.attributes = customer_info
    customer.save
    customer.id
  end
  
  def blogs
    blogs = ShopifyAPI::Page.all.select{|page| page.template_suffix == 'blog-entry' || page.template_suffix == 'blog-featured'}.sort_by{|page| page.created_at }.reverse
    parsed_blogs = []
    blogs.each do |blog|
      hash = {}
      hash[:title] = blog.title
      hash[:img_link] = Nokogiri::HTML(blog.body_html).css('.blog-preview')[0].attributes['src'].value
      hash[:main_img_link] = Nokogiri::HTML(blog.body_html).css('.blog-hero')[0].attributes['src'].value
      hash[:subtext] = Nokogiri::HTML(blog.body_html).css('.featured-subtext')[0].text unless Nokogiri::HTML(blog.body_html).css('.featured-subtext').empty?
      hash[:link] = "/pages/#{blog.handle}"
      parsed_blogs << hash
    end
    featured = parsed_blogs.select{|blog| !blog[:subtext].nil?}[0]
    parsed_blogs -= [featured]
    {featured: featured, blogs: parsed_blogs}
  end

end
