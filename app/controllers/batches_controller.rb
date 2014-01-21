class BatchesController < ApplicationController
  def show
    @batch = Batch.find(params[:id])
    @prods = []
    @batch.orders.each do |order|
      @prods << order.products
    end
    @prods.flatten!.uniq!
    @product_data = {}
    @prods.each do |product|
      @product_data[product.sku] = Shopify.data(product.sku)
    end
  end

  def new
    @batch = Batch.new
    @subs = []
    @orders = []
    Sub.pull_subs_due(params['days'].to_i).each do |sub|
      @subs << ChargifyResponse.parse(sub.chargify)
      @orders << sub.orders.new
    end
    p @subs
  end

  def create

  end

end
