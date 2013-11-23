class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @sub = Sub.find(params[:sub_id])
  end


end
