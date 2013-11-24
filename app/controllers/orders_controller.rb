class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @sub = Sub.find(params[:sub_id])
    @chargify_data = Chargify::Subscription.find(@sub.cid).attributes
    @customer = @chargify_data["customer"].attributes
    @product = @chargify_data["product"].attributes
    @billing = @chargify_data["credit_card"].attributes
  end

  def create
    @order = Order.new(order_params)
    @order.products << Product.find_by(sku:'test')
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
    params.permit(:item1)
  end


end
