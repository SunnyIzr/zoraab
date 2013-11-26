class SubsController < ApplicationController
  def new
    @sub = Sub.new
  end

  def create
    @sub = Sub.new(sub_params)

    if @sub.save
      redirect_to sub_path(@sub.id)
    else
      render text: "There was an error with your request. Either you did not input a Chargify ID or the subscriber already exists in Coz with that Chargify ID. Please Try Again."
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
    @kitter_suggestions = Kitter.generate_kitter_suggestions(params['sub_id'])
    render json: @kitter_suggestions
  end

  private
  def sub_params
    params.permit(:cid)
  end
end
