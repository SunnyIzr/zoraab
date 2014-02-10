class QuickbooksController < ApplicationController

  def index
    p '*'*100
    p session[:token]
    p '*'*100
    p session[:secret]
    p session[:realm_id]
  end

  def authenticate
    callback = oauth_callback_vendors_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']
    redirect_to root_url, notice: "Your QuickBooks account has been successfully linked."
  end

  private
    def set_qb_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = session[:realm_id]
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

end
