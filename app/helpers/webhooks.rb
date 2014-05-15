module Webhooks
  extend self

  def chargify(payload)
    if new_sub?(payload)
      create_new_signup(payload)
    elsif no_pending_order?(payload)
      create_outstanding_renewal(payload)
      DataSession.refresh
    else
      sub_order = save_order_attrs(payload)
      ss_order = Shipstation.send_order(sub_order)
      sub_order.ssid = ss_order.OrderID
      sub_order.save
      sub_order.send_to_shopify
    end
  end

  def new_sub?(payload)
    Sub.find_by(cid: payload['subscription']['id']).nil?
  end

  def create_new_signup(payload)
    OutstandingSignup.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_f/100.0), users_ref: payload['subscription']['customer']['reference'].to_i)
  end

  def no_pending_order?(payload)
    pending_order_cids = SubOrder.pending.map {|order| order.sub.cid }
    !pending_order_cids.include?(payload['subscription']['id'].to_i)
  end

  def create_outstanding_renewal(payload)
    OutstandingRenewal.create(trans_id: payload['transaction']['id'], cid: payload['subscription']['id'], name: payload['subscription']['customer']['last_name'], plan: payload['subscription']['product']['name'], amount: (payload['transaction']['amount_in_cents'].to_i/100.0))
  end

  def pending_order(payload)
    SubOrder.pending.select { |order| order.sub.cid == payload['subscription']['id'].to_i }.first
  end

  def save_order_attrs(payload)
    sub_order = pending_order(payload)
    sub_order.trans_id = payload['transaction']['id'].to_i
    sub_order.amt = payload['transaction']['amount_in_cents'].to_f/100.0
    sub_order.save
    sub_order
  end

end
