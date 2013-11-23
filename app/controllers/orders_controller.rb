class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    p "*"*500
    p params
    @sub = Sub.find(params[:sub_id])
  end


end
