class WelcomeController < ApplicationController
  def index
    @os_signups = OutstandingSignup.all
  end
end
