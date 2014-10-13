class ApplicationController < ActionController::Base
  http_basic_authenticate_with :name=>ENV['USERNAME'], :password => ENV['PW'], :except => [:new_trans, :shopify_data, :blogs]
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
