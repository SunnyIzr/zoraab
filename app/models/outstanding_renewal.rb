class OutstandingRenewal < ActiveRecord::Base

  def self.refresh_outstanding_renewals
    all.reverse.each do |signup|
      if signup.trans_id == Order.last.trans_id
        signup.destroy
        return
      end
    end
  end

end
