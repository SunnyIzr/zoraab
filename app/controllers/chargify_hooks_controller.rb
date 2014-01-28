class ChargifyHooksController < ApplicationController

  def new_trans
    respond_to do |format|
      msg = { :status => "ok", :message => "Success!" }
      format.json  { render :json => msg }
    end
    p params
    p '?'*5000

    if Sub.find_by(cid: params['payload']['subscription']['id']) == nil
      os_signup = OutstandingSignup.create(trans_id: params['payload']['transaction']['id'], cid: params['payload']['subscription']['id'], name: params['payload']['subscription']['customer']['last_name'], plan: params['payload']['subscription']['product']['name'], amount: (params['payload']['transaction']['amount_in_cents'].to_i/100))
    else
      Order.pending.each do |order|
        if order.sub.cid == params['payload']['subscription']['id']
          order.trans_id = params['payload']['transaction']['id']
          order.save
          return
        end
      end
      os_ren = OutstandingRenewal.create(trans_id: params['payload']['transaction']['id'], cid: params['payload']['subscription']['id'], name: params['payload']['subscription']['customer']['last_name'], plan: params['payload']['subscription']['product']['name'], amount: (params['payload']['transaction']['amount_in_cents'].to_i/100))
    end

  end

  private
  def payload_params
    params.permit(:payload)
  end
end
