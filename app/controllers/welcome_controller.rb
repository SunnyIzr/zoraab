class WelcomeController < ApplicationController
  def index
    @os_signups = OutstandingSignup.all
    @os_rens = OutstandingRenewal.all
    @pending_orders = Order.pending
  end
end
