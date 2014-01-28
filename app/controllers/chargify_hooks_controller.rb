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
      os_ren = OutstandingRenewal.create(trans_id: params['payload']['transaction']['id'], cid: params['payload']['subscription']['id'], name: params['payload']['subscription']['customer']['last_name'], plan: params['payload']['subscription']['product']['name'], amount: (params['payload']['transaction']['amount_in_cents'].to_i/100))
    end

  end

  private
  def payload_params
    params.permit(:payload)
  end
end



{payload:
  {transaction: {
    id: 12345,
    amount_in_cents: 4500
    },
    subscription: {
      id: 1234567,
      customer: {
        last_name: 'John Doe'
      },
      plan: {
        name: 'SOCK Dabble'
      }
      }
    }
  }
