class OutstandingRenewal < ActiveRecord::Base
  validates_uniqueness_of :trans_id
  validates_presence_of :trans_id
  validate :trans_not_exist?

  def self.refresh_outstanding_renewals
    all.reverse.each do |signup|
      if signup.trans_id == SubOrder.last.trans_id
        signup.destroy
        return
      end
    end
  end

  def trans_not_exist?
    if SubOrder.all.map {|order| order.trans_id}.include?(self.trans_id)
      errors.add(:trans_id, 'Transaction already fulfilled')
    end
  end

end
