module Webhooks
  extend self

  def chargify(payload)
    if Sub.find_by(cid: payload['subscription']['id']) == nil
      os_signup = OutstandingSignup.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_i/100))
    else
      SubOrder.pending.each do |order|
        if order.sub.cid == payload['subscription']['id'].to_i
          order.trans_id = payload['transaction']['id']
          order.save
          return
        end
      end
      os_ren = OutstandingRenewal.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_i/100))
    end
  end

end
