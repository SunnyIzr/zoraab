class AmznOrder < Order
  before_save :calc_fees, :set_gateway, :set_ssid

  def calc_fees
    if self.amt > 0.0
      fee = ( self.amt * 0.15 )
      self.fees = fee.round(2)
    end
  end

  def set_gateway
    self.gateway = 'amazon'
  end

  def set_ssid
    o = Shipstation.get_order_by_order_number(self.order_number)
    self.ssid = o.id
  end

  def qb_gift_card
    nil
  end

  def qb_fees
    {'Amazon Fee' => self.fees.to_s}
  end

  def qb_memo
    nil
  end
end
