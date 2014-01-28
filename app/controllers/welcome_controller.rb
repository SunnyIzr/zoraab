class WelcomeController < ApplicationController
  def index
    @os_signups = OutstandingSignup.all
    @os_rens = OutstandingRenewal.all
  end
end
