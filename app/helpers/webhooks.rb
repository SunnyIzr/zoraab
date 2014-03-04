module Webhooks
  extend self

  def chargify(payload)
    if Sub.find_by(cid: payload['subscription']['id']) == nil
      os_signup = OutstandingSignup.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_f/100.0))
    else
      SubOrder.pending.each do |order|
        if order.sub.cid == payload['subscription']['id'].to_i
          order.trans_id = payload['transaction']['id']
          order.amt = payload['transaction']['amount_in_cents'].to_f/100.0
          order.save
          Shipstation.send_order(order)
          ss_order = Shipstation.send_order(order)
          order.ssid = ss_order.OrderID
          order.save
          return
        end
      end
      os_ren = OutstandingRenewal.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_i/100.0))
      sub = Sub.find_by(cid: payload['subscription']['id'])
      data_item = [sub.id, ChargifyResponse.parse(sub.chargify)]
      data_session = DataSession.last
      data_session.data << data_item
      data_session.data.sort_by! {|sub| sub[1][:next_pmt_date]}
      data_session.save
    end
  end

end
