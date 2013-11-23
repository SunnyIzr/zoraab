class SubsController < ApplicationController
  def new
    @sub = Sub.new
  end

  def create
    @sub = Sub.new(sub_params)

    if @sub.save
      redirect_to sub_path(@sub.id)
    else
      render text: "Need Chargify ID"
    end
  end

  def show
    @sub = Sub.find(params[:id])
    @chargify_data = Chargify::Subscription.find(@sub.cid).attributes
    @customer = @chargify_data["customer"].attributes
    @product = @chargify_data["product"].attributes
    @billing = @chargify_data["credit_card"].attributes
  end

  private
  def sub_params
    params.permit(:cid)
  end
end