class SubsController < ApplicationController
  def new
    @sub = Sub.new
  end

  def create
    @sub = Sub.create(sub_params)
    p @sub
    @sub.save
    p @sub
  end

  private
  def sub_params
    params.permit(:cid)
  end
end