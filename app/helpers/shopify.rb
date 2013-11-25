module Shopify
  BRANDS = [  "Foot Traffic",
              "Hot Sox",
              "Happy Socks",
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
      price: res['price'],
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
      prefs << tag if ['Fashion Socks', 'Dress Socks', 'Fun Socks', 'Casual Socks'].include?tag
    end
    prefs
  end

end
