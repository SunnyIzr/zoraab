class UpfrontSub < Sub
  def active?
    self.sub_orders.size < self.term
  end

  def next_due_date
    self.sub_orders.where.not(trans_id: nil).last.created_at + 30.days if self.active?
  end

  def due?
    self.next_due_date < Time.new if self.active?
  end

  def get_term
    self.term = self.chargify['product'].attributes['expiration_interval']
    self.save
  end

  def self.refresh
    all.each do |usub|
      if usub.due?
        data = usub.chargify
        installment = usub.sub_orders.where.not(trans_id: nil).size + 1
        trans_id = usub.cid.to_s + installment.to_s
        if SubOrder.pending.map {|o| o.sub.cid}.include?(usub.cid)
          sub_order = SubOrder.pending.select {|o| o.sub.cid == usub.cid }.first
          sub_order.trans_id = trans_id.to_i
          sub_order.save
          ss_order = Shipstation.send_order(sub_order)
          sub_order.ssid = ss_order.OrderID
          sub_order.save
          sub_order.send_to_shopify
        else
          oren = OutstandingRenewal.create(trans_id: trans_id.to_i, name: data[:name], plan: data[:plan], cid: usub.cid, amount: 0.0)
          oren.created_at = usub.next_due_date
          oren.save
        end
      end
    end
  end
end
