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
    Batch.destroy_empty_batches
    @batch = Batch.create
    @subs = []
    @orders = []
    Sub.pull_subs_due(params['days'].to_i).each do |sub|
      @subs << ChargifyResponse.parse(sub.chargify)
      @orders << sub.orders.new
    end
    p "~"*1000
    p @batch
  end

  def create

  end

end
