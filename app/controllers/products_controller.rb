class ProductsController < ApplicationController
  def info
    @data = Shopify.data(params['sku'])
    render json: @data
  end
end


