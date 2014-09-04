class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    @prods = @order.get_prod_data
    respond_to do |format|
      format.html
      format.csv { send_data @order.to_csv(@prods) }
    end
  end

  def new
    @order = SubOrder.new(trans_id: params['trans_id'],amt: params['amt'])
    @sub = Sub.find(params[:sub_id])
    @response = @sub.chargify
  end

  def create
    @order = SubOrder.new(order_params)
    @order.set_order_details
    @order.save
    if @order.sub.type == 'UpfrontSub'
      @order.type = 'UpfrontSubOrder'
      @order.save
      id = @order.id
      @order = UpfrontSubOrder.find(id)
    end
    @order.set_order_line_items(params[:item])
    if @order.id != nil
      @order.send_to_shopify if params[:commit] == "Save and Update Shopify" || params[:update_shopify] == '1'
      OutstandingSignup.refresh_outstanding_signups
      OutstandingRenewal.refresh_outstanding_renewals
      DataSession.last.remove_order_due(@order)
      redirect_to order_path(@order.id)
    else
      render text: "FAIL!"
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
    @sub = @order.sub
    @order.destroy
    redirect_to sub_path(@sub)
  end

  def send_to_shopify
    @order = SubOrder.find(params[:order_id].to_i)
    if @order.send_to_shopify
      respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.json  { render :json => msg }
      end
    end
  end

  def index
    @orders = SubOrder.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
  end

  def send_to_shipstation
    order = SubOrder.find(params[:order_id])
    ss_order = Shipstation.send_order(order)
    if ss_order.OrderID != nil
      respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.json  { render :json => msg }
      end
      order.ssid = ss_order.OrderID
      order.save
    end
  end
  
  def add_line_item
    render json: {html: render_to_string(partial: "orders/line_item_input", locals: {item: params[:item], sub_id: params[:sub_id]}) }
  end
  
  def shopify_orders
    start_date = Date.strptime(params[:start_date])
    end_date = Date.strptime(params[:end_date]) + 1.day
    shop_orders = ShopifyAPI::Order.find(:all, :params => {'created_at_max' => end_date, 'created_at_min' => start_date,:limit =>250})
    Qb.init
    existing_qbo_orders = Qb.sr.query("select * from SalesReceipt where TxnDate >= '#{start_date.strftime}' AND TxnDate <= '#{end_date.strftime}'", per_page: 1000).entries
    existing_qbo_orders.map! { |qbo| qbo.doc_number }    
    shop_orders = shop_orders.select{ |order| !existing_qbo_orders.include?(order.name) }
    orders = []
    puts "Getting #{shop_orders.size} Shopify Orders"
    shop_orders.each_with_index do |o,i|
      puts "Getting Order #{i+1}/#{shop_orders.size}"
      p o.name
      orders << Shopify.order(o)
      sleep(2)
    end
    hash = {}
    orders.each do |order|
      hash[order[:number]] = order
    end
    render json: hash.to_json
  end

  private
  def order_params
    params.permit(:amt, :sub_id, :order_id, :order_number,:created_at,:batch_id,:trans_id)
  end

  def items_params
    params.permit(:item)
  end


end
