class ProductsController < ApplicationController
  def info
    @data = Shopify.data(params['sku'])
    render json: @data
  end

  def shopify_sync
    Product.sync_to_shopify
    redirect_to root_path
  end
end


