class WelcomeController < ApplicationController
  def index
    @os_signups = OutstandingSignup.all
    @os_rens = OutstandingRenewal.all
    @pending_orders = SubOrder.pending
    @subs = []
    @os_signups.size.times { @subs << Sub.new }
  end
  
  def destroy_oren
    OutstandingRenewal.find(params[:id]).destroy
    redirect_to root_path
  end
  
  def destroy_osign
    OutstandingSignup.find(params[:id]).destroy
    redirect_to root_path
  end
end
