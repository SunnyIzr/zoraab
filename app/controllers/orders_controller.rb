class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    @prods = @order.products.map { |product| Shopify.data(product.sku)}
    respond_to do |format|
      format.html
      format.csv { send_data @order.to_csv(@prods) }
    end
  end

  def new
    @order = Order.new
    @sub = Sub.find(params[:sub_id])
    @response = ChargifyResponse.parse(@sub.chargify)
  end

  def create
    @order = Order.new(order_params)
    @sub = Sub.find(params[:sub_id])
    response = ChargifyResponse.parse(@sub.chargify)
    @order.set_order_details(response)
    params[:item].each do |item|
      p item
      @order.products << Product.find_by(sku: item)
    end
    if @order.save
      redirect_to order_path(@order.id)
    else
      render text: "FAIL!"
    end
  end

  private
  def order_params
    params.permit(:sub_id, :order_number)
  end

  def items_params
    params.permit(:item)
  end


end
