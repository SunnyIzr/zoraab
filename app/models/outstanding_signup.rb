class OutstandingSignup < ActiveRecord::Base
  validates_uniqueness_of :trans_id
  validates_presence_of :trans_id


  def self.refresh_outstanding_signups
    all.reverse.each do |signup|
      if signup.trans_id == Order.last.trans_id
        signup.destroy
        return
      end
    end
  end

end
