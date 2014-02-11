class QuickbooksController < ApplicationController

  def index
    p '*'*100
    p 'TOKEN:'
    p session[:token]
    p '*'*100
    p 'SECRET:'
    p session[:secret]
  end

  def authenticate
    callback = oauth_callback_quickbooks_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']
    redirect_to quickbooks_url, notice: "Your QuickBooks account has been successfully linked."
  end

  private
    def set_qb_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = ENV['RID']
    end

end
