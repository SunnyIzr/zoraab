module Shopify
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
end
