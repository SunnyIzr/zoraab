class SubsController < ApplicationController
  skip_before_filter  :verify_authenticity_token, :only => :shopify_data
  before_filter :cors_preflight_check, :only => :shopify_data
  after_filter :cors_set_access_control_headers, :only => :shopify_data
  def new
    @sub = Sub.new
  end

  def create
    @sub = Sub.new(sub_params)
    @sub.get_prefs
    if @sub.save
      redirect_to sub_path(@sub.id)
    else
      render text: "There was an error with your request. Either you did not input a Chargify ID or the subscriber already exists in Coz with that Chargify ID. Please Try Again."
    end
  end

  def create_with_trans
    @sub = Sub.find_or_create_by(cid: params['cid'])
    @sub.type = 'UpfrontSub' if params['upfront'].to_bool
    @sub.save
    @sub.term = UpfrontSub.find(@sub.id).get_term if params['upfront'].to_bool
    @sub.get_prefs if @sub.prefs.empty?
    redirect_to new_sub_order_path(@sub) + '?trans_id=' + params['trans_id'] + '&amp;amt=' + params['amt']
  end

  def show
    @sub = Sub.find(params[:id])
    @response = @sub.chargify
    @order_prod_data = @sub.get_prod_data
  end

  def index
    @subs = Sub.paginate(:page => params[:page], :per_page => 10)
    @responses = @subs.map { |sub| sub.chargify }
  end

  def index_upcoming
    @subs = DataSession.last.data
  end

  def search
  end

  def show_by_cid
    @sub = Sub.find_by(cid: params['cid'])
    if @sub
      redirect_to sub_path(@sub)
    else
      render text: "Does Not Exist!"
    end
  end

  def kitter
    @kitter_suggestions = Kitter.suggest_prod_ids(params['sub_id'])
    ksesh = KitterSession.find_or_create_by(sub_id: params['sub_id'].to_i)
    ksesh.product_ids = @kitter_suggestions
    ksesh.save!
    render json: @kitter_suggestions
  end

  def last_order
    @sub = Sub.find(params[:id])
    @order = @sub.sub_orders.last
    redirect_to order_path(@order.id)
  end

  def next_kitter
    @session = KitterSession.find_by(sub_id: params['sub_id'])
    @product = Product.find(@session.product_ids[params['pos'].to_i])
    render json: @product
  end

  def check_dupe
    @sub = Sub.find(params['sub_id'])
    render json: @sub.dupe?(params['sku'])
  end

  def refresh_subs
    DataSession.refresh
    respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.json  { render :json => msg }
    end
  end
  
  def change_prefs
    @sub = Sub.find(params[:sub_id])
    @sub.set_prefs(params[:prefs])

    redirect_to sub_path(@sub.id)
  end
  
  def shopify_data
    @sub = Sub.find_by(shopify_id: params[:shopify_id])
    data = {sub: @sub, prefs: @sub.prefs, cid: @sub.chargify, orders: @sub.sub_orders}
    render json: data
  end
  
  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    p '~'*100
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  private
  def sub_params
    params.permit(:cid,:trans_id,:upfront,:sku)
  end
end
