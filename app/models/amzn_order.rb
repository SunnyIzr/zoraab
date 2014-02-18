class AmznOrder < Order
  before_save :calc_fees, :set_gateway

  def calc_fees
    if self.amt > 0.0
      fee = ( self.amt * 0.15 )
      self.fees = fee.round(2)
    end
  end

  def set_gateway
    self.gateway = 'amazon'
  end

end
