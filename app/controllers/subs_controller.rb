class SubsController < ApplicationController
  def new
    @sub = Sub.new
  end

  def create
    @sub = Sub.new(sub_params)
    @sub.retrieve_wufoo_prefs
    if @sub.save
      redirect_to sub_path(@sub.id)
    else
      render text: "There was an error with your request. Either you did not input a Chargify ID or the subscriber already exists in Coz with that Chargify ID. Please Try Again."
    end
  end

  def create_with_trans
    @sub = Sub.find_by(cid: params['cid'])
    if @sub == nil
      @sub = Sub.new(cid: params['cid'])
      @sub.retrieve_wufoo_prefs
      if @sub.save
        redirect_to new_sub_order_path(@sub) + '?trans_id=' + params['trans_id']
      else
        render text: "There was an error with your request. Either you did not input a Chargify ID or the subscriber already exists in Coz with that Chargify ID. Please Try Again."
      end
    else
      redirect_to new_sub_order_path(@sub) + '?trans_id=' + params['trans_id']
    end

  end

  def show
    @sub = Sub.find(params[:id])
    @response = ChargifyResponse.parse(@sub.chargify)
  end

  def index
    @subs = Sub.all
    @responses = @subs.map { |sub| ChargifyResponse.parse(sub.chargify) }
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
    @order = @sub.orders.last
    redirect_to order_path(@order.id)
  end

  def next_kitter
    @session = KitterSession.find_by(sub_id: params['sub_id'])
    @product = Product.find(@session.product_ids[params['pos'].to_i])
    render json: @product
  end

  private
  def sub_params
    params.permit(:cid,:trans_id)
  end
end
