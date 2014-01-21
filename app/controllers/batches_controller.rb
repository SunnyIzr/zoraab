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
end
