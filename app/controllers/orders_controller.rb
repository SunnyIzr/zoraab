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
    @order = Order.new(trans_id: params['trans_id'])
    @sub = Sub.find(params[:sub_id])
    @response = ChargifyResponse.parse(@sub.chargify)
  end

  def create
    if params[:commit] == "Save and Update Shopify"
      params[:item].each do |sku|
        Shopify.reduce_shopify_inv(sku)
      end
    end
    @order = Order.new(order_params)
    @sub = Sub.find(params[:sub_id])
    response = ChargifyResponse.parse(@sub.chargify)
    @order.set_order_details(response)
    params[:item].each do |item|
      @order.products << Product.find_or_create_by(sku: item)
    end
    if @order.save
      redirect_to order_path(@order.id)
    else
      render text: "FAIL!"
    end
  end

  def new_batch
    @subs = []
    @orders = []
    Sub.pull_subs_due(params['days'].to_i).each do |sub|
      @subs << ChargifyResponse.parse(sub.chargify)
      @orders << sub.orders.new
    end
  end

  private
  def order_params
    params.permit(:sub_id, :order_number,:created_at,:batch_id,:trans_id)
  end

  def items_params
    params.permit(:item)
  end


end
