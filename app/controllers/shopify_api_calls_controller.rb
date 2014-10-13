class ShopifyApiCallsController < ApplicationController
  skip_before_filter  :verify_authenticity_token, :only => [:blogs,:update_shopify_customer]
  before_filter :cors_preflight_check, :only => [:blogs,:update_shopify_customer]
  after_filter :cors_set_access_control_headers, :only => [:blogs,:update_shopify_customer]
  def blogs
    render json: Shopify.blogs
  end
  
  def update_shopify_customer
    shopify_customer = ShopifyAPI::Customer.find(params[:id].to_i)
    params[:updates].each do |idx,value|
      shopify_customer.attributes[value['name']] = value['value']
    end
    if shopify_customer.save
      respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.json  { render :json => msg }
      end
    end
  end
    
  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    p '~'*100
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
  end
  
  private
  def shopify_updates
    params.permit(:id,:updates => [:name,:value])
  end

end