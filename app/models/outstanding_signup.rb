class OutstandingSignup < ActiveRecord::Base
  validates_uniqueness_of :trans_id
  validates_presence_of :trans_id
  validate :trans_not_exist?
  after_save :check_dupe_trans


  def self.refresh_outstanding_signups
    all.reverse.each do |signup|
      if signup.trans_id == SubOrder.last.trans_id
        signup.destroy
        return
      end
    end
  end

  def check_dupe_trans
    self.destroy if OutstandingSignup.all.map { |oren| oren.trans_id }.count(self.trans_id) > 1
  end

  def trans_not_exist?
    if SubOrder.all.map {|order| order.trans_id}.include?(self.trans_id)
      errors.add(:trans_id, 'Transaction already fulfilled')
    end
  end

end
