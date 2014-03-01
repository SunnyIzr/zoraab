class UpfrontSub < Sub
  def active?
    self.sub_orders.size < self.term
  end

  def next_due_date
    self.sub_orders.last.created_at + 30.days if self.active?
  end

  def due?
    self.next_due_date < Time.new
  end

  def self.refresh
    all.each do |usub|
      if usub.due?
        data = ChargifyResponse.parse(usub.chargify)
        installment = usub.sub_orders.size + 1
        trans_id = usub.cid.to_s + installment.to_s
        oren = OutstandingRenewal.create(trans_id: trans_id.to_i, name: data[:name], plan: data[:plan], cid: usub.cid, amount: 0.0)
        oren.created_at = usub.next_due_date
        oren.save
      end
    end
  end
end
