class WelcomeController < ApplicationController
  def index
    @os_signups = OutstandingSignup.all
    @os_rens = OutstandingRenewal.all
    @pending_orders = SubOrder.pending
    @subs = []
    @os_signups.size.times { @subs << Sub.new }
  end
end
