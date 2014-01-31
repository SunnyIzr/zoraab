class ChargifyHooksController < ApplicationController

  def new_trans
    respond_to do |format|
      msg = { :status => "ok", :message => "Success!" }
      format.json  { render :json => msg }
    end
    Webhooks.chargify(params['payload'])
  end

  private
  def payload_params
    params.permit(:payload)
  end
end
