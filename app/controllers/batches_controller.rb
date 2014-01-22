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
    respond_to do |format|
      format.html
      format.csv { send_data @batch.to_csv }
    end
  end

  def index
    @batches = Batch.all
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
  end

  def create

  end

end
