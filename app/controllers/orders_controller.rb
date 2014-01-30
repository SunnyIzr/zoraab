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
    update_shopify if params[:commit] == "Save and Update Shopify" || params[:update_shopify] == '1'
    @order = Order.new(order_params)
    @sub = Sub.find(params[:sub_id])
    response = ChargifyResponse.parse(@sub.chargify)
    @order.set_order_details(response)
    params[:item].each do |item|
      @order.products << Product.find_or_create_by(sku: item)
    end
    if @order.save
      OutstandingSignup.refresh_outstanding_signups
      OutstandingRenewal.refresh_outstanding_renewals
      redirect_to order_path(@order.id)
    else
      render text: "FAIL!"
    end
  end

  def update_shopify
    params[:item].each do |sku|
      Shopify.reduce_shopify_inv(sku)
    end
  end

  def send_to_shipstation
    order = Order.find(params[:order_id])
    ss_order = Shipstation.send_order(order)
    if ss_order.OrderID != nil
      respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.json  { render :json => msg }
      end
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
    params.permit(:sub_id, :order_id, :order_number,:created_at,:batch_id,:trans_id)
  end

  def items_params
    params.permit(:item)
  end


end
