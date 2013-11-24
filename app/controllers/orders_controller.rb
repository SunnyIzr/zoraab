class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    @sub = Sub.find(@order.sub_id)
    @chargify_data = Chargify::Subscription.find(@sub.cid).attributes
    @customer = @chargify_data["customer"].attributes
    @product = @chargify_data["product"].attributes
    @billing = @chargify_data["credit_card"].attributes
  end

  def new
    @order = Order.new
    @sub = Sub.find(params[:sub_id])
    @chargify_data = Chargify::Subscription.find(@sub.cid).attributes
    @customer = @chargify_data["customer"].attributes
    @product = @chargify_data["product"].attributes
    @billing = @chargify_data["credit_card"].attributes
    @number_of_socks = @product['handle'][0].to_i
  end

  def create
    @order = Order.new(order_params)
    @sub = Sub.find(params[:sub_id])
    @chargify_data = Chargify::Subscription.find(@sub.cid).attributes
    @customer = @chargify_data["customer"].attributes
    @product = @chargify_data["product"].attributes
    @billing = @chargify_data["credit_card"].attributes
    @order.name = @customer['first_name'] + ' ' + @customer['last_name']
    @order.email = @customer['email']
    @order.address = @customer['address']
    @order.address2 = @customer['address2']
    @order.city = @customer['city']
    @order.state = @customer['state']
    @order.zip = @customer['zip']
    @order.country = @customer['country']
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
